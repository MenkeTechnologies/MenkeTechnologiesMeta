```
██████╗  █████╗ ████████╗ ██████╗██╗  ██╗     ██████╗ ██████╗ ██████╗ ███████╗
██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║    ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██████╔╝███████║   ██║   ██║     ███████║    ██║     ██║   ██║██████╔╝█████╗  
██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║    ██║     ██║   ██║██╔══██╗██╔══╝  
██║     ██║  ██║   ██║   ╚██████╗██║  ██║    ╚██████╗╚██████╔╝██║  ██║███████╗
╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

![C++](https://img.shields.io/badge/C%2B%2B-20-05d9e8?style=flat-square)
![Depends](https://img.shields.io/badge/depends-juce__core-ff2a6d?style=flat-square)
![Role](https://img.shields.io/badge/signal-agnostic%20patch%20graph-39ff14?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-audio%20stack-d300c5?style=flat-square)

### `[THE SHARED ROUTING CORE]`

> *"Knows nothing about audio or MIDI."*

The signal-agnostic **modular patch graph** behind the MenkeTechnologies plugin stack — the cable routing system shared by **zpwr-fx**, **zpwr-synth**, and **zpwr-midi-fx**. Created by MenkeTechnologies.

### [`zpwr-fx`](https://github.com/MenkeTechnologies/zpwr-fx) · [`zpwr-synth`](https://github.com/MenkeTechnologies/zpwr-synth) · [`zpwr-midi-fx`](https://github.com/MenkeTechnologies/zpwr-midi-fx)

### [`Read the Docs`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-patch-core) &middot; [`Engineering Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-patch-core/report)

---

## Table of Contents

