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

The signal-agnostic **modular patch graph** behind the MenkeTechnologies plugin stack — the cable routing system shared by **zpwr-fx**, **zpwr-synth**, **zpwr-midi-fx**, and **zpwr-daw**. Created by MenkeTechnologies.

### [`zpwr-fx`](https://github.com/MenkeTechnologies/zpwr-fx) · [`zpwr-synth`](https://github.com/MenkeTechnologies/zpwr-synth) · [`zpwr-midi-fx`](https://github.com/MenkeTechnologies/zpwr-midi-fx)

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
for (int i = 0; i < numSamples; ++i)
{
    float ext[N] = { inL[i], inR[i], noise, softKeys..., midi... };
    g->evalSample (timeIndex++, ext, N);
    out[i] = g->sourceValue (g->outputSource (0)) * g->outputGain (0);
}
```

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

`zpc::WebEditor<Engine>` is the WebView backend every host shares (catalog/patch JSON, BinaryData serving, preset I/O, ~30 native functions). Soft knobs are an **expandable pool**: hosts create a fixed ceiling of automatable params up front (`EditorConfig::maxSoftKeys`) and expose the runtime *active* count through `getSoftKeyCount` / `setSoftKeyCount` callbacks; the UI's `+`/`−` controls call the `setSoftKeyCount` native function, which returns a fresh catalog so the source list and knob row rebuild. The first soft knob's source id is `EditorConfig::srcSK0`, and host MIDI/perf sources sit after the whole pool so growing the count never shifts their ids.

**EZ mode** (for beginners): set `EditorConfig::autoWire` to a function that returns the current patch with the standard signal path connected, and the UI shows an **⚡ EZ WIRE** button. `zpc::autoWireChain(patch, inputSource)` is the ready-made chain (input → every block in order → outputs) for linear hosts; a synth supplies its own voice-topology wiring. Param enum labels: a `ParamSpec` with non-empty `names` renders as a labelled dropdown instead of a knob.

**Stereo mode + Stereo Lock** (audio-L/R hosts only — `EditorConfig::getStereoMode` set; gated off for the MIDI fx) — two header toggles that maintain a true-stereo patch from a single editable chain:

- **⊞ STEREO** mirrors the entire graph — every block, cable and mod — into an independent **right-channel** chain. Each clone node *j′ = j + N* references the cloned upstream nodes, reads **In R** where the original reads **In L** (and vice-versa, via `EditorConfig::stereoInL`/`stereoInR`), and feeds **Out R**; **Out L** is left untouched. So a chain starting from one input becomes true L/R stereo; a chain summing L+R stays dual-mono. Clones are tagged with `NodeDef::clone` (serialized in the patch JSON) so the engine always knows which half is which.
- The mirror is **maintained like EZ**: `stereoSync` is folded into the same post-structural-edit hook as `ezRewire`, so adding/removing/retyping a block (or a cable/mod) re-mirrors automatically. EZ runs first (wires the left chain), then the mirror copies it to the right — the two **compose**. Toggling Stereo off calls `stripStereo` (removes the clone nodes, reindexes, back to mono left).
- In plain Stereo the clone **knobs are independent** (preserved across structural syncs) so you can detune L/R for width. **🔒 LOCK** additionally links them: a left-channel `setBlockParam` mirrors to `node + leftCount()` (the clone redraws live in the UI too), and the locked clone blocks render dimmed with a lock badge.
- Engine API (`PatchEngineT`, forwarded through `LayeredEngineT` / a host's voice engine): `stereoize(inL,inR)`, `stripStereo()`, `stereoSync(inL,inR,lock)`, `leftCount()`. Toggle state is `HostState` (`stereoMode`/`stereoLock`, persisted alongside `ezMode`). Native functions: `setStereoMode`, `setStereoLock`, `reconcilePresetModes`.
- **Preset load** never silently transforms a preset: `reconcilePresetModes` turns **EZ off** (don't re-wire hand-authored routing) and **Lock off**, and sets **Stereo on iff the loaded preset actually contains clone nodes** — so the toggles always match the preset you loaded.

**Other editor aids** — **🧬 Mutate** (header) randomises the current patch's continuous params + mod depths within their own ranges (Shift = stronger; mod-depth / enum mutation toggle in SETTINGS); the **preset Morph** XY pad (synth) bilinearly blends four corner snapshots and is always host-automatable via reserved `morphX`/`morphY` params; a **global busy spinner** (Audio-Haxor design, `busy()` overlay) shows during heavy ops (mutate, stereo) instead of a beachball; synth-panel blocks carry a **B1…BN index badge** (their source id in cables/mods); and the synth's first-class **Trigger** mod source (`kSrcTrig`) emits a one-sample impulse on each note-on edge, distinct from the held **Gate**.

**PERFORM tab** — a play surface that drives the host-automatable soft-key macros (each is a real APVTS param via the soft-key relays, so everything below records as host automation):

- **ORB** (Omnisphere-style) — drag the puck: **angle** selects one of 8 randomised scenes (a per-macro offset vector), **distance** from centre scales intensity; 🎲 rolls fresh scenes and jumps to a random one; **⏺ / ▶** record the puck gesture and loop it back, re-applying the recorded motion to the macros.
- **PRESET MORPH** — bilinear blend of four corner presets (host-automatable `morphX`/`morphY`); 🎲 fills all four corners at random (shown behind the `busy()` spinner).
- **XY macro pads** — each drives a pair of soft keys, with a per-pad **HOLD**/**SPRING** release toggle (HOLD leaves the dot, SPRING snaps both axes back to centre); per-pad 🎲 and a global **RANDOMIZE**.
- **SNAPSHOTS** — eight macro-surface snapshots (localStorage): click empty to save, filled to recall, right-click to clear.
- **MIDI IN toggles** — **PROGRAM** (respond to MIDI Program Change) and **BANK** (Bank Select CC0/CC32; `program = (MSB*128+LSB)*128 + PC`); both default ON, persisted in `HostState` (`pgmChange`/`bankSelect`), exposed via `EditorConfig::getPgmChange`/`setPgmChange`/`getBankSelect`/`setBankSelect`, catalog flag `hasMidiProgram`, native functions `setPgmChange`/`setBankSelect`.
- **ARP** — mode / rate / **LATCH** (keep arpeggiating held notes after release; `EngineSettings::arpLatch`, set via `setSetting`).
- **KEY / SCALE** quantize and **CHORD** stacking (Oct/5th/Maj/Min/Maj7/Min7/Sus4/Power — the on-screen keyboard sends the stacked intervals).
- On-screen 3-octave keyboard (drag-glissando) plus spring pitch-bend and mod wheels. Set `EditorConfig::sendMidi` to a sink that injects a `juce::MidiMessage` into the host's block (a `zpc::MidiInbox` in `HostSupport.h` is the thread-safe editor→audio queue); the UI emits `midiNoteOn/Off`, `midiPitchBend`, `midiCC`.

**BROWSE tab** — a SynthMaster-style tag/category preset browser. Presets carry facet tags (`"Facet:Value"`, e.g. `Type:Bass`, `Style:Acid`, `Character:Aggressive`); factory presets get a `Bank:Factory` tag plus `EditorConfig::factoryTags(index)`, user presets store their tags in the saved JSON and get `Bank:User`. Fixed, ordered facet columns named PRODUCT / BANK / AUTHOR / INSTRUMENT TYPE / ATTRIBUTES / STYLES, each led by an `(All)` reset row (multi-select, AND across facets / OR within one); a fuzzy-searched, numbered preset list with per-preset favourite stars (persisted to `favorites.json` via `loadFavorites` / `saveFavorites`), a favourites-only filter and a random-preset button (header 🎲 + browser, the latter respecting the active facet filter); and a structured PRESET DETAILS panel (product, bank, author, description, instrument type(s), attribute(s), style(s)) with author/description/tags editable on user presets. The tag vocabulary + factory tag tables live in `include/zpc/PresetTags.h` (`zpc::fxFactoryTags` / `synthFactoryTags` / `midiFactoryTags` and the canonical `attributeOrder()` / `styleOrder()` / `typeOrder()`), published in the catalog so facet columns order by the canonical taxonomy. Native functions: `getPresetLibrary`, `setPresetTags`, `loadFavorites`, `saveFavorites`; `savePreset` takes an optional tags array.

**Wavetable oscillator + waveform editor** — the `Wavetable` module (`include/zpc/Wavetables.h`) is a config-driven oscillator: its single-cycle frames live in the node's `config` string (`;`-separated frames, `,`-separated −1..1 samples), and the `Position` param morphs between them. zpc ships Serum-style built-in tables (`wavetableNames()` / `builtinWavetable()` → catalog + the `getWavetable` native function). Opening a `Wavetable` block shows a waveform editor: draw on the canvas to reshape the current frame, navigate/add/remove frames, and load a built-in table — all persisted through `setScript` (node config).

**Graphical LFO / envelope editors** — opening an LFO- or envelope-shaped block (detected by its param names: `Shape`+`Rate`, or `Attack`+`Release`) shows a graphical panel above the knobs. The envelope is a draggable SVG ADSR/AR curve (handles write straight to `setBlockParam`); the LFO draws its waveform with the exact DSP shape math, a four-way shape picker, and a `requestAnimationFrame` playhead at the block's rate. Param-driven only — no engine round-trip.

**Colour-scheme editor** — the SETTINGS pane has per-hue colour pickers (accent, cyan, magenta, text, backgrounds, border, …) that recolour the UI live; the glow/dim variants are derived from the base hues. Named custom schemes are saved to a real file, `<userAppData>/<name>/colorschemes.json`, via the `loadColorSchemes` / `saveColorSchemes` native functions (ported from audio-haxor). Built-in schemes still live in the webui.

**Header live meters** — the header shows three host-fed readouts, each polled by the UI and driven by an optional `EditorConfig` callback (absent callback = the readout hides itself): the oscilloscope + 3D spectral waterfall (`getAnalyzer` → `{scope,spectrum}`), the MIDI input LED (`getMidiActivity`), and the **CPU meter** (`getCpuLoad`). `getCpuLoad` returns the realtime DSP load as a fraction of the audio-thread budget (1.0 = the block render used its entire `numSamples / sampleRate` window); the readout shows it as a percentage, amber past 70% and red past 90% (approaching dropout). Hosts measure it with `zpc::CpuMeter` (`include/zpc/HostSupport.h`): bracket `processBlock` with `startBlock()` / `endBlock(numSamples, sampleRate)` and expose `load()` through the callback. A high unison/voice count multiplies per-voice work and is the usual cause of a spike. Lock-free — the audio thread only writes, the UI only reads. A **RAM meter** (`getRamUsage` native function) sits beside it, showing the process resident set size in MB/GB; it defaults to `zpc::processResidentBytes()` (mach on Apple, `/proc/self/statm` on Linux, PSAPI on Windows) so it works with no host wiring, and `EditorConfig::getRamBytes` can override it to report a host-specific figure (e.g. just the sample-bank bytes).

**Log file** — `zpc::WebEditor` owns a `juce::FileLogger` at `<userAppData>/<name>/<name>.log` and writes timestamped lines for editor open, preset save/load and scheme save. The UI can append via the `logUi` native function, read the path with `getLogPath`, and open it in the OS file browser with `revealLog` (the **REVEAL LOG FILE** button under SETTINGS → Diagnostics).

**Global modulators** — `zpc::GlobalMods` (`include/zpc/GlobalMods.h`) is the shared always-available modulator bus: generated sources (3 LFOs, 2 envelopes, Random, Sample&Hold) advanced per block, plus the MIDI-derived set fed from incoming MIDI (mod wheel, pitch bend, channel + poly aftertouch, velocity, note, gate, key-track, expression, breath, sustain, the MPE pressure/slide/bend dimensions, and 8 assignable CC slots), all normalised 0..1. A host copies `value(i)` into its external scalar array and feeds `names()` to the catalog so every plugin exposes the same modulator set.

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
- `spliceInsert` offsets every internal node-output id by the append base (and `ModRoute.node` / `ParamSync.node`); host externals pass through `externalRemap` (null ⇒ identity), a `0` result drops that cable — so a module saved in one host degrades to open inputs in a host that lacks the source.

**Editor + UI.** `WebEditor` adds a second `PresetStore` (full CRUD) and the native functions `listModules` / `saveModule` / `loadModule` / `deleteModule` / `renameModule` / `cloneModule`, plus `fetchRegistry` / `importRegistryModule`. `loadModule` routes through the same undo path as every structural edit (one undoable splice). In the shared WebView UI, **Cmd/Ctrl-click** or **Shift-click** blocks to select, then **◈ MODULES** opens the manager: save the selection, drop saved modules into the patch, or browse the registry.

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

### ASCII string-literal lint

`scripts/lint_ascii_strings.py` rejects non-ASCII bytes inside C++ string / char
literals (they corrupt `juce::String` and the generated docs — comments may keep
any Unicode). It runs in CI (`.github/workflows/lint-ascii.yml`) on every push.
Enable it locally as a pre-commit hook once per clone:

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
| `src/PatchCore.cpp`         | Routing/topo/mod-matrix/eval + core modules + serialization/migration |
| `src/ScriptEngine.cpp`      | Expression VM implementation |
| `tests/PatchCoreTest.cpp`   | Headless unit test |
| `tests/GlobalModsTest.cpp`  | Headless `GlobalMods` test (slot layout, MIDI routing, generated sources) |

---

## [0xFF] LICENSE

© MenkeTechnologies. The shared core of the MenkeTechnologies audio stack: [zpwr-fx](https://github.com/MenkeTechnologies/zpwr-fx), [zpwr-synth](https://github.com/MenkeTechnologies/zpwr-synth), [zpwr-midi-fx](https://github.com/MenkeTechnologies/zpwr-midi-fx).
