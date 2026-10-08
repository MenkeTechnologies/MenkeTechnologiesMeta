```
███████╗██████╗ ██╗    ██╗██████╗       ██████╗  █████╗ ██╗    ██╗
╚══███╔╝██╔══██╗██║    ██║██╔══██╗      ██╔══██╗██╔══██╗██║    ██║
  ███╔╝ ██████╔╝██║ █╗ ██║██████╔╝█████╗██║  ██║███████║██║ █╗ ██║
 ███╔╝  ██╔═══╝ ██║███╗██║██╔══██╗╚════╝██║  ██║██╔══██║██║███╗██║
███████╗██║     ╚███╔███╔╝██║  ██║      ██████╔╝██║  ██║╚███╔███╔╝
╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ 
```

![C++](https://img.shields.io/badge/C%2B%2B-20-05d9e8?style=flat-square)
![JavaScript](https://img.shields.io/badge/JavaScript-grid%20engine-ff2a6d?style=flat-square)
![Rust](https://img.shields.io/badge/Rust-bindings-39ff14?style=flat-square)
![Role](https://img.shields.io/badge/role-DAW%20arranger%20engine-d300c5?style=flat-square)
![Video](https://img.shields.io/badge/also-full%20video%20editor-ff2a6d?style=flat-square)
![C ABI](https://img.shields.io/badge/C%20ABI-FFI-05d9e8?style=flat-square)
![Export](https://img.shields.io/badge/export-Type--0%20MIDI-ff2a6d?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-audio%20stack-d300c5?style=flat-square)

### `[ONE GRID ENGINE, N DOMAINS, TWO TRANSPORT BRIDGES]`

> *"One renderer + one interaction model + one value model, bound to a domain."*

### [`Read the Docs`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw) &middot; [`Engineering Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw/report) &middot; [`DAW Features Port Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw/daw_features_port_report) &middot; [`Premiere Port Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw/premiere_port_report)

A standalone **DAW arranger engine** that is **also a full video editor** — a
generalized canvas grid (notes / arranger / automation / triggers / autolanes /
launcher / highway domains, the arranger timeline now carrying **video** clips too),
a pure C++ `ClipEngine` with a swung audio-thread step clock, a C ABI for Rust hosts, and
byte-identical C++/JS MIDI export. Shared across the MenkeTechnologies audio stack.
Created by MenkeTechnologies. See the
[Block Reference](docs/reference.html) ([PDF](docs/reference.pdf)),
the [Engineering Report](docs/report.html), the
[DAW Arranger Port Report](docs/arranger_port_report.html), the
[DAW Features Port Report](docs/daw_features_port_report.html) and the
[Adobe Premiere Pro Port Report](docs/premiere_port_report.html).

# zpwr-daw

A full DAW arranger engine — extracted as a standalone library (formerly
`zpwr-clip-engine`). It started as a per-layer piano-roll pattern sequencer and
grew into a two-view DAW: an **Arrangement** timeline (tracks, clips, sections,
tempo/meter maps, markers, breakpoint automation) and a **Session** clip launcher
(scenes, follow actions), plus MIDI/JSON export and an in-progress JUCE audio-clip
layer. Playback runs on a native audio-thread step clock when the host wires it
(minimise-proof) and falls back to a JS timer otherwise.

Host-agnostic: the engine emits events (notes / CC / audio / bool triggers) and
exposes clip data via `model.serialize()`; **each host binds what an event does** —
MIDI in the synth plugins, trades in traderview, translations in ztranslator,
stryke transforms in Audio-Haxor — and it also runs standalone. See
[`docs/EMBEDDING.md`](docs/EMBEDDING.md) for the seams, and the live coverage
audit in [`docs/arranger_port_report.html`](docs/arranger_port_report.html).

## The first DAW that is also a full video editor

A `video` clip is just another thing the grid arranger carries. Because the
timeline already moves notes and audio along one shared clock, dropping a **video
track type** onto it turned the DAW into a non-linear video editor on the same
canvas — and we then built out the whole Adobe Premiere Pro surface against it
until **no Premiere feature is left uncovered**. The live, citation-backed audit is
[`docs/premiere_port_report.html`](docs/premiere_port_report.html): every feature
names the exact `file:line` in `libs/zpwr-clip-engine/webui` where it lives.

- **edit on the timeline** — video tracks, blade/razor, ripple/insert/overwrite,
  slip/roll/slide/rate-stretch trims, three- and four-point editing from a source
  monitor, JKL shuttle, SMPTE drop-frame timecode, markers, sync/track lock, A/V
  link, multicam.
- **preview** — a program monitor that seeks the playhead frame each tick, pops
  out into a draggable player, with filmstrip thumbnails, safe-margin guides,
  master + per-track VU meters and playback-resolution frame-skip.
- **composite & grade** — Motion/Opacity/Crop/Flip with keyframes + easing, blend
  modes, ellipse/rect/pen masks (keyframable), luma/track-matte/chroma keying,
  adjustment layers, and a Lumetri-style color stack.
- **finish** — titles & Essential Graphics, transitions, optical-flow time
  interpolation, and an FCP-XML / Media Encoder export path.

Every **PORTED** row is a real citation, not a self-assigned score; the two
**PARTIAL** rows are shipped-with-a-limitation rather than missing (native
sample-accurate audio DSP wants a compiled plugin; Productions multi-user wants a
shared-storage sync transport — both are modelled in the webui today). The same
clip+automation timeline that emits MIDI and audio now emits a cut.

## Modular DAW-feature library

The DAW capabilities the arranger and Premiere reports don't cover ship as eight
pure, deterministic, host-agnostic ES modules under `libs/zpwr-clip-engine/webui`,
aggregated by the [`daw-features.js`](libs/zpwr-clip-engine/webui/daw-features.js)
barrel. Each function is unit-tested (`grid/tests/*.test.mjs`, run with
`node --test`); because these are pure data/math with no audible, native, or
hardware component, the test **is** the verification. A host binds them to its own
UI, audio, MIDI-out, or file I/O.

- **mixing console & routing** — VCA/DCA fader groups, selectable pan laws,
  mid-side width, polarity + mono-sum compatibility, pre/post-fader sends, PFL/AFL
  cue-bus modes, orderable/bypassable insert chains, sidechain key routing.
- **MIDI note tools** — partial quantize (strength/swing/ends), humanize (injected
  RNG), scale-lock, strum, chordify, ratchet.
- **automation math** — RDP thinning, LFO-to-envelope bake, curve segment shapes,
  and the read/write/touch/latch/trim mode-merge.
- **tempo/meter math** — musical-position ↔ seconds integration, beat-mapping from
  taps, metronome subdivisions/accents, non-linear tempo ramps.
- **arrangement** — named switchable arrangement alternatives + A/B structural diff.
- **interchange** — SMF import (`.mid` → notes) and Type-1 multitrack export.
- **notation data-model** — enharmonic pitch spelling, key signatures, duration
  decomposition, rests, beaming, transposing instruments, MusicXML serialize.
- **MIDI mapping** — learn/bind table, value-transform math, relative-encoder
  decode, toggle/momentary, macro fan-out, soft-takeover.

Live, citation-backed audit:
[`docs/daw_features_port_report.html`](docs/daw_features_port_report.html) — every
row names its `module:line` and the test that pins it. Live capture, physical
controller I/O, and the audible render stay host-side and are noted per row.

## Modular stereo audio engine (the fully modular DAW)

**The modular claim (INVENTIONS.md #65):** not a fixed channel-strip mixer with a
modular *device* bolted on, but a DAW whose entire signal path is a user-patchable
graph — **every track auto-owns a layer**, each layer is a stereo patch graph
hosting oscillators / FX / plugins, and master / aux / global-mod buses are
themselves patch graphs. Because all of these are the same `zpwr-patch-core` graph,
**every param is a mod-matrix target**: the same block/cable/mod-route model that
routes signal also routes modulation, and the synth panel + mod matrix are
generated from that one patch (not a hand-authored strip). "None found" is owned as
a claim, not proven — see the meta repo's `INVENTIONS.md`.

Every track auto-owns a **layer** (its note/MIDI graph) **and** a **stereo audio
graph** — `zpc::StereoGraph` (`PatchEngineT<StereoSample>`), where **one cable
carries an L/R pair**. It's a separate graph alongside the note-stream MIDI graph
and the mono float graph, shared across all four products (`libs/zpwr-patch-core`):

- **mono FX run in stereo for free** — `wrapMonoAsStereo` runs any of the ~3.5k
  mono blocks once per channel with independent L/R state (no hand-written stereo
  block set). `registerStereoModules` wraps every mono block **except** Oscillators
  (excluded) and the **Plugin** host (already stereo → `registerStereoPluginBlock`,
  a native stereo node, never dual-mono-wrapped).
- **per-track render** — `processBlock` feeds each layer's note output to that
  track's instrument Plugin node, runs the stereo graph for the block, and sums it
  into the master with the layer's **gain · pan (equal-power) · width (mid/side)**.
- **mod → mix** — the global mod control patch (LFOs/envs/MIDI/soft-keys) and each
  layer's own mod routes modulate Master + per-layer Vol/Pan/Width (the GLOBAL MOD
  / LAYER MOD patch-panel tabs).
- **cue + DJ crossfader** — a 2nd stereo **Cue** output for headphone/preview, plus
  an automatable **Crossfade** param: tracks pick an A/B group (`LayerProps.xfade`),
  the main mix crossfades A↔B (equal-power), and **cued** tracks sum to the Cue bus
  at full level independent of the crossfader.

Status: the engine path (graph, wrapper, stereo Plugin host, per-track render, mod,
cue/crossfade) is **compile/link-verified**, and the **in-app editor already exists** —
a 2nd `WebEditor` (namespaced `trk`, bound to the per-track `audioEngine`) drives the
same modular patch panel against a track's stereo graph: `selectTrkGraph(track)` →
`trksetActiveLayer` then `trkaddBlock`/`trksetBlockType`/`trksetBlockParam`/`trkaddCable`
load any of the ~3.5k blocks into that track's `StereoGraph` and wire them. Each track's
**whole** stereo graph (instrument node + FX blocks + cables + mod routes) now
round-trips through save/reload — `tracksToJson`/`restoreTracksFromJson` serialize the
full `PatchDef` per track (`patchToJson`), not just the hosted plugin. It still sums
silence until a track's graph hosts an instrument/source, and the one remaining step is
**not new code** but a **JUCE build + a human listening** to confirm audible output —
autonomous ticks compile-verify the path (they can't hear it).

## Built-in device library (Ableton-style)

Like Ableton Live ships its own devices, zpwr-daw ships a **built-in library of
instruments/effects that are curated graphs of our own zpc DSP blocks** — no
third-party plugins (`ZpwrSynth`/`ZpwrFx`/… are external, not the stdlib). A
**device** is exactly the `factoryPatch` pattern (a `PatchDef` of blocks + real
factory params), authored as data in
[`libs/zpwr-clip-engine/webui/devices/devices.js`](libs/zpwr-clip-engine/webui/devices/devices.js):
**66 devices** across the DAW's **three track types**:

- **Instruments** (MIDI-in / stereo-out) — mono-block synth voices whose source
  block is pitched by the note: Mallet (Modal), Wind (Blown), Strings (Bowed),
  Vocal (FOF), Pluck (Low-Pass Gate), Pulsar, Terrain, Scanned, and a two-block
  source→filter voice. The user opens the device and edits its DSP blocks.
- **Audio FX** (per-track stereo graph) — EQ Eight, Compressor, Reverb, Delay/Echo,
  Auto Filter (Filter swept by an LFO), Saturator, Chorus, Phaser, Redux, Gate,
  Limiter, Vocoder…
- **MIDI FX** (note engine) — Arpeggiator, Chord, Euclidean, Velocity, Random,
  Strum, Ratchet, Humanize…

Each device's default params are the real named presets from
`zpwr-patch-core/BlockPresets.h`, so `deviceToPatch()` emits the exact
`patchToJson` v4 shape the engine loads. Every device is a real, loadable
block-graph, headless-verified (wiring, params, mod routes, JSON round-trip) by
[`grid/tests/devices.test.mjs`](libs/zpwr-clip-engine/webui/grid/tests/devices.test.mjs);
the citation-backed roster is [`docs/device_library_report.html`](docs/device_library_report.html)
(regenerate with `node scripts/gen-device-report.mjs`). Loaded devices get an
editable face from the existing auto-generated patch panel; bespoke zgui-core
device panels and a drag-in browser are the next layer.

```sh
node --test webui/grid/tests/devices.test.mjs
```

## Note-stream generative MIDI engine (`include/zpc/midi/`)

The generative side is a second `zpwr-patch-core` host whose cable signal is a
**note-event stream**, not audio. `NoteStream = std::vector<NoteEvent>` (sorted by
sample offset) is the signal type; every generator/transform is a
`zpc::ModuleInfoT<NoteStream>` node, so the same graph core that runs the audio FX
runs the MIDI FX — dynamic blocks, summed cables, the mod matrix, topo eval,
lock-free edits, JSON, and the shared WebEditor come for free
(`include/zpc/midi/MidiModules.h`). `registerMidiModules(reg, dict)` installs the
23 module bodies (ported verbatim from the former hand-rolled `MidiPatchGraph`);
`defaultMidiPatch()` wires the showcase **Chord → Arp** patch;
`convertLegacyMidiPatch()` upgrades the pre-zpc JSON schema. The note-stream signal
policy is `SignalTraits<NoteStream>`: a cable's stream folds into the slot sum with
note-on velocities scaled by the cable gain (gain ≤ 0 mutes note-ons; note-offs
always pass so nothing hangs).

`NoteEvent` carries `On / Off / CC / Bend / Pressure` plus a `detune` field
(microtuning in semitones → per-channel pitch-bend on output), so the modules
process CC, pitch-bend and channel-pressure in-stream, not just note on/off
(`include/zpc/midi/MidiTypes.h`). `MidiHostCtx` gives every module the per-block
`Transport` snapshot, a deterministic xorshift RNG seed, and the shared
`ChordDictionary` / `ChordEngine`; `MidiNoteState` (one per node) holds each
generator's private DSP state.

The generators:

- **Euclidean** (`Euclidean.h`) — Bjorklund's algorithm distributes `pulses` hits
  as evenly as possible over `steps` slots (with a `rotate` offset), the
  maximally-even rhythm primitive. `E(3,8)` → `x..x..x.` (tresillo), `E(5,8)` →
  `x.xx.xx.` (cinquillo). Also available as the arp's per-step gate overlay.
- **Arpeggiator** (`Arpeggiator.h`) — a stateful note-traversal engine over the
  held pool. Modes: Up / Down / Up-Down / Down-Up / Converge / Diverge / As-Played
  / Random / Chord. Each of up to `kMaxSteps` (16) columns is an `ArpStep` with its
  own enable, velocity, gate (>1 overlaps), transpose, **ratchet** (1..8 sub-hits),
  probability and tie. `ArpParams` adds musical `Division` (straight/dotted/triplet),
  1..4 octave span + octave mode, swing, latch, the Euclidean gate overlay, and
  timing/velocity humanize. `processStep(step, params, rng)` returns `Hit`s carrying
  a step-relative sub-offset and gate length; the clock lives in the host.
- **ChordEngine** (`ChordEngine.h`) — stateless voicing: one input note → a sorted,
  de-duplicated chord with inversion (0..4), sub-octave doubling (0..2), spread
  (0..2), transpose, per-voice strum delay (ms), an optional per-key chord map
  (Chromatic / Circle-of-Fifths / Lowest-Note layout), and an optional scale lock.
  Chord types come from `ChordDictionary` (triads, sixths, sevenths, extended
  9/11/13, suspended, added-tone, altered/jazz, quartal/cluster — count queried at
  runtime via `size()`, never hardcoded).
- **Scale** (`Scale.h`) — a mode catalog (major/minor family, church modes,
  pentatonic/blues, whole-tone/diminished/augmented, Hungarian/Japanese/Egyptian/
  Spanish) plus a `quantize()` that snaps arbitrary notes onto the nearest in-scale
  pitch, driving the arp's scale-locked harmony.
- **Cellular-automata note generators** — three pure `std::uint64_t` cores on an
  8×8 toroidal grid (cell = bit `y*8+x`), each shared between the MIDI module and
  its headless smoke test: **Game of Life** (`GameOfLife.h`, B3/S23), **Brian's
  Brain** (`BrianBrain.h`, ready/firing/dying three-state), and **Langton's Ant**
  (`Langton.h`, turn-flip-move). A read column advances one step per clock, and set
  cells in that column emit notes — non-repeating evolving patterns past a fixed
  step grid. `MidiNoteState` also carries Turing shift-register, Polymeter,
  Counterpoint, Bassline, and Scoop/Fall pitch-bend-sweep state for the rest of the
  23-module pack.

The JUCE bridge is separate (`include/zpc/midi/NoteGraphHost.h`, host-only):
`midiToNoteEvents()` parses a `juce::MidiBuffer` into the stream,
`emitNoteStreamToMidi()` renders a stream back to MIDI (microtuning → per-channel
bend), and `runNoteGraphLayers()` drives every non-muted/solo-respecting layer for
one audio block. `zpwr-midi-fx` sinks the output to MIDI; `zpwr-synth` feeds the
same stream straight into its voices — one translation, no per-host drift.

```sh
cmake --build build --target MidiModulesTest
./build/MidiModulesTest_artefacts/*/MidiModulesTest
```

## Ships three ways

One codebase, three distributions: a **standalone app**, a **VST3 plugin**, and
**embedded inside any GUI app** (audio or not — traderview → trades, ztranslator →
translations, Audio-Haxor → stryke on clips). This is the embeddable-arranger claim
(INVENTIONS.md #64): a *complete* two-view arranger (Arrangement + Session, clips,
breakpoint automation, tempo/meter maps) that runs standalone, as a VST3 inside
another DAW, **and** mounts in an arbitrary host off the same clip/automation
timeline. Honest caveats from the ledger: "None found" is owned, not proven; the
audio render path is written but **unverified pending a JUCE build**; and the
**non-audio** embeds (traderview → trades, ztranslator → translations) are
**aspirational design intent** — those app repos don't yet mount the clip engine.

The closest prior art isn't a clean match: NI **Maschine** is a groovebox tied to
their hardware workflow (by NI's own words, *"never a full DAW"*); **Komplete
Kontrol** is a plugin host, not a DAW; **Tracktion Engine** is a compile-time
library, not a loadable plugin. So a **general-purpose** full DAW arranger that
runs as a plugin *and* embeds in arbitrary GUI apps — including **non-audio** ones
(trades / translations / code off the same clip+automation timeline) — has no
clean dup found. Owned as a claim, *none-found* not proven — see the meta repo's
`INVENTIONS.md`.

It carries these pieces:

| Piece | Path | Role |
| --- | --- | --- |
| Generalized grid engine | `libs/zpwr-clip-engine/webui/grid/` | One canvas renderer + one interaction model + a value model, bound to a `domain`. The FL-Studio-style clip / timeline / arranger grid, host-agnostic. |
| Grid domains | `libs/zpwr-clip-engine/webui/grid/domains/` | Eight bindings: `notes.js` (pitch lanes × step cells, value = note length → the CLIP piano-roll), `arranger.js` (tracks × bars, cells = clip ids → the DAW arrangement; double-click a clip drills into its notes), `automation.js` (macro lanes × 8-bar blocks, value 0..1 → the ALS section-overrides timeline), `triggers.js` (action lanes × time slots, value = bool → the LOGIC view: verified ztranslator rule programs scheduled on the arranger bars, gated on static analysis), `autolanes.js` (MPE/CC lanes → Pitch Bend / CC74 / Channel Pressure as their real MIDI messages), `launcher.js` (scene grid → the Session clip launcher), `highway.js` (keys / pads / drums lanes × steps → the read-only play-along note highway over the same ClipSeq pattern; it renders verdicts and never grades). `requests.js` (request lanes × millisecond ticks → a network run on the arrangement grid: each send is a region, with latency, status class and retry backoff as breakpoint lanes on the same axis).|
| Transport bridges | `libs/zpwr-clip-engine/webui/grid/transport/` | `juce-bridge.js` (`nf` → JUCE `WebBrowserComponent` native fns) and `tauri-bridge.js` (`nf` → Tauri `invoke`). The frontend never knows which host it runs in. |
| Slot sequencer | `libs/zpwr-clip-engine/webui/grid/sequencer.js` | A JS step clock that walks the time axis and fires every set cell per slot (swing-aware). Drives the triggers domain and is the JS-fallback clock for any host without a native engine. |
| Verified logic clips | `libs/zpwr-clip-engine/webui/grid/domains/triggers.js`, `libs/ztranslator-core/src/verify.rs` | Rule programs scheduled as clips on the arranger timeline. A cell carries `{ source, rules }`; the host verifies it live through `zt_invoke("ztr_verify_source", { text, label })` -> `verify::analyze_program` and refuses to arm any clip whose analysis reports a `Severity::Error` finding — dead code, contradiction, tautology, division by zero, infinite loop, broken goto. Warnings and infos do not block. Programs fire as `ClipEvent::Logic` on the same swung step boundary as notes. |
| Session Proof (whole-session verification gate) | `libs/zpwr-clip-engine/webui/clip/session-proof.js`, `libs/zpwr-patch-core/webui/zpc-patch-audit.js` | Lifts the per-clip arm gate to the whole session: one static pass composing every scheduled logic clip's `verify.rs` analysis with the three patch-graph analyzers — Mod Reach (`zpc-mod-reach.js`), Sum Map (`zpc-sum-map.js`) and Patch Audit (`zpc-patch-audit.js`) — into one graded findings report, and refuses to export/render (`clipExportMidi`, `exportProject`) a session with a provable `Severity::Error`. Errors block, warnings/infos allow — `sessionIsRenderable(analysis)` is the session-scope sibling of `program_is_armable`. The Error set is deliberately narrow (a provably-wrong logic program or a summing bus that provably clips) so an over-conservative gate never blocks a valid render. Reachable from the ⌘K palette ("Session Proof") and fired automatically as the export gate. |
| Command palette & automation vocabulary | `libs/zpwr-patch-core/webui/zpc-command-palette.js` | The ⌘K palette over every visible tab and enabled header action (the toolbar `⌘K` button is the reliable trigger inside a plugin host that eats the keystroke). The same list is published on the shared bus via `ZGui.palette.setCommands()`, so each row is also addressable **by id** from a saved `ZGui.userCommands` chain — the ids fill the chain editor's action dropdown and the `zgui:user-command` router resolves them. Ids come from structure, never from a translated label: `tab.<data-pane>` for a tab (`tab.produce`, `tab.ztranslate`, `tab.pdf` are the DAW-only ones), `action.<element-id>` for a header button, and literals for the analyzers (`audit.patch`, `audit.mod-reach`, `audit.sum-map`, `audit.euclid-orbit`, `audit.session-proof`, `terminal.toggle`). The DAW-only tabs reveal themselves after their module boots, so the vocabulary is republished on init, on every open, and right before the router resolves an id. |
| Clip editor command bus | `libs/zpwr-clip-engine/webui/clip/editor-commands.js`, `libs/zpwr-clip-engine/webui/clip/clip-command-palette.js` | The clip editor's own catalog — every registered feature as a `tool` command, plus the video / audio / MIDI / transform / automation / measure / project-tool clip effects — published so each command is addressable **by id**, not only clickable. `publishCommandBus()` registers it wherever the host has somewhere to put it — as typed verbs on `ZGui.automation` where that bus is loaded (zgui-core `automation.js`, now bundled — see **GUI Automation Bus** below; the clip catalog reaches the bus through the vocabulary mirror rather than this call, because a classic script injected after the clip module graph has evaluated arrives too late for it) and as rows in the zpc command vocabulary (`window.zpcRegisterCommands` → `ZGui.palette.setCommands()` → the `zgui:user-command` router), at editor init rather than on first ⌘K, so a saved chain resolves the ids even if the palette is never opened. A verb id is `clip.<surface>.<catalog id>` — structural, never derived from a translated label, and surface-qualified because the bare catalog id is not unique (a scalar feature is both a video effect and a tool). Each verb declares a reversibility class: `tool` / `measure` / `project-tool` only compute, so they are `pure`; a media command with a host `onRun` writes an effect onto the clip with no inverse, so it declares `irreversible` and a transaction refuses it rather than stranding a chain half-undone at abort. Rows are tagged `bulk`, which keeps a four-figure catalog out of the zpc overlay's row list while leaving every id routable — the editor ships its own filtered palette for browsing them, reachable from the zpc palette as one row. Totals are never written down: `commandCount()` / `paletteStats()` derive them from the live catalog. |
| Plugin block picker | `libs/zpwr-patch-core/webui/index.html`, `app/src/PluginEditor.cpp` | A `Plugin` block in the track's audio graph hosts a real VST3 / AU. The card's **⭳ PLUGIN** button calls the `trkloadPluginIntoNode` native function, which opens the host's plugin picker and loads the chosen plugin into that node's `PluginNodeState`. The button renders only where the host wired `EditorConfig::loadPluginIntoNode` — the DAW's audio graph does, the note-stream graph does not. |
| Native-fn coverage gate | `test/webeditor-native-fn-coverage.test.js` | `zpc::WebEditor` registers 154 native functions and never removes one (a registered name is an ABI an out-of-tree host may depend on), so a name nobody calls is indistinguishable from a wiring bug. This test parses the `pfx("name")` registrations out of `WebEditor.h`, parses the frontend bundle list out of `app/CMakeLists.txt`, and asserts every registered name is either called by a bundled file or carries a self-naming `no frontend caller (<name>):` note within 30 lines of its own registration. 9 names are on the explained list — see the table in `libs/zpwr-patch-core/README.md` for each one's reason and consumer. Reachability is decided by the quoted-string-literal test ``/['"`][A-Za-z0-9_]*name['"`]/``, because a caller writes the name verbatim or composes it onto the graph's `uiPrefix` (`"trkgetPatch"`); the looser "is it mentioned" test reports eight, hiding `morphSet` behind an unrelated JS local of the same name in `index.html`. |
| Pure C++ engine | `include/zpc/ClipEngine.h` | JUCE-free pattern model + swung step clock + event queue. Timing/length semantics ported verbatim from the clip.js fallback sequencer. `ClipEvent::Logic` (additive over `NoteOn`/`NoteOff`) schedules verified logic clips via `setLogicClips` on the same timebase. |
| MIDI File export | `include/zpc/MidiFile.h`, `libs/zpwr-clip-engine/webui/grid/export/midi.js` | Renders a pattern to a Type-0 Standard MIDI File — import the sequencer into any compatible DAW (Ableton, FL, Logic, Reaper). Byte-identical C++ and JS exporters. |
| Ableton `.als` import | `libs/zpwr-clip-engine/webui/grid/als-import.js` | Reads an Ableton Live Set (gzip XML) into a project — tracks, clips, MIDI notes, tempo, time signature, arrangement placement, locators, audio-clip paths. Float-time notes (fractional grid-step + exact beat length). Dependency-free XML parser; verified across Live 8.2.1 → Live 12.2. |
| C ABI (FFI) | `include/zpc/capi/clip_engine.h`, `src/capi/clip_engine.cpp` | `extern "C"` surface over `ClipEngine` so Rust hosts drive the same engine the JUCE plugins drive. |
| Rust bindings | `bindings/rust/` | `zpwr-clip-engine-sys` (raw decls, compiles the C ABI via `cc`) + `zpwr-clip-engine` (safe wrapper). |
| Note-stream module pack | `include/zpc/midi/`, `src/midi/` | Chord / Arp / Scale / Euclidean / Game-of-Life / Brian-Brain / Langton + the chord & scale engines, all as `ModuleInfoT<NoteStream>` modules. The MIDI counterpart to the header-only audio pack. |
| Native sequencer glue | `include/zpc/ClipSeq.h` | The `clipSeq*` host contract (`ClipSeqHooks`) + a templated helper that registers the matching native functions on a JUCE `WebBrowserComponent` options builder. |
| CLIP web UI (legacy) | `libs/zpwr-clip-engine/webui/clip/` | The original DOM piano-roll as an ES module (`clip.js` exporting `initClip`). Stays live until consumers cut over to the grid engine (notes domain). |

## GUI Automation Bus (drive the DAW from a stryke script)

The DAW is scriptable **semantically** — by named, typed verbs, not by pixel or keystroke
synthesis. It hosts the same [GUI Automation Bus](https://github.com/MenkeTechnologies/MenkeTechnologiesMeta/blob/main/docs/GUI_AUTOMATION_BUS.md)
the rest of the suite exposes, so one script drives the DAW and the other apps together:

```stryke
use App
val $daw = App::open("zpwr-daw")           # dials $TMPDIR/zgui/zpwr-daw.sock

$daw->call("project.import", %{ text => $als })     # an Ableton Live Set, straight in
$daw->call("track.add", %{ type => "audio" })
$daw->call("clip.video.gaussblur")                  # any clip-editor command, by id
val %verdict = %{ $daw->call("session.proof") }     # the whole-session verification gate
val %lean = %{ $daw->call("session.optimize", %{ project => $zdp }) }   # strip what renders nothing
val %why = %{ $daw->call("session.bisect", %{ a => $yesterday, b => $zdp }) }   # which edits were audible
$daw->on("transportChanged", fn ($t) { p "playing: ${ $t->{playing} }" })
```

| Piece | Path | Role |
| --- | --- | --- |
| Socket host | `app/src/DawBus.h` | The C++ port of the Rust `zgui-bridge` transport: one Unix socket per running app at `$XDG_RUNTIME_DIR/zgui/<app>.sock` (Linux) or `$TMPDIR/zgui/<app>.sock` (macOS), mode 0600, never a network listener. Same newline-delimited JSON frames (`call` / `get` / `verbs` / `sub` → `reply` / `event`), same request/reply correlation, so a client cannot tell a JUCE host from a Tauri one. JUCE-free by construction — POSIX sockets and `<thread>` only — which is what lets the whole protocol be exercised headlessly by `tests/daw_bus_test.cpp` instead of only by launching a plugin host. A connection thread blocks on the webview's answer with a bounded timeout, so a torn-down editor returns an error rather than stranding the client. |
| Editor wiring | `app/src/PluginEditor.cpp` | Opens the endpoint when the editor exists (the surface it dispatches into *is* the WebView), closes it first on teardown. A request is marshalled to the message thread and run through `WebBrowserComponent::evaluateJavascript`; the eval's synchronous return says only whether the dispatcher was installed — the value itself comes back asynchronously through the `zguiBusReply` native function, because a verb may be `async`. Binding can legitimately fail (a second plugin instance, a second editor), and that is not an error worth showing anyone: the DAW is fully usable without automation. |
| Webview surface | `webui/bus/daw-bus.js` | The DAW's typed verbs / state / events, plus the JUCE `invoke` adapter. Nothing is reimplemented: the registry (`ZGui.automation`) and the dispatch shim (`ZGui.automationHost`) are the **shared zgui-core modules the Tauri apps use**, and the shim already took an injected `invoke`, so a JUCE host is a parameter rather than a fork. The two classic scripts are injected by basename from here rather than `<script src>`'d, because the shell `index.html` is shared with zpwr-synth / zpwr-fx / zpwr-midi-fx, which have no bus. |
| Vocabulary mirror | `webui/bus/daw-bus.js` | Wraps `ZGui.palette.setCommands()` — the one call through which the whole app publishes its vocabulary — so **every ⌘K row is also a bus verb**, the clip editor's bulk catalog included. A wrapper rather than a snapshot, so a republish (a tab revealing itself, the catalog growing) lands on the bus too. This is how the clip catalog reaches `ZGui.automation` despite `publishCommandBus()` having already run: its verbs close over editor-private wiring, so re-calling it would register verbs bound to an empty context — worse than none. |

**Reversibility is declared, not guessed.** Every verb carries a `rev` class so a stryke
transaction can refuse or compensate instead of stranding a chain half-applied at abort:
`pure` (computes only), `inverse:<verb>` (undone by naming the compensating verb — e.g.
`transport.play` declares `inverse:transport.stop`), or `irreversible` (writes with no
declared undo). This extends the clip engine's own `pure`/`irreversible` vocabulary
(`clip/clip-command-palette.js` `commandRev`) with the `inverse` case.

**Degrading is explicit.** No native reply channel in a build means the surface registers
*nothing* rather than advertising verbs nobody can reach; Windows has no ported transport
(the Rust host reaches it through a named pipe, which has no C++ standard-library
equivalent) and says so rather than pretending.

Covered by `tests/daw_bus_test.cpp` (real socket, real frames — framing, correlation,
subscription fan-out and pruning, the timeout path, and the endpoint-address convention
the Rust client independently resolves) and `test/daw-bus.test.js` (the surface, the
`invoke` mapping, and the vocabulary mirror, driven against the real shared
`automation.js` / `automation-host.js`).

## Session optimizer (a compiler pass over the arrangement)

`webui/audit/session-optimizer.js` treats a saved project as a **program** and runs the two
classic compiler passes over it — **dead-code elimination** and **common-subexpression
elimination** — then hands back the smallest project that is *proved* to render what the
input rendered. Every other analyzer in this stack is a read-only linter that grades a
session (PATCH AUDIT, MOD REACH, SUM MAP, NOTE SAFETY, VIDEO PROOF, composed by SESSION
PROOF); this is the first one that **transforms** the project, which is why it carries a
proof instead of a verdict.

**The equivalence relation is named, and the optimizer is checked against it.**
`flattenSession(project)` is the semantics: a DOM-free port of the flattener the editor
actually plays (`buildEvents` / `emitInst`, `clip-seq.js`), canonicalised to the audible
render — every note event, every audio voice trigger whose gain is non-zero, every video
placement as a bar span. Two projects are render-equivalent iff those canonical forms are
identical, and `optimizeSession` re-proves that on its own output before returning it: if a
rule is wrong, it hands back the input untouched rather than a project it cannot prove.
A placement's contribution is likewise decided by running that same emitter against that
placement alone — **the reason codes explain a verdict, they never produce one**, so an
audit answer and the render cannot drift apart.

| Verb | Question it answers |
| --- | --- |
| `session.audit` | Which placements, clips and lanes contribute to the render, and why the rest do not (`instance-muted`, `empty-pattern`, `clip-missing`, `audio-gain-zero`, `unplaced-clip`, `no-live-placement`). |
| `session.optimize` | The smallest render-equivalent project, plus every removal and clip merge it made, plus the proof. |
| `session.impact` | What deleting a track / placement / clip would actually change — the exact events lost and the step span they occupied. The inverse of the audit: not "is it dead" but "how much of the mix is this responsible for". |
| `session.equivalent` | Do two projects render identically? (Digest first, then event-by-event with the first difference named.) |

All four are pure functions of a project document, so — like `project.verifyProof` — they
take the project as an argument and need no mounted editor: a script can audit or strip a
`.zdp` the DAW has never opened.

**Where it refuses is the interesting part.** An over-eager pass here silently changes a
mix, so each one is guarded and each guard is pinned by a test that fails if the guard is
removed:

- a dead placement that **defines a clip's bar length** is retained, because the clip's
  length is the max over its placements and a slipped note wraps modulo that length —
  dropping it would move notes on the placements that survive;
- clips with identical patterns are merged **only** when bar length, link group and
  per-clip MIDI effects match too; audio and video clips are never merged, because their
  payload (path, fades, grade, keyframes) is not modelled here;
- a **video** placement is never stripped, muted or not: the picture render is host-side.

**It also reports two semantics that surprise everyone rather than acting on them.** Track
volume 0 does *not* silence MIDI — `emitInst` floors the scaled velocity at 1, so a vol-0
track still plays every note at velocity 1, while a vol-0 *audio* clip is genuinely silent;
that asymmetry ships as a `vol-zero-midi-still-audible` warning. And mute/solo are live
state, not project state: only the per-placement `muted` flag survives a save.

**Prior art, and what is not claimed.** "Find things the project does not use" is old and
shipped everywhere: Reaper's `File > Clean current project directory` lists media files not
referenced by the project, Ableton's File Manager lists **Unused Files** in a Live Set, Pro
Tools' `Select > Unused` + `Clear` empties the clip list of clips not on the timeline. All
three are *asset* cleanup — files or list entries nothing points at — and this module's
`unplaced-clip` reason is exactly that case, labelled as such. Nothing here claims DCE, CSE,
program slicing or graph reachability as inventions either; they are decades old in
compilers. What is not prior art is the combination: contribution analysis of elements that
**are** on the timeline, a named audible-render equivalence relation, a transformation
checked against it, and an impact slice — over an arrangement, a block graph and clip
content that are queryable data rather than an opaque session file.

Pinned by `test/session-optimizer.test.js` — the port is asserted against hand-computed
event lists rather than against itself, each refusal has its own test, and the last one
closes the loop through the clip engine's own SMF encoder, so "renders the same" is checked
as **bytes**. The bus surface is covered in `test/daw-bus.test.js`.

## Session bisect (which of your edits changed what you hear)

`webui/audit/session-bisect.js` points the same relation at a **change**. Give it two saved
projects — yesterday's file and today's, or two adjacent undo snapshots — and it decomposes
the difference into atomic, independently-applicable edits and answers, per edit, whether
the render moved:

| Verb | Question it answers |
| --- | --- |
| `session.diff` | What changed in the render: the exact events added and removed, per channel, each with the bar it lands in **under its own side's grid** (a meter or division change moves the grid, so reporting both sides against one would lie). |
| `session.editScript` | The atomic edits between two projects, one per document location (`transport:divIdx`, `markers@8`, `track:t1:vol`, `clip:c1:gain`, `pattern:c1`, `cell:t1@4`). |
| `session.bisect` | Every edit with its class, the render diff, and the minimal set of edits that reproduces the change. |
| `session.history` | The same over a whole version series — the editor's undo stack is exactly that, up to 80 serialized projects — so "which of the last 80 states actually changed the mix?" is one call. |

**Three classes, and the third is the point.** An edit is `audible` when a probe fires,
`render-neutral` when the render is provably identical with and without it, and
`unmodelled` when it touches a field the flattener never reads. An audio clip's `path` is
the whole sound and none of the relation; a track's `eq`, the transport `bpm` and video
grading are the same. Those are reported as unmodelled with a note saying where the effect
actually lives — **never as neutral**, because a silence is not a proof. The modelled
surface is declared as a manifest with a citation per entry, and the test walks it and
constructs a project pair that moves the digest through each field, so an entry nothing can
falsify would fail the suite.

**Two probes, because one is not enough.** *Solo* applies just this edit; *necessary*
applies everything except it. A new clip pattern and the placement that plays it are each
silent alone and load-bearing together — the solo probe on its own would call both
harmless. An edit declared outside the modelled surface that a probe fires on anyway is
reported as a `manifestViolation`: a bug in the analyzer, not a verdict.

**Prior art, and what is not claimed.** Undo history is universal and is not this: the
Ableton Live 12 manual describes it as "lists all the actions taken since opening a Set and
lets you revert or reapply them up to a specific point", and notes that "the Undo History is
not saved with a Set once it is closed and is refreshed each time the Set is opened" — a
list of action *labels* within one session, with no comparison of two Sets and no statement
about which actions were audible. Reducing a change set to a 1-minimal subset by asking an
oracle is **delta debugging** — `ddmin`, "Reduce `inp` to a 1-minimal failing subset",
attributed to Zeller et al, 2002 (DOI 10.1109/32.988498) — and is not claimed here; the
greedy pass in `minimalCause` reaches the same 1-minimality property without ddmin's
partition schedule. Checking a transformation by comparing denotations is translation
validation, also decades old. And proving two mixes identical by cancelling one against the
other is the engineer's **null test**, which needs two finished renders; this needs none,
runs on the document, and attributes the difference to individual edits.

Pinned by `test/session-bisect.test.js`: hand-computed renders, the refusal cases (an audio
`path` change must never come back neutral), the manifest walk, and 1-minimality re-checked
by removing each kept edit rather than trusting the return value.

## Arranger & clip-engine internals

The transport core is `zpc::ClipEngine` (`include/zpc/ClipEngine.h`) — JUCE-free, a
single header the C ABI compiles. It holds the pattern (`[{s,l,n,len,v}]`) and the
transport, and advances a **swung step clock** whose timing is ported verbatim from
the `clip.js` fallback sequencer so native and JS playback match to the sample:

- **step duration** = `60 / bpm / perBeat` seconds (the grid note division);
- **swing** delays the off-beat half of the swing timebase and shortens the return
  so the cycle length stays constant (`stepDur(i)` = the gap *after* step `i`);
- **note length** is held in steps — a note at step `s` length `L` fires its
  note-off at the top of step `s+L`, matching the editor's held-note countdown.

`advance(seconds)` accumulates dt and fires every step boundary it crosses (with a
runaway-dt guard), queuing `ClipEvent` note-on/off records; a host without an audio
callback pulls them with `pollEvents(out, max)` (the Tauri timer path), while a JUCE
host sequences inside `processBlock`. `renderMidi(repeats)` reuses the pattern +
transport to emit a Type-0 SMF. `setPatternJson()` is a tolerant scanner for the
fixed clip shape (any key order, integer or float); a fractional `.als`-import start
rounds to the nearest step here (the native clock has no sub-step slot — the JS
clock plays it exactly from the `bl` beat-length field).

**Native host contract.** `zpc::ClipSeqHooks` (`include/zpc/ClipSeq.h`) is four
`std::function`s — `pattern` / `transport` / `play` / `step` — and
`registerClipSeqFns()` appends the matching `clipSeq*` native functions onto a JUCE
`WebBrowserComponent` options builder (templated so the header needs only
`juce_core`). `hooks.wired()` drives the page's `hasClipSeq`; a null `play` means no
native sequencer and the page falls back to its JS clock. The audio-thread clock is
immune to the timer throttling browsers impose on minimised/hidden windows — the
"minimise-proof" playback the intro names.

**Audio-clip layer** (`include/zpc/AudioClip.h`, `ClipAudio.h`) — the audio half:
`zpc::AudioClipPlayer` decodes files into clips and streams them as voices inside
`processBlock`, with per-trigger gain, linear + equal-power fades, `rate` repitch
(linear-interp resample), pitch-preserving **WSOLA** time-stretch (cached per
`(handle, ratio)`), ProTools **slip**, and Ableton **warp markers**. `trigger()`
runs on the message thread (any WSOLA pre-render happens there); `process()` runs on
the audio thread; the handoff is a lock-free `juce::AbstractFifo`, and the clip
vector is grow-only so a sounding voice's `shared_ptr` never frees on the audio
thread. The DSP math underneath is factored into JUCE-free primitives
(`include/zpc/AudioDsp.h`): `slipStartSample`, equal-power `crossfadeGains`
(cos/sin), the invertible piecewise-linear `WarpMap` (arrangement ↔ source time),
`wsolaStretch`, and the `CompLane` take-selection model. **Honest status:** those
primitives are headless-verified (`tests/audio_dsp_test.cpp`,
`tests/audio_clip_render_test.cpp` — real WAV decode → trigger → process with
Goertzel/timing assertions), but *subjective audible quality* stays a **GAP** until
the synth's `processBlock` is built and a human hears it. Take **recording** (vs
selection) and warp **capture** need a live audio input and stay host-side gaps.

## Dependencies

zpwr-daw is a **host of `zpwr-patch-core`**, not a peer library. The signal-agnostic
graph core (`ModuleRegistryT` / `RuntimeGraphT` / `SignalTraits` / `PatchEngineT`)
from [zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core) is
vendored as a submodule under `libs/zpwr-patch-core`, and this repo instantiates it
three ways over three signal types: `NoteStream` (the generative MIDI pack), a
mono `float` graph, and `StereoGraph` = `PatchEngineT<StereoSample>` (the per-track
audio). One core, three domains.

The composition below zpwr-daw:

- **`zpwr-patch-core`** — the graph engine + mod matrix + the shared WebEditor and
  patch-panel UI. It in turn vendors:
  - **`zdsp-core`** (`libs/zdsp-core` inside patch-core) — the ~3.5k mono DSP
    blocks + presets that the audio graph and the built-in device library load;
  - **`zgui-core`** (`webui/lib/zgui-core` inside patch-core) — the web UI toolkit
    the grid, patch panel and (planned) device panels render with.
- **`juce_core`** — the only dependency beyond the patch-core stack for the headless
  build; the audio-clip and native-sequencer glue additionally pull
  `juce_audio_basics` / `juce_audio_formats` / `juce_gui_extra` in a JUCE host.

The Rust/C-ABI path (`ClipEngine` + `MidiFile`) needs none of the above — it
compiles the JUCE-free `clip_engine.cpp` directly with `cc`.

```sh
git clone --recurse-submodules https://github.com/MenkeTechnologies/zpwr-daw.git
```

## Build (standalone test)

Point `ZPC_JUCE_DIR` at a JUCE checkout. Standalone builds compile the two graph-core
translation units from the submodule directly, so no separate `zpwr_patch_core` lib is
required; when embedded in a host that already defines `zpwr_patch_core`, this links that
target instead.

```sh
cmake -S . -B build -DZPC_JUCE_DIR=/path/to/JUCE
cmake --build build --target MidiModulesTest
./build/MidiModulesTest_artefacts/*/MidiModulesTest
```

### Reference docs & manual PDF

`docs/reference.html` is the full block reference, generated from the live module registry (the same catalog the UI shows) so it never drifts from the build. `docs/reference.pdf` is the same content paginated for print, built from that HTML.

```sh
# regenerate docs/reference.html from the registry
cmake --build build --target gen_reference
build/gen_reference_artefacts/<config>/gen_reference docs/reference.html
# rebuild docs/reference.pdf (needs pandoc + xelatex) — also refreshes the HTML
scripts/reference_pdf.sh
```

`scripts/reference_pdf.sh` builds the dark screen edition by default. `PRINT=1` builds the print edition instead — the same content re-themed to a white page with a grayscale ramp (KDP bills a `\pagecolor` page at the premium-colour rate) and a 0.9in margin, written to `docs/reference-print.tex` / `docs/reference-print.pdf`; the screen PDF is left untouched. `scripts/print_cover.sh` then wraps that interior in a KDP full-wrap paperback cover (back · spine · front as one 300 DPI sRGB JPEG). The spine width is measured from the interior's page count, so the cover must be rebuilt whenever the interior is:

```sh
PRINT=1 scripts/reference_pdf.sh   # → docs/reference-print.pdf (+ .tex)
scripts/print_cover.sh             # → docs/cover-print.jpg (needs ImageMagick 7 + poppler)
```

`print_cover.sh` reads `INTERIOR` / `OUT` / `EDITION` from the environment if you want to point it at a different interior or output path.

## Embedding in a host

CMake — add this repo as a submodule and link the alias. If the host already adds
`zpwr-patch-core`, add it **before** this so the core lib is reused rather than recompiled:

```cmake
add_subdirectory(libs/zpwr-patch-core)   # the host's own core submodule (optional)
add_subdirectory(libs/zpwr-clip-engine)
target_link_libraries(MyPlugin PRIVATE zpwr::clip_engine)
```

Native sequencer — wire the audio-thread clock and register the JS bridge:

```cpp
#include <zpc/ClipSeq.h>

zpc::ClipSeqHooks clip;
clip.pattern   = [this] (const juce::String& json) { /* parse + stage pattern */ };
clip.transport = [this] (int steps, double bpm, double perBeat, float swing,
                         int swingUnit, bool loop, bool perLayer, int target) { /* … */ };
clip.play      = [this] (bool on) { /* start / stop the processBlock step clock */ };
clip.step      = [this] { return currentStep; };

rootObject->setProperty ("hasClipSeq", clip.wired());        // advertise availability to the page
options = zpc::registerClipSeqFns (std::move (options), clip, pfx);
```

Web UI — load the styles and module, then wire it with the host's helpers:

```js
import { initClip } from "./clip/clip.js";
const clip = initClip({ el, nf, getCAT, getActiveLayer });
clip.buildClip();                       // (re)render the roll, e.g. on tab switch
// keyboard handlers call clip.clipManualKey(true|false); transport calls clip.clipStop()
```

Open `libs/zpwr-clip-engine/webui/clip/demo.html` in a browser to see the legacy roll render against stub host deps.

## Generalized grid engine (`libs/zpwr-clip-engine/webui/grid/`)

One renderer + one interaction model + one value model, bound to a `domain`.
The domain supplies everything that differs (lanes, time-axis cells, value type,
which gestures apply, serialize shape); the engine supplies everything shared
(render loop, hit-test, all gestures, popover bulk-edit, persistence). The merge
detail that matters: `value.type` selects the edit-drag axis — `'length'` →
horizontal right-edge note resize (notes), `'unit'` → vertical top-band value
height (automation), `'bool'` → click toggle (triggers).

```js
import { createGrid } from "./grid/index.js";
import { createNotesDomain } from "./grid/domains/notes.js";
import { createJuceBridge } from "./grid/transport/juce-bridge.js";

const { nf } = createJuceBridge({ prefix: uiPrefix });   // or createTauriBridge()
const grid = createGrid({
    canvas: document.getElementById("clip-grid"),
    domain: createNotesDomain({ getSteps, getPerBeat, layer: 0 }),
    store: localStorage,
    storageKey: "zfx_clip_notes_L0",
    onChange: (model) => nf("clipSeqPattern")(JSON.stringify(model.serialize())),
});
grid.setPlayhead(currentStep);   // drive the playhead column from the transport
```

Domains: `createNotesDomain` (piano-roll, serializes to the `[{s,l,n,len,v}]`
ClipSeq shape), `createAutomationDomain` (ALS lanes, serializes to the Rust
`{param:{bar:value}}` shape, resizable sections), `createTriggersDomain`
(provisional trigger shape, pending the ztranslator contract).

Pure-logic tests (model, domains, layout/hit math) run headless:

```sh
node --test webui/grid/tests/grid.test.mjs
```

## Projects & banks (BROWSE)

A **project** is the whole editable DAW state — every clip's piano-roll pattern,
the arrangement (tracks × bars of clip instances), sections, loops, markers, and
transport — serialized by `libs/zpwr-clip-engine/webui/grid/project.js`
(`serializeProject` / `deserializeProject`) and saved as a **`.zdp`** file. A
**bank** is a named collection of projects (`serializeBank` /
`deserializeBank`), saved as a **`.zpb`** file, so a live set or song folder
travels as one file. Banks hold already-serialized projects, so a bank
round-trips unchanged; entries whose payload isn't a valid project are dropped on
(de)serialization.

`.zdp` / `.zpb` are **gzip-compressed JSON** — JSON compresses ~5-10×, so the
files are deflated (same codec as the C++ preset store, `zpc::jsonfile`). The
WebView compresses via `CompressionStream('gzip')` (raw bytes if unavailable),
and reads auto-detect the gzip magic (`0x1f 0x8b`) so plain/legacy JSON still
loads.

**Importing an Ableton Live Set (`.als`).** The project loader also accepts
`.als` — `.als` is gzip XML, so the same reader decompresses it, sees the
`<Ableton>` root, and routes it through `libs/zpwr-clip-engine/webui/grid/als-import.js`
(`alsToProject`) instead of the JSON path. It brings in tracks, clips, MIDI
notes, tempo, time signature, arrangement placement, locators, and audio-clip
sample paths — the cross-DAW interop Bitwig ships. Devices/plugins, automation
envelopes and audio warping have no target in the clip model and are dropped.
Notes keep their exact time: a fractional start is encoded in the grid-step key
and the exact length in a `bl` (beats) field, so an imported groove is not
quantized to the 16th grid.

The `⛁ BANKS` button on the CLIP toolbar opens the browser
(`libs/zpwr-clip-engine/webui/clip/clip-bank.js`, `createBankBrowser`): a two-column overlay
(BANKS | PROJECTS) that lists banks and their projects, snapshots the open
project into a bank (`+ SAVE CURRENT`), loads a project on click, overwrites
(`⟳`) / renames (double-click) / deletes entries, and imports/exports banks
(`.zpb`) and single projects (`.zdp`). Banks persist in `localStorage`
(`zfx_clip_banks`) between sessions; file save/load uses the host's native
chooser inside JUCE and a browser download/upload otherwise. No host markup is
required — the modal is built on demand, so it works against the shared
patch-core shell unchanged.

```js
import { serializeBank, deserializeBank } from "./grid/project.js";
const bank = serializeBank({ name: 'Live Set', projects: [{ name: 'Opener', project }] });
const back = deserializeBank(JSON.parse(text));   // null if not a zpwr-clip-bank
```

```sh
node --test webui/grid/tests/bank.test.mjs
```

## C ABI + Rust bindings (for Rust hosts)

The pure C++ `ClipEngine` advances a swung step clock and queues note on/off
events; the C ABI (`include/zpc/capi/clip_engine.h`) exposes it to Rust so
Audio-Haxor / ztranslator drive the same engine the JUCE plugins drive. The
`-sys` crate compiles the JUCE-free `clip_engine.cpp` directly with `cc` — no
CMake or JUCE needed for the Rust path.

```rust
use zpwr_clip_engine::ClipEngine;
let mut e = ClipEngine::new();
e.set_pattern(r#"[{"s":0,"l":0,"n":60,"len":2,"v":100}]"#);
e.set_transport(4, 120.0, 4.0, 0.0, 1, /*loop*/ true, /*per_layer*/ false, /*target*/ 0);
e.play(true);
e.advance(0.125);                       // one step at 120 bpm / 1/16
for ev in e.poll_events() { /* route note on/off to the synth */ }
```

```sh
cargo test --manifest-path bindings/rust/zpwr-clip-engine/Cargo.toml
```

C/C++ consumers can instead link the CMake target `zpwr::clip_engine_capi`
(static) or build `-DZPC_BUILD_CAPI_SHARED=ON` for a shared library.

## Export to MIDI (import into a compatible DAW)

Any pattern renders to a Type-0 Standard MIDI File — the universal DAW
interchange format — so the sequencer's output drops straight into Ableton, FL,
Logic, Reaper, etc. One step = one grid cell; `perBeat` is steps-per-quarter
(the clip.js note division); layer → MIDI channel; `repeats` renders the pattern
back-to-back N times. The C++ (`include/zpc/MidiFile.h`) and JS
(`libs/zpwr-clip-engine/webui/grid/export/midi.js`) writers emit byte-identical files.

Rust / native:

```rust
let mut e = ClipEngine::new();
e.set_pattern(r#"[{"s":0,"l":0,"n":60,"len":2,"v":100}]"#);
e.set_transport(4, 120.0, 4.0, 0.0, 1, true, false, 0);
e.write_midi_file("clip.mid", /*repeats*/ 4)?;     // or e.render_midi(4) -> Vec<u8>
```

Web (grid frontend):

```js
import { patternToMidi, downloadMidi } from "./grid/export/midi.js";
downloadMidi(patternToMidi(grid.serialize(), { bpm, perBeat, steps, repeats: 4 }), "clip.mid");
```

C ABI: `zpc_clip_render_midi(engine, repeats, &data, &len)` (free with
`zpc_bytes_free`). The exporters are verified by round-trip parsing in the test
suites (`cargo test`, `node --test webui/grid/tests/midi.test.mjs`).

## Proof-carrying export

SESSION PROOF already composes four analyzers into one graded verdict and refuses to
export a session it can prove misbehaves. That verdict now travels **with the bytes**.

No interchange format carries a machine-checkable claim about the session it encodes —
not SMF, not `.als`, not AAF, OMF or FCP-XML. The receiving tool re-analyses from
scratch or, far more often, does not analyse at all. A **proof seal**
(`libs/zpwr-clip-engine/webui/grid/export/proof-seal.js`) is that claim:

- the graded verdict (renderable + error/warning/info counts + the findings),
- the analysis **input** the verdict came from, in containers with room for it, so the
  receiver re-runs the same pure functions and *confirms* the claim rather than trusting
  it,
- a digest that **binds** the claim to the exact content — a seal cannot be lifted onto a
  different export, and an edited file is detected as unsealed instead of silently
  inheriting a PASS.

Where it rides:

| Export | Carries | Receiver can |
|---|---|---|
| `clip.mid` (SMF) | `FF 06` marker (`ZPWR SESSION PROOF: PASS`, visible in any DAW's marker lane) + `FF 01` text with the seal | verify the claim belongs to these notes, and read the verdict |
| `project.zdp` | the same seal plus the analysis input | additionally **re-derive** the verdict from the carried session |

Verification is bounded by parse time — re-running pure functions over JSON plus one
linear digest pass:

```js
const { ok, reason, recomputed } = clip.verifyProjectProof(project);
```

There is no signature and no key: a seal proves the *integrity of the claim against the
content*, not authorship. Anyone can recompute it, which is the point. Covered by
`node --test webui/grid/tests/proofseal.test.mjs`, which tests every property in both
directions (a forged verdict, a lifted seal, an edited file and a deleted finding are
each rejected with their own reason).

## Interaction parity checklist (regression contract, HANDOFF §2)

The grid engine must preserve every gesture from the ALS timeline it was lifted
from. Verify against this list when touching `grid-interactions.js`:

- paint (left click-drag), cross-lane sweep
- erase (right click-drag), cross-lane sweep; native context menu suppressed
- value-by-height drag (unit) / right-edge length drag (notes)
- scroll fine-tune (±`value.step`)
- shift-click range-select within a lane
- cmd/ctrl-click ramp (anchor → clicked, linear, y = end value)
- multi-select + popover bulk-edit of the whole selection
- boundary-drag region resize with frozen pixel↔unit mapping + ghost preview (automation)
- DPR-correct canvas layout + ResizeObserver reflow; custom cursors