- [\[0x00\] Overview](#0x00-overview)
- [\[0x01\] Using It](#0x01-using-it)
- [\[0x02\] Defining a Module](#0x02-defining-a-module)
- [\[0x03\] Shared WebEditor & Expandable Soft Knobs](#0x03-shared-webeditor--expandable-soft-knobs)
- [\[0x04\] Patch Versioning & Migration](#0x04-patch-versioning--migration)
- [\[0x05\] User Modules & Registry](#0x05-user-modules--registry)
- [\[0x06\] Build / Test](#0x06-build--test)
- [\[0x07\] Layout](#0x07-layout)
- [\[0x08\] Companion Documents](#0x08-companion-documents)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] OVERVIEW

It owns the parts that are the same in every modular plugin and nothing else:

- **Routing** — nodes wired by source ids, fan-out, feedback.
- **Evaluation** — topological order each rebuild; cycles resolve with a one-sample delay.
- **Mod matrix** — every node param has a `(source, depth)` modulation.
- **Per-cable** gain + colour.
- **Lock-free** live edits (atomic params) + atomic graph swap on structural edits.
- **JSON** serialisation of a whole patch.
- **`ScriptEngine`** — a small RT-safe expression VM, exposed as the `Expr` module.
- **Latency alignment** — opt-in per engine (`zpc/Latency.h`); see below.

### Intra-patch automatic latency alignment

A hand-wired patch can put a genuinely latent block (a 1024-point STFT frame, a partitioned
convolution, a 4x-oversampled clipper, a windowed smoother) on one branch and a direct wire on
another, then sum them. Every modular environment leaves that misalignment for the user to hear
and hand-correct with a delay block.

`zpc/Latency.h` fixes it from data the engine already has. Each latent block declares its
intrinsic group delay on the registry (`ModuleInfo::latencySamples` / `latencyFn`, populated by
`registerModuleLatencies`, which `registerAudioModules` calls). `computeLatencyPlan` then runs a
longest-path relaxation over the **same** topological order `RuntimeGraphT` already computes on
every rebuild, and pads every shorter branch entering a node — and every output cable — up to the
longest one. Alignment is per node, not per slot, so a two-input block sees all of its inputs on
the same sample.

A host opts in with one call, after which the compensation is recomputed on every patch load and
every structural edit, and the patch's total latency is available to report to the DAW:

```cpp
zpc::enableLatencyCompensation (engine, registry, [this] { triggerAsyncUpdate(); });
setLatencySamples (engine.latencySamples());
```

Cost when nothing is latent is zero: no cable gets a delay ring and the per-sample path is
byte-identical (asserted by `LatencyTest`). Note-stream graphs are unaffected — events carry
their own sample offsets, so `applyLatencyPlan` is a no-op for any `S` other than `float`.

It knows **nothing about audio or MIDI**. Each host supplies:

1. a **`ModuleRegistry`** of node types (name, param specs, input count, a `makeState` factory and a `compute` callback), and
2. the **external source values** each sample (In L/R, noise, soft keys, MIDI/MPE, … — whatever ids `1..kBlockBase-1` mean to that host).

Block outputs (`kBlockBase + n`) are resolved by the core; everything else is the host's. The graph is **templated on the signal type** carried between nodes (a `SignalTraits<S>` policy): `float` for audio (zpwr-fx, zpwr-synth) and a **note-event stream** for MIDI (zpwr-midi-fx). Every node carries an `S` signal output plus a `float` scalar projection (its mod-matrix value); the `float` instantiation is the plain audio graph.

---

## [0x01] USING IT

```cpp
zpc::ModuleRegistry reg;
zpc::registerCoreModules (reg);     // Expr, Gain, Mixer
registerMyModules (reg);            // your audio / synth / midi modules

zpc::PatchEngine engine (reg);
engine.prepare (sampleRate);
engine.setPatch (myPatch);

// audio thread:
auto g = engine.activeGraph();
g->beginBlock();                       // snapshot params once per block (optional fast path)
for (int i = 0; i < numSamples; ++i)
{
    float ext[N] = { inL[i], inR[i], noise, softKeys..., midi... };
    g->evalSample (timeIndex++, ext, N);
    out[i] = g->sourceValue (g->outputSource (0)) * g->outputGain (0);
}
```

`beginBlock()` is an opt-in CPU optimization: it snapshots every node's params (resolving tempo-sync once) into a per-block mirror so the per-sample inner loop does **zero atomic param loads** — UI param edits then land at the next block boundary (block-rate automation, matching the host's own smoothing cadence). It is purely optional: a host that never calls it keeps the per-sample path with relaxed atomic loads. With `zpc::LayeredEngineT`, call `zpc::beginLayersBlock (eng)` once at the top of `processBlock` instead — it fans the snapshot out across every layer plus the master/aux FX and mod buses.

---

## [0x02] DEFINING A MODULE

```cpp
zpc::ModuleInfo m;
m.name = "Gain";
m.description = "Gain trim (dB) plus a DC bias offset.";  // one-line doc; ASCII only
m.category = "Utility";                                    // taxonomy bucket for the reference
m.params = { { "Gain", -60, 24, 0 } };
m.numIns = 1;
m.compute = [] (const zpc::ComputeContext& c)
{
    return c.in[0] * std::pow (10.0f, c.params[0] * 0.05f);
};
reg.add (std::move (m));
```

`description` / `category` are the source of truth for the generated module
reference (`docs/reference.html` + `reference.pdf` in each host plugin, via
`zpc::renderReferenceHtml`). **Keep description (and every other C++ string
literal) ASCII** — they load into `juce::String` through the `const char*` ctor,
which asserts ASCII and mangles a multi-byte em-dash (`—`) into mojibake in the
rendered docs. Use a plain `-`. A linter enforces this (see Build / Test).

---

## [0x03] SHARED WEBEDITOR & EXPANDABLE SOFT KNOBS

`zpc::WebEditor<Engine>` is the WebView backend every host shares (catalog/patch JSON, BinaryData serving, preset I/O, 155 native functions). Soft knobs are an **expandable pool**: hosts create a fixed ceiling of automatable params up front (`EditorConfig::maxSoftKeys`) and expose the runtime *active* count through `getSoftKeyCount` / `setSoftKeyCount` callbacks; the UI's `+`/`−` controls call the `setSoftKeyCount` native function, which returns a fresh catalog so the source list and knob row rebuild. The first soft knob's source id is `EditorConfig::srcSK0`, and host MIDI/perf sources sit after the whole pool so growing the count never shifts their ids.

**Native functions the web UI deliberately does not call.** A registered name is an ABI an
out-of-tree host may already depend on, so nothing here is removed once shipped — but a name with no
caller is indistinguishable from a wiring bug unless the reason is written down. Every such name
carries an inline `no frontend caller (<name>):` note at its `withNativeFunction` registration in
`WebEditor.h`, saying whether it is superseded and by what, and naming the consumer where one
exists. Today the set is 9 names:

| Name | Why no caller | Consumer |
| --- | --- | --- |
| `getSoftKeyCount` | the count already ships on the catalog as `numSoftKeys`, and `setSoftKeyCount` echoes the fresh one | out-of-tree host driving the editor headlessly (no catalog render to piggyback on) |
| `getBlockPresets` | superseded by `blockPresetList`, which merges factory *and* user presets for the card's `‹ ★ ›` picker | tooling that needs the factory set to be identical on every machine — `blockPresetList` folds in the local `block_presets.json` |
| `setParamMod` / `setParamModDepth` | target-addressed `(node,param)`; the mod matrix edits rows by index with `addMod` + `setModTarget` + `setModSource` + `setModDepth` | a caller holding only a parameter. Not an alias: `setParamMod` enforces one mod per target by retargeting an existing row, where `addMod` always appends |
| `setManyParams` | the echo-free bulk apply — the UI moves one knob at a time and loads whole patches with `setPatchJson` | a caller morphing at control rate, for which `setBlockParam`'s per-call patch echo is the wrong cost. In-tree morphing runs host-side instead |
| `morphBegin` / `morphSet` / `morphEnd` | the XY pad binds `morphX`/`morphY` through `Juce.getSliderState`, so the relay carries the whole gesture | **zpwr-synth** — the only host that wires `EditorConfig::morphGestureBegin` / `morphSetValue` / `morphGestureEnd`, onto the reserved `morphX`/`morphY` host params. Elsewhere the callbacks are null and the three are registered no-ops |
| `stereoize` | the ⊞ STEREO toggle maintains the mirror with `stereoSync` on every edit | a caller that wants the one-shot split. Different contract: `stereoSync` re-mirrors and overwrites right-chain drift, `stereoize` splits once and leaves both halves alone |

Reproduce the set by taking every `pfx("name")` in `WebEditor.h` that no bundled frontend file
contains **as the tail of a quoted string literal** — ``/['"`][A-Za-z0-9_]*name['"`]/`` — which is how
a caller writes it, verbatim or composed onto the `uiPrefix` (`"trkgetPatch"`). The quoted-literal
form matters: a plain "is the name mentioned anywhere" search hides `morphSet` behind the unrelated
JS local `let morphSet = [...]` in `webui/index.html`, and reports eight names instead of nine.
zpwr-daw runs that comparison as a test (`test/webeditor-native-fn-coverage.test.js`) against the
frontend it bundles, so a newly registered name is either wired or explained before it ships.

**Hosting a VST3 / AU in a block.** The `Plugin` block (`include/zpc/PluginBlock.h`) processes cabled
audio through a real hosted plugin. *Which* plugin it hosts is a host action — the host owns the
plugin scan and the node's `PluginNodeState` — so the block card renders a **⭳ PLUGIN** button only
where the host wired `EditorConfig::loadPluginIntoNode`, and the button calls that native function
with the block index. The guard is per-graph (the native fn is registered under the graph's
`uiPrefix`), so a host that wires the picker on one graph and not another gets the button on exactly
the one that can serve it. The host's `PluginHost::startScan()` runs the sweep on a background thread (the cached list keeps serving `listJson()` / `create()` until the new one is installed) and `scanStatusJson()` reports per-format progress and the plugin being probed for the UI to poll; `scan()` remains the blocking variant.

**EZ mode** (for beginners): set `EditorConfig::autoWire` to a function that returns the current patch with the standard signal path connected, and the UI shows an **⚡ EZ WIRE** button. `zpc::autoWireChain(patch, inputSource, takesAudio)` is the ready-made chain (input → blocks in order → outputs) for linear hosts; the optional `takesAudio` predicate skips blocks that do not belong in the signal path, and `zpc::audioChainFilter(registry)` builds one that admits a block only when its first input carries audio (an input labelled Trig / Gate / Clock / Sync / Reset / Strike / CV / Pitch, or no input at all, marks a modulator or source). Unset, every non-None block is chained, which note-stream hosts rely on (there a Gate input is the note path); a synth supplies its own voice-topology wiring. Param enum labels: a `ParamSpec` with non-empty `names` renders as a labelled dropdown instead of a knob.

**Stereo mode + Stereo Lock** (audio-L/R hosts only — `EditorConfig::getStereoMode` set; gated off for the MIDI fx) — two header toggles that maintain a true-stereo patch from a single editable chain:

- **⊞ STEREO** mirrors the entire graph — every block, cable and mod — into an independent **right-channel** chain. Each clone node *j′ = j + N* references the cloned upstream nodes, reads **In R** where the original reads **In L** (and vice-versa, via `EditorConfig::stereoInL`/`stereoInR`), and feeds **Out R**; **Out L** is left untouched. So a chain starting from one input becomes true L/R stereo; a chain summing L+R stays dual-mono. Clones are tagged with `NodeDef::clone` (serialized in the patch JSON) so the engine always knows which half is which.
- The mirror is **maintained like EZ**: `stereoSync` is folded into the same post-structural-edit hook as `ezRewire`, so adding/removing/retyping a block (or a cable/mod) re-mirrors automatically. EZ runs first (wires the left chain), then the mirror copies it to the right — the two **compose**. Toggling Stereo off calls `stripStereo` (removes the clone nodes, reindexes, back to mono left).
- In plain Stereo the clone **knobs are independent** (preserved across structural syncs) so you can detune L/R for width. **🔒 LOCK** additionally links them: a left-channel `setBlockParam` mirrors to `node + leftCount()` (the clone redraws live in the UI too), and the locked clone blocks render dimmed with a lock badge.
- Engine API (`PatchEngineT`, forwarded through `LayeredEngineT` / a host's voice engine): `stereoize(inL,inR)`, `stripStereo()`, `stereoSync(inL,inR,lock)`, `leftCount()`. Toggle state is `HostState` (`stereoMode`/`stereoLock`, persisted alongside `ezMode`). Native functions: `setStereoMode`, `setStereoLock`, `reconcilePresetModes`.
- **Preset load** never silently transforms a preset: `reconcilePresetModes` turns **EZ off** (don't re-wire hand-authored routing) and **Lock off**, and sets **Stereo on iff the loaded preset actually contains clone nodes** — so the toggles always match the preset you loaded.

**Other editor aids** — **🧬 Mutate** (header) randomises the current patch's continuous params + mod depths within their own ranges (Shift = stronger; mod-depth / enum mutation toggle in SETTINGS); the **preset Morph** XY pad (synth) bilinearly blends four corner snapshots and is always host-automatable via reserved `morphX`/`morphY` params; a **global busy spinner** (Audio-Haxor design, `busy()` overlay) shows during heavy ops (mutate, stereo) instead of a beachball; synth-panel blocks carry a **B1…BN index badge** (their source id in cables/mods); and the synth's first-class **Trigger** mod source (`kSrcTrig`) emits a one-sample impulse on each note-on edge, distinct from the held **Gate**.

**Command palette / automation vocabulary** (`webui/zpc-command-palette.js`) — the ⌘K palette
(toolbar `⌘K` button in a host that eats the keystroke) lists every visible tab and every enabled
header action, with the personal `ZGui.userCommands` entries ranked on top. The same list is
published on the shared bus through `ZGui.palette.setCommands()`, which is what fills the
user-command editor's **action** dropdown and arms the `zgui:user-command` router — so every row
is also addressable **by id** from a saved command chain. Ids come from structure and never from
the label: a tab is `tab.<data-pane>`, a header button is `action.<element-id>`, an analyzer is a
literal (`audit.patch`, `audit.sum-map`, `audit.euclid-orbit`, `audit.session-proof`,
`terminal.toggle`). A label is a translated string, so an id derived from one would rename itself
on a locale switch and break every saved chain; `webui/zpc-command-palette.test.mjs` pins that by
re-reading the same DOM with every label rewritten and demanding an identical id set. The
vocabulary is republished on init, on every palette open, and immediately before the router
resolves an id, so a host-gated tab that reveals itself after boot (PRODUCE / ZTRANSLATE / PDF in
zpwr-daw) is dispatchable without reopening the palette; `window.zpcPublishCommands()` forces a
refresh.

An **embedded core contributes its own commands** to that same vocabulary with
`registerCommands(fn)` (also exposed as `window.zpcRegisterCommands`, assigned at module load so a
sibling ES module that imports later still finds it; a core that publishes *before* this module
evaluates parks its contributor on `window.zpcPendingCommands`, which is drained on the next build,
so neither load order loses a row). A contributor is a **function**, not a snapshot, so a core whose
catalog grows after boot is re-read on every republish; registering the same function twice is a
no-op, a contributor that throws is skipped rather than emptying the palette, and zpc's own
structural ids always win a collision. A row tagged `bulk: true` marks a large
machine-addressable catalog — the clip engine's ~1.2k editor commands — and is published for id
routing but withheld from the visible overlay, which builds a DOM row for every item it is handed
and matches all of them on an empty query; the owning core ships its own filtered palette for
browsing them.

**Patch Audit** (zpc palette -> "Patch Audit") — a static signal-path linter over the live patch graph, shared by all three hosts. Purely client-side over the in-memory patch JSON + catalog (no engine round-trip, O(V+E), read-only): it flags **dead blocks** (output that never reaches Out - directly or through a modulation on a block that is heard - i.e. wasted CPU), **feedback loops** (signal-graph cycles the engine resolves with a one-sample delay), the **critical serial path** (the longest chain of blocks to the output, a latency / CPU-depth proxy), **inert modulation** (routes with an unpatched source, zero depth, or a missing target), a **silent-patch** check (no block cabled to any output) and the **fan-out hotspot** (the most-shared source). Findings open in a `ZGui.modal`, ranked by severity, and each flagged block is a chip that reveals it in the PATCH tab. The topology is read straight from the patch JSON: any cable / mod source with id `>= blockBase` is a block output (block index `id - blockBase`), so dead-code / cycle / longest-path analysis is unambiguous across the float (fx/synth) and note-stream (midi-fx) graphs alike.

**Sum Map** (zpc palette -> "Sum Map") — a static summing-node (mixing-bus) analyzer over the live patch graph, shared by all three hosts. Where **Patch Audit** reads cable *presence* (reachability, cycles, depth — and ignores gain) and **Mod Reach** reads the *mod matrix* (how far a parameter can travel — and never looks at signal cables), Sum Map is the third axis: the **signed cable-gain algebra at every summing junction** (a block input slot fed by two or more cables, or an Out L / Out R bus). Purely client-side over the patch JSON (O(cables), read-only, no engine round-trip) it flags **phase cancellation** (cables sum destructively, net `|Σgain|` far below `Σ|gain|` — silent signal loss the engine's Auto-Gain-Stage / Soft-Clip cannot recover, since those only attenuate and never re-phase), **coherent overload** (`Σ|gain|` stacking past unity — headroom burned by correlated in-phase cables), **duplicate cables** (the same source wired into one slot twice — doubling or nulling), and **buried cables** (a cable summing ≥ 20 dB below its junction's dominant, inaudible in the mix). The coherent worst-case (every source correlated and in phase) is a stated *bound*, the same philosophy as Mod Reach's worst-case extremes. Findings open in a `ZGui.modal`, ranked by severity, each junction a chip that reveals its block in the PATCH tab. The signed cable gain (−2…+2, so a negative gain is a polarity flip) makes cancellation real; the junction algebra is identical for the float (fx/synth) and note-stream (midi-fx) graphs — there a summing node merges event streams and cable gain scales event magnitude, so cancellation is velocity subtraction, overload is event pile-up.

**Junction Meter** (`webui/zpc-junction-meter.js`) — the *live* half of Sum Map: a **cancellation ammeter on every summing junction**, painted straight onto the patcher as a small ring beside each junction's jack. Every correlation meter that ships (FabFilter Pro-Q, Ozone, iZotope Insight) measures the **output bus**, because no product exposes the junction set of a user-built graph in the first place; here each junction carries its own. It is fed by the payload the cable-glow poll already fetches (`getCableActivity` → `{ metered, lv:{srcId:level} }`, 24 Hz) — no second render pass, no new audio path, O(cables) per poll. Two numbers per junction: the **live cancellation**, which is Sum Map's own `1 − |Σg| / Σ|g|` weighted by what is actually sounding (`A_i = gain_i × level_i`), and the **envelope co-activity** `r`, a running Pearson kept as six exponentially-weighted accumulators per cable pair. Together they cross-examine the static bound and label the junction `confirmed` (the predicted null is happening now), `unreachable` (the cables alternate, `r ≤ −0.35`, so the prediction cannot occur for this material), `emerging` (a null the unit-gain pass did not predict, because the live levels drifted), or `hot` (the live in-phase worst case reaches full scale). Only those four paint; `clear` and `idle` stay invisible.

`r` is an **envelope** correlation, not a waveform phase correlation, and is never reported as one: the engine publishes `sourceLevel(id)` = `nodePeak`, a decaying per-block peak *magnitude* (`PatchCore.h:1377` → `:879`) — no sign, no waveform, no timestamp — so a true inter-sample phase figure is not derivable from what crosses the bridge. What `r` does answer is whether two cables are ever loud together, which is exactly what decides if the static bound is reachable, and the shared peak-hold release biases it toward `+1`, so a negative `r` is only ever used to *withdraw* a static warning, never to raise a new one. Sources below `blockBase` are **unmetered** in zpwr-fx (`PatchCore.h:1379`: externals are not metered by the core graph), so absence is not silence there and such a junction reports `unmetered` rather than a false `idle`; zpwr-synth's `PolyEngine` does meter externals, so the same junction is fully measurable in the synth.

**Euclid Orbit** (zpc palette -> "Euclid Orbit", `webui/zpc-euclid-mirror.js`) — the modulated Euclidean rhythm, drawn. Every Euclidean sequencer that ships (Ableton's generator, Bitwig's Euclid, VCV's Euclidean modules, Cthulhu's arp) exposes steps/pulses/rotation as *settings*: two integers in, one rhythm out. Here they are ordinary modulation *destinations* — `PatchCore.h:1252-1261` sums every route targeting a node into its parameter vector before the block runs, and `doEuclid` re-reads Pulses/Steps/Rotate from that vector on every block (`MidiModules.cpp:285-287`), so an LFO on Pulses does not smear one rhythm, it walks the patch through a **sequence of different rhythms**. Because the engine casts each parameter to `int`, that map is piecewise constant: the patch visits a finite **orbit** of exact Euclidean patterns with exact switch-over points, and both are solved in closed form (each parameter is affine in the modulator scalar, so a breakpoint is one division) rather than sampled. The modal lists the orbit, scrubs the modulator, and draws the live ring with the unmodulated rhythm ghosted behind it. Read-only: it never edits the patch.

The engine has **two** Euclidean generators and they disagree. `zpc/midi/Euclidean.h`'s `euclidean()` is Bjorklund and rotates the pattern *left*; `MidiModules.cpp`'s `euclidStep()` is the Bresenham distribution and rotates *right*. They agree on E(3,8) (the tresillo, `x..x..x.`) and differ on E(5,8) — `x.xx.xx.` against `x.x.xx.` — which are rotations of one another, so the difference survives a casual look while still putting the onsets on different steps. `SeqEuclid` and `EuclidMel` use the first; `EuclideanGate`, `EuclideanAccentVelocity`, `EuclidComplementGate` and `EuclideanVelocity` use the second. Euclid Orbit selects the generator per block type rather than picking one, and both of its ports are pinned to `tests/euclid_golden.txt` — the same table `EuclidMirrorTest` re-derives from the shipping C++ — so the rhythm drawn cannot drift from the rhythm played. Its block table (which parameter index carries Pulses/Steps/Rotate, and which generator each handler calls) is extracted from `src/midi/MidiModules.cpp` by the node test rather than restated, so re-ordering a block's parameters fails a test instead of silently pointing the mirror at the wrong knob.

**PERFORM tab** — a play surface that drives the host-automatable soft-key macros (each is a real APVTS param via the soft-key relays, so everything below records as host automation):

- **ORB** (Omnisphere-style) — drag the puck: **angle** selects one of 8 randomised scenes (a per-macro offset vector), **distance** from centre scales intensity; 🎲 rolls fresh scenes and jumps to a random one; **⏺ / ▶** record the puck gesture and loop it back, re-applying the recorded motion to the macros.
- **PRESET MORPH** — bilinear blend of four corner presets (host-automatable `morphX`/`morphY`); 🎲 fills all four corners at random (shown behind the `busy()` spinner).
- **XY macro pads** — each drives a pair of soft keys, with a per-pad **HOLD**/**SPRING** release toggle (HOLD leaves the dot, SPRING snaps both axes back to centre); per-pad 🎲 and a global **RANDOMIZE**.
- **SNAPSHOTS** — eight macro-surface snapshots (localStorage): click empty to save, filled to recall, right-click to clear.
- **MIDI IN toggles** — **PROGRAM** (respond to MIDI Program Change) and **BANK** (Bank Select CC0/CC32; `program = (MSB*128+LSB)*128 + PC`); both default ON, persisted in `HostState` (`pgmChange`/`bankSelect`), exposed via `EditorConfig::getPgmChange`/`setPgmChange`/`getBankSelect`/`setBankSelect`, catalog flag `hasMidiProgram`, native functions `setPgmChange`/`setBankSelect`.
- **ARP** — mode / rate / **LATCH** (keep arpeggiating held notes after release; `EngineSettings::arpLatch`, set via `setSetting`).
- **KEY / SCALE** quantize and **CHORD** stacking (Oct/5th/Maj/Min/Maj7/Min7/Sus4/Power — the on-screen keyboard sends the stacked intervals).
- On-screen 3-octave keyboard (drag-glissando) plus spring pitch-bend and mod wheels. Set `EditorConfig::getWheels` to return `{ pb: 0..16383, mod: 0..127 }` and one poll moves every on-screen wheel to follow an external keyboard (skipped while that wheel is dragged; unset ⇒ the wheels move only when dragged). Set `EditorConfig::sendMidi` to a sink that injects a `juce::MidiMessage` into the host's block (a `zpc::MidiInbox` in `HostSupport.h` is the thread-safe editor→audio queue); the UI emits `midiNoteOn/Off`, `midiPitchBend`, `midiCC`.

**BROWSE tab** — a SynthMaster-style tag/category preset browser. Presets carry facet tags (`"Facet:Value"`, e.g. `Type:Bass`, `Style:Acid`, `Character:Aggressive`); factory presets get a `Bank:Factory` tag plus `EditorConfig::factoryTags(index)`, user presets store their tags in the saved JSON and get `Bank:User`. Fixed, ordered facet columns named PRODUCT / BANK / AUTHOR / INSTRUMENT TYPE / ATTRIBUTES / STYLES, each led by an `(All)` reset row (multi-select, AND across facets / OR within one); a fuzzy-searched, numbered preset list with per-preset favourite stars (persisted to `favorites.json` via `loadFavorites` / `saveFavorites`), a favourites-only filter and a random-preset button (header 🎲 + browser, the latter respecting the active facet filter); and a structured PRESET DETAILS panel (product, bank, author, description, instrument type(s), attribute(s), style(s)) with author/description/tags editable on user presets. The tag vocabulary + factory tag tables live in `include/zpc/PresetTags.h` (`zpc::fxFactoryTags` / `synthFactoryTags` / `midiFactoryTags` and the canonical `attributeOrder()` / `styleOrder()` / `typeOrder()`), published in the catalog so facet columns order by the canonical taxonomy. Native functions: `getPresetLibrary`, `setPresetTags`, `loadFavorites`, `saveFavorites`; `savePreset` takes an optional tags array.

**Wavetable oscillator + waveform editor** — the `Wavetable` module (`include/zpc/Wavetables.h`) is a config-driven oscillator: its single-cycle frames live in the node's `config` string (`;`-separated frames, `,`-separated −1..1 samples), and the `Position` param morphs between them. zpc ships Serum-style built-in tables (`wavetableNames()` / `builtinWavetable()` → catalog + the `getWavetable` native function). Opening a `Wavetable` block shows a waveform editor: draw on the canvas to reshape the current frame, navigate/add/remove frames, and load a built-in table — all persisted through `setScript` (node config).

**Graphical LFO / envelope editors** — opening an LFO- or envelope-shaped block (detected by its param names: `Shape`+`Rate`, or `Attack`+`Release`) shows a graphical panel above the knobs. The envelope is a draggable SVG ADSR/AR curve (handles write straight to `setBlockParam`); the LFO draws its waveform with the exact DSP shape math, a four-way shape picker, and a `requestAnimationFrame` playhead at the block's rate. Param-driven only — no engine round-trip.

**Colour-scheme editor** — the SETTINGS pane has per-hue colour pickers (accent, cyan, magenta, text, backgrounds, border, …) that recolour the UI live; the glow/dim variants are derived from the base hues. Named custom schemes are saved to a real file, `<userAppData>/<name>/colorschemes.json`, via the `loadColorSchemes` / `saveColorSchemes` native functions (ported from audio-haxor). Built-in schemes still live in the webui.

**Header live meters** — the header shows three host-fed readouts, each polled by the UI and driven by an optional `EditorConfig` callback (absent callback = the readout hides itself): the oscilloscope + 3D spectral waterfall (`getAnalyzer` → `{scope,spectrum}`), the MIDI input LED (`getMidiActivity`), and the **CPU meter** (`getCpuLoad`). `getCpuLoad` returns the realtime DSP load as a fraction of the audio-thread budget (1.0 = the block render used its entire `numSamples / sampleRate` window); the readout shows it as a percentage, amber past 70% and red past 90% (approaching dropout). Hosts measure it with `zpc::CpuMeter` (`include/zpc/HostSupport.h`): bracket `processBlock` with `startBlock()` / `endBlock(numSamples, sampleRate)` and expose `load()` through the callback. A high unison/voice count multiplies per-voice work and is the usual cause of a spike. Lock-free — the audio thread only writes, the UI only reads. A **RAM meter** (`getRamUsage` native function) sits beside it, showing the process resident set size in MB/GB; it defaults to `zpc::processResidentBytes()` (mach on Apple, `/proc/self/statm` on Linux, PSAPI on Windows) so it works with no host wiring, and `EditorConfig::getRamBytes` can override it to report a host-specific figure (e.g. just the sample-bank bytes).

**Log file** — `zpc::WebEditor` owns a `juce::FileLogger` at `<userAppData>/<name>/<name>.log` and writes timestamped lines for editor open, preset save/load and scheme save. The UI can append via the `logUi` native function, read the path with `getLogPath`, and open it in the OS file browser with `revealLog` (the **REVEAL LOG FILE** button under SETTINGS → Diagnostics).

**Global modulators** — `zpc::GlobalMods` (`include/zpc/GlobalMods.h`) is the shared always-available modulator bus: generated sources (3 LFOs, 2 envelopes, Random, Sample&Hold) advanced per block, plus the MIDI-derived set fed from incoming MIDI (mod wheel, pitch bend, channel + poly aftertouch, velocity, note, gate, key-track, expression, breath, sustain, the MPE pressure/slide/bend dimensions, and 8 assignable CC slots), all normalised 0..1. A host copies `value(i)` into its external scalar array and feeds `names()` to the catalog so every plugin exposes the same modulator set.

**Mixer modulation — two summing paths** — a layer's mixer strip (Vol/Pan/Width), the master and aux returns can be modulated **two independent ways that sum** into the same per-layer/master offset (`gLayVol/Pan/Wid[L]` etc., accumulated in the host's `processBlock`): (1) **Global mod** — routes in the shared global-mod control graph (its own LFOs/envelopes plus the `GlobalMods` sources), able to target *any* layer + master, edited in the **GLOBAL MOD** tab; and (2) **per-layer mod** — routes in a layer's *own* patch graph targeting that layer's Vol/Pan/Width (the **LAYER MOD DEST** rows in the layer's OUT column), driven by the layer's *own* sources (a layer LFO/env) and read mono from the first sounding voice (mixer params only matter while sounding). The two live in **separate graphs with separate source pools**, so a route made in one never appears in the other — but both stack onto the same target, on top of the knob value.

**Layers + bus routing** — `zpc::LayeredEngineT<Engine>` (`include/zpc/LayeredEngine.h`) stacks unlimited layers, each a full engine copy; the editor edits the active layer and the layer bar adds/duplicates/deletes/mutes/solos/gains/pans them. Each layer carries a `route`: **parallel** (sums into the mix) or **series** (processes the previous layer's output) — a per-bus P/S toggle in the layer bar, threaded by `evalLayersMixed` (a layer feeding a series successor leaves the mix; a muted series layer bypasses). `layersToJson`/`layersFromJson` round-trip the whole stack including routing.

**Microtuning (Scala)** — `zpc::parseScala` / `scalaToNoteCents` (`include/zpc/Scala.h`) turn a Scala `.scl` scale into a per-MIDI-note cents-offset table. A synth applies it as a fractional Note external so every oscillator inherits the tuning with no per-oscillator change; the synth SETTINGS pane has a **LOAD .SCL** control (`chooseScalaFile` / `tuningName`), persisted in plugin state. A 12-equal scale yields zero offsets (standard tuning unchanged).

---

## [0x04] PATCH VERSIONING & MIGRATION

`patchToJson` stamps `"v": kPatchJsonVersion`. `patchJsonVersion(json)` reads it (missing ⇒ 1 = legacy). `migrateSourceIds(patch, remap)` rewrites every source id a patch references (input cables, mod sources, outputs) — hosts call it on load to shift a legacy external-source layout forward.

---

## [0x05] USER MODULES & REGISTRY

A **user module** is a selection of blocks (plus their internal cables, mod routes and tempo-sync overrides) saved as a self-contained, reusable sub-graph — the VCV-Rack *Selection* (`.vcvs`) idea. Loading one **splices it into the current patch**: its blocks are appended and every internal id is reindexed, so the module *expands out* into real, editable blocks (Phase 1). The saved file also records its input ports and output node(s), so a future release can load the same file as one **encapsulated nested block** without a format change.

**Core API** (`PatchCore.h`, signal-agnostic, unit-tested):

```cpp
ModulePorts ports;
PatchDef sub = extractSubPatch (full, { 2, 5, 6 }, ports);  // save: subset -> normalized 0..k-1 sub-graph
int base = spliceInsert (dst, sub, externalRemap);          // load: append + reindex; returns the append base
```

- `extractSubPatch` renumbers internal cables to local ids, cuts cables to blocks outside the selection (open inputs), keeps host externals (In L/R, soft knobs, global mods) and records them in `ports.inSources`, and marks internal sinks in `ports.outNodes`.
- `spliceInsert` offsets every internal node-output id by the append base (and `ModRoute.node` / `ParamSync.node`); host externals pass through `externalRemap` (null ⇒ identity), a `0` result drops that cable — so a module saved in one host degrades to open inputs in a host that lacks the source. `EditorConfig::hostAliases` lists former names a renamed host still answers to: a module whose `"host"` matches one loads on the identity path instead of the cross-host label remap. The same aliases drive a one-time data migration: on first launch under the new name `WebEditor` copies every file (except `.log`) from `<userAppData>/<alias>` into `<userAppData>/<name>`, never overwriting an existing file, leaving the old directory untouched, and dropping a `.migrated-from-<alias>` marker so it runs once. `loadModule` trims trailing empty blocks before splicing, so a module lands next to the last real block.

**Editor + UI.** `WebEditor` adds a second `PresetStore` (full CRUD) and the native functions `listModules` / `saveModule` / `loadModule` / `deleteModule` / `renameModule` / `cloneModule`, plus `fetchRegistry` / `importRegistryModule`. `loadModule` routes through the same undo path as every structural edit (one undoable splice). In the shared WebView UI, **Cmd/Ctrl-click** or **Shift-click** blocks to select, or drag on empty canvas to marquee-select every block card and cable the rectangle touches (Shift or Cmd/Ctrl adds to the selection; Delete/Backspace removes the selected cables), then **◈ MODULES** opens the manager: save the selection, drop saved modules into the patch, or browse the registry.

**`.zmod` format** (envelope versioned independently of the inner patch `"v"`):

```jsonc
{ "zmod": 1, "name": "...", "category": "Filter", "desc": "...", "host": "zpwr-fx",
  "patch": { /* a self-contained PatchDef, nodes 0..k-1 */ },
  "inPorts": [ { "src": 1, "label": "In L", "role": "base" } ],
  "outPorts": [ { "node": 3, "label": "Out" } ], "nodeCount": 4 }
```

**Registry.** A shared module library modeled on [library.vcvrack.com](https://library.vcvrack.com/) — a static, git-backed JSON index (no server), served from GitHub Pages and set per host via `EditorConfig::registryUrl`. The index lists published modules with metadata and download URLs; the UI browses/filters it and imports a chosen `.zmod` into the local store. Publishing is a manifest PR, mirroring VCV's submission flow.

```jsonc
// registry.json
{ "modules": [ { "slug": "barrys-delay", "name": "Barry's Delay", "author": "MenkeTechnologies",
                 "category": "Delay", "tags": ["delay","mod"], "license": "CC0",
                 "host": "zpwr-fx", "desc": "...", "url": "https://.../modules/barrys-delay.zfxmod" } ] }
```

---

## [0x06] BUILD / TEST

Depends only on `juce::juce_core`. Consumers add it via `add_subdirectory` and link `zpwr::patch_core`; the consumer's top-level `CMAKE_OSX_ARCHITECTURES` (default `x86_64;arm64`) propagates here, so the core compiles universal as part of each plugin. The standalone test build below also defaults to universal on macOS. To build the headless test standalone, point at a JUCE checkout:

```sh
cmake -B build -DZPC_JUCE_DIR=/path/to/JUCE
cmake --build build --target PatchCoreTest
build/PatchCoreTest_artefacts/Debug/PatchCoreTest
```

`GlobalModsTest` (built when `juce::juce_audio_basics` is available) covers the global-modulator bus:

```sh
cmake --build build --target GlobalModsTest
build/GlobalModsTest_artefacts/Debug/GlobalModsTest
```

`LatencyTest` covers intra-patch latency alignment: it re-measures every declared block
group delay against the shipping DSP, cross-checks the table against each block's own
description, and proves that a latent branch and a direct branch summed together arrive on
the same sample. `SpectralBakeTest` covers the single-cycle spectral bake (pitch detection,
harmonic resynthesis, band limiting, and the refusal cases).

```sh
cmake --build build --target LatencyTest SpectralBakeTest
build/LatencyTest_artefacts/Debug/LatencyTest
build/SpectralBakeTest_artefacts/Debug/SpectralBakeTest
```

`EuclidMirrorTest` locks the Euclidean rhythm the engine plays to the one the editor
draws: it replays `tests/euclid_golden.txt` through the shipping `euclidean()` and
demands an exact match, and `webui/zpc-euclid-mirror.test.mjs` replays the same file
through the JS port. Either side drifting fails one of the two. `zpc/midi/Euclidean.h`
is JUCE-free, so unlike every target above this one is a plain `add_executable` that
needs no JUCE checkout:

```sh
cmake --build build --target EuclidMirrorTest
build/EuclidMirrorTest tests/euclid_golden.txt   # or: ctest -R EuclidMirrorTest
```

The webui analyzers are plain ESM with their own node tests (no bundler, no package.json):

```sh
node webui/zpc-patch-audit.test.mjs
node webui/zpc-mod-reach.test.mjs
node webui/zpc-sum-map.test.mjs
node webui/zpc-note-safety.test.mjs
node webui/zpc-euclid-mirror.test.mjs
node --test webui/zpc-junction-meter.test.mjs
node --test webui/zpc-command-palette.test.mjs
```

### ASCII string-literal lint

`scripts/lint_ascii_strings.py` rejects non-ASCII bytes inside C++ string / char
literals (they corrupt `juce::String` and the generated docs — comments may keep
any Unicode). The CI workflow that ran it on every push was removed when Actions
were disabled (f571b40103), so enable it locally as a pre-commit hook once per clone:

```sh
git config core.hooksPath .githooks   # blocks commits with non-ASCII string literals
python3 scripts/lint_ascii_strings.py # or run it directly over the source tree
```

---

## [0x07] LAYOUT

| Path | Role |
|------|------|
| `include/zpc/PatchCore.h`   | Patch data, module registry, runtime graph, engine, serialization |
| `include/zpc/ScriptEngine.h`| RT-safe expression VM (the `Expr` module) |
| `include/zpc/WebEditor.h`   | Shared WebView editor backend (catalog/patch/preset/browser native functions) |
| `include/zpc/HostSupport.h` | Soft-knob pool, host state (active count + EZ), BinaryData finder, `MidiInbox` |
| `include/zpc/LayeredEngine.h`| Unlimited layers (each a full engine copy) + per-layer parallel/series bus routing + JSON |
| `include/zpc/ReferenceDoc.h`| Offline reference-page renderer (registry → `docs/reference.html`/PDF) |
| `include/zpc/PresetStore.h` | File-based user-preset CRUD (list/save/load/remove/rename/clone) |
| `include/zpc/GlobalMods.h`  | Shared global-modulator bus (LFOs/envelopes/random + all MIDI/MPE sources) |
| `include/zpc/AudioModules.h`| Float effect pack (Filter/Delay/Reverb/Phaser/Drive/… + the `registerX` calls below) |
| `include/zpc/Wavetables.h`  | Config-driven `Wavetable` oscillator + Serum-style built-in tables |
| `include/zpc/GranularSpectral.h` | `Granular` grain cloud + `Spectral` STFT phase-vocoder oscillators |
| `include/zpc/MoreOscillators.h`  | Susaw/Sampler/Sync/DAHDSR/Glide/Sub/Spire + PMOsc/PhaseDist/Warp/Geiger/FreqShift/Vocoder/PZFilter/PathLFO |
| `include/zpc/Convolution.h` | True IR/convolution reverb (partitioned FFT) + IR audio-file loader (else a generated decay tail) |
| `include/zpc/Multisample.h` | Multi-region `.sfz` sample playback (vel-layer crossfade + round-robin) |
| `include/zpc/SampleLoad.h`  | Host-side audio-file decode into the shared `SampleStore` (Sampler) |
| `include/zpc/SfzLoad.h`     | `.sfz` parser → `MultiSampleStore` regions (Multisampler) |
| `include/zpc/Scala.h`       | Scala `.scl` → per-MIDI-note cents table for synth-voice microtuning |
| `include/zpc/Valhalla.h`    | Plate / Shimmer / FreqEcho space effects |
| `include/zpc/Physical.h`    | Pluck (Karplus-Strong) / Multitap / MSEG |
| `include/zpc/Synthesis.h`   | Modal / LowPassGate / Blown / Bowed / FOF / WaveTerrain / Pulsar / Scanned (synthesis methods) |
| `include/zpc/Traktor.h`     | Barberpole / Mulholland / Bouncer / Beatmasher |
| `include/zpc/Traktor2.h`    | Spinback / Iceverb / PeakFilter / BeatSlicer / ReverseGrain / PeakPhaser / FilterLFO / PeakFlanger |
| `include/zpc/Latency.h`     | Per-block group-delay table + intra-patch latency alignment (longest-path relaxation over `topoOrder`) |
| `include/zpc/dsp/SpectralBake.h` | Freeze a live signal into one band-limited single-cycle wavetable frame (pitch detect → harmonic resynthesis) |
| `webui/zpc-note-safety.js`  | NOTE SAFETY: static hung-note + polyphony-budget prover over a note-stream graph |
| `src/PatchCore.cpp`         | Routing/topo/mod-matrix/eval + core modules + serialization/migration |
| `src/ScriptEngine.cpp`      | Expression VM implementation |
| `tests/PatchCoreTest.cpp`   | Headless unit test |
| `tests/GlobalModsTest.cpp`  | Headless `GlobalMods` test (slot layout, MIDI routing, generated sources) |
| `tests/LatencyTest.cpp`     | Headless latency-alignment test (re-measures the declared delays against the real DSP) |
| `tests/SpectralBakeTest.cpp`| Headless spectral-bake test (pitch detection, resynthesis fidelity, refusal cases) |

---

## [0x08] COMPANION DOCUMENTS

| Document | What |
|---|---|
| [`BLOCKS.md`](BLOCKS.md) | The full deduplicated block catalog and the naming-collision reference. Auto-generated by `scripts/gen_blocks.py` from the registration sites — never edit it by hand, re-run the script |
| [`ANALOG_CIRCUIT_MODELING.md`](ANALOG_CIRCUIT_MODELING.md) | Per-block audit of every `m.analog = true` block: which are true circuit models and which are voiced approximations |
| [`FX_PARITY.md`](FX_PARITY.md) | Every known audio/MIDI effect type mapped against what the registries already ship, so the buildable gaps stay an explicit work list |
| [`SYNTH_PARITY.md`](SYNTH_PARITY.md) | The same analysis for reference-synth features: shipped, portable-and-missing, or not portable |
| [`CPU_OPTIMIZATION.md`](CPU_OPTIMIZATION.md) | DSP CPU work list across the engine and the zpwr-synth host, ordered by value-per-effort with file:line references |
| [`TRAKTOR.md`](TRAKTOR.md) | Transcribed Traktor effect reference, kept as source material for the parity docs |

---

## [0xFF] LICENSE

© MenkeTechnologies. The shared core of the MenkeTechnologies audio stack: [zpwr-fx](https://github.com/MenkeTechnologies/zpwr-fx), [zpwr-synth](https://github.com/MenkeTechnologies/zpwr-synth), [zpwr-midi-fx](https://github.com/MenkeTechnologies/zpwr-midi-fx).
