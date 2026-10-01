```
███████╗██████╗ ██╗    ██╗██████╗ 
╚══███╔╝██╔══██╗██║    ██║██╔══██╗
  ███╔╝ ██████╔╝██║ █╗ ██║██████╔╝
 ███╔╝  ██╔═══╝ ██║███╗██║██╔══██╗
███████╗██║     ╚███╔███╔╝██║  ██║
╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═╝
███╗   ███╗██╗██████╗ ██╗    ███████╗██╗  ██╗
████╗ ████║██║██╔══██╗██║    ██╔════╝╚██╗██╔╝
██╔████╔██║██║██║  ██║██║    █████╗   ╚███╔╝ 
██║╚██╔╝██║██║██║  ██║██║    ██╔══╝   ██╔██╗ 
██║ ╚═╝ ██║██║██████╔╝██║    ██║     ██╔╝ ██╗
╚═╝     ╚═╝╚═╝╚═════╝ ╚═╝    ╚═╝     ╚═╝  ╚═╝
```

![JUCE](https://img.shields.io/badge/JUCE-8.0.13-ff2a6d?style=flat-square)
![C++](https://img.shields.io/badge/C%2B%2B-20-05d9e8?style=flat-square)
![Formats](https://img.shields.io/badge/VST3%20%C2%B7%20AU%20%C2%B7%20CLAP%20%C2%B7%20Standalone-39ff14?style=flat-square)
![MTAudio](https://img.shields.io/badge/MTAudio-audio%20stack-d300c5?style=flat-square)

### `[MODULAR MIDI EFFECT / GENERATOR]`

> *"A patchable grid of note-stream modules."*

A modular MIDI effect / generator plugin (VST3 · AU · CLAP · Standalone) built on JUCE, with a cyberpunk WebView UI. Created by MTAudio. Part of the MTAudio audio stack alongside [zpwr-synth](https://github.com/MenkeTechnologies/zpwr-synth) and [zpwr-fx](https://github.com/MenkeTechnologies/zpwr-fx).

Where [Xfer Cthulhu](https://xferrecords.com/products/cthulhu) is a fixed chord + arp, zpwr-midi-fx is a **patchable grid of MIDI modules** — the same modular-patch model as zpwr-fx, but the signal flowing between blocks is a stream of note events, not audio. Wire `MIDI In → blocks → Out`, cross-modulate block parameters from a mod matrix, and drive it all from soft keys, LFOs, envelopes and live MIDI/MPE expression. The audio path is pass-through, so it drops in front of any instrument.

### [`zpwr-fx`](https://github.com/MenkeTechnologies/zpwr-fx) · [`zpwr-synth`](https://github.com/MenkeTechnologies/zpwr-synth) · [`zpwr-patch-core`](https://github.com/MenkeTechnologies/zpwr-patch-core)

### [`Read the Docs`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-midi-fx) &middot; [`Engineering Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-midi-fx/report)

---

## Table of Contents

- [\[0x00\] Patch Model](#0x00-patch-model)
- [\[0x01\] Module Library](#0x01-module-library)
- [\[0x02\] Mod Matrix](#0x02-mod-matrix)
- [\[0x03\] Perform & Global](#0x03-perform--global)
- [\[0x04\] Architecture](#0x04-architecture)
- [\[0x05\] Build](#0x05-build)
- [\[0x06\] Test](#0x06-test)
- [\[0x07\] Note Safety (Static Prover)](#0x07-note-safety-static-prover)
- [\[0x08\] Presets](#0x08-presets)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] PATCH MODEL

Built on the shared **[zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core)** (zpc) graph — the same engine as zpwr-fx/zpwr-synth, instantiated on a note-event stream instead of audio samples. A dynamic set of blocks (add/remove/reorder), each with a module type, note-stream inputs + a scalar `Mod` input (unbounded summed cables per slot), up to six parameters, and one output. Inputs select any source; the two outputs (`Out A`, `Out B`) merge to the plugin's MIDI out. The graph is evaluated once per audio block in topological order, and note-offs are scheduled across block boundaries so nothing ever hangs.

An **⚡ EZ WIRE** button auto-wires MIDI In → your blocks → Out A so a beginner gets a working chain without touching cables; an **INIT** button unplugs every cable & mod while keeping the blocks, and **🗑** blanks the whole patch. The **INPUTS** column exposes every patchable source as a jack — the note input, all scalar modulators (Random + performance/MPE controllers) and the soft keys — so anything usable in the mod matrix can be cabled directly into a block.

**Cables** are drawn between jacks and can be dragged to re-patch. Right-click a cable for its editor: a **Level** control (scales note velocity on that connection — `0` mutes it, and cable brightness/width follow the level), a **Colour** swatch, and **Disconnect**. Level is a live tweak; colour is cosmetic and persists with the patch.

Every control has a hover tooltip explaining what it does.

```
MIDI In ─▶ [B1 Chord] ─▶ [B2 Arp] ─▶ Out A ─▶ MIDI Out
```

---

## [0x01] MODULE LIBRARY

**563 note-stream modules** across 11 categories — harmony, sequencing, probability, routing, control sources, dynamics, expression, tuning, MPE/voicing, plus a family of cellular-automaton sequencers (Game of Life, Brian's Brain, Langton's Ant). The table below is a representative selection; `docs/reference.html` lists every block with its inputs and parameters, generated from the live registry so it never drifts.

| Module | What it does |
|--------|--------------|
| **Chord** | one key → a voiced chord (166 types, inversion, spread, octave-double, transpose, strum) |
| **Arp** | host-synced arpeggiator (9 play modes, divisions, gate, octaves, swing) |
| **Scale** | snap every note onto the nearest in-key pitch (20 scales) |
| **Transpose** | shift notes by semitones (modulatable) |
| **Velocity** | scale / offset note velocity (modulatable) |
| **SeqEuclid** | retrigger held notes on a Euclidean rhythm (Bjorklund) |
| **Chance** | per-note probability gate |
| **Harmonize** | stack up to three fixed intervals |
| **Echo** | MIDI delay with feedback (decaying repeats) |
| **Merge** | combine two note streams |
| **MidiLFO** | scalar control source (sine / tri / saw / square) |
| **MidiEnv** | ADSR envelope follower, gated by held notes — a scalar control source |
| **Octave** | add octave-up / octave-down copies |
| **NoteFilter** | pass only notes within a note + velocity range (key zone) |
| **Mono** | collapse to monophonic with note priority (last / lowest / highest) |
| **MidiLatch** | toggle-hold notes — sustain until re-pressed, ignore note-offs |
| **Strum** | spread simultaneous notes in time (up / down) |
| **MidiQuantize** | snap note timing to a grid (rate + strength) |
| **Channel** | remap the output MIDI channel |
| **FixedNote** | force every note to one pitch (drum triggering) |
| **MidiRandom** | clock-driven random-note generator over a range |
| **MidiSampleHold** | sample a scalar source on note triggers — a control source |
| **MidiSlew** | smooth a scalar source — a control source |
| **VelCurve** | reshape velocity through a gamma curve |
| **RandOctave** | randomly shift notes by ± octaves (probability) |
| **Humanize** | jitter note timing and velocity for a played feel |
| **SeqRatchet** | split each note into N rapid retriggers over one division |
| **KeySwitch** | keyboard split — one zone plays, the other holds back |
| **MidiFold** | octave-fold every note into a fixed [low, high] window |
| **NoteLength** | force every note to a fixed gate length |
| **Accent** | boost the velocity of every Nth note (downbeat) |
| **VelClip** | clamp note velocity into a [min, max] window |
| **Invert** | melodic inversion — reflect notes around a pivot |
| **MidiUnison** | layer each note as N copies, optional channel spread (MPE) |
| **Ramp** | velocity crescendo/decrescendo cycling over N notes |

---

## [0x02] MOD MATRIX

A dynamic list of routes, each mapping a **scalar source → any block parameter** with a depth. Sources:

- **Soft Keys** (expandable pool of host-automatable macros, ceiling 32; 16 active by default, `+`/`−` to add/remove, active count saved in plugin state)
- **Auto-param pool** — a reserved pool of 96 `Auto N` host params; right-click any block param to bind it (the Kontakt/Reaktor model), so any module parameter becomes host-automatable / CC-mappable. 32 soft keys + 96 auto params = **128 CC-mappable slots**, one per MIDI CC.
- **LFO** and **Env** block outputs
- **Random**
- **Performance controllers** — Mod Wheel, Pitch Bend, Aftertouch, Velocity, Expression (CC11), Sustain (CC64)
- **MPE** — per-note Bend, Pressure and Slide (CC74), read from the most recently active note's channel

Routing (source / destination) rebuilds the graph; depth is a live, lock-free tweak. The same sources are available on each block's `Mod` input.

---

## [0x03] PERFORM & GLOBAL

**PERFORM tab** — a macros-and-pads view with no patching, for live play:

- **Preset Morph** — a 4-corner XY pad (A/B/C/D) that bilinearly interpolates between four captured presets. Corner snapshots live on the processor; X/Y are reserved host params (`morphX`/`morphY`), so the morph is host-automatable. 🎲 assigns a random preset to all four corners.
- **Orb** — angle picks one of 8 random "scenes" (per-macro offset vectors), distance from centre scales intensity. 🎲 rolls new scenes; ⏺ records orb motion while you drag; ▶ loops the recorded motion. Offsets are applied on top of the macro values captured when the gesture/playback started, and writes go through the soft-key params so they record as host automation.
- **XY macro pads** — each pad drives a pair of soft keys (X/Y). Per-pad **HOLD** keeps the dot where you drop it; **SPRING** snaps both axes back to centre on release. 🎲 randomises a pad's two macros.
- **Macro knobs** — a dial per active soft key.
- **Snapshots** — 8 slots capturing the whole macro surface (per-plugin localStorage); click empty to save, filled to recall, right-click to clear.
- **On-screen keyboard** — global **Key + Scale** quantize of incoming notes and a **Chord** selector (Off / Oct / 5th / Maj / Min / Maj7 / Min7 / Sus4 / Power) that stacks extra intervals on each played key. The control band also exposes a global arp (mode / rate / latch) and a `🎲 RANDOMIZE` of all macro knobs. (midi-fx also has its own per-block `Arp` module with an independent latch — distinct from this global arp.)

**MIDI In response** — `PROGRAM` and `BANK` toggles (both **default ON**): incoming Program Change switches presets, with Bank Select (CC0 MSB / CC32 LSB) captured for the next Program Change. Both are saved in plugin state.

---

## [0x04] ARCHITECTURE

```
libs/zpwr-patch-core/  the shared zpc graph (submodule) + the shared cyberpunk webui
        src/midi/      JUCE-independent note engines (headless-testable)
                       MidiTypes · ChordDictionary · ChordEngine · Scale · Euclidean · Arpeggiator
                       MidiModules — the 563 MIDI modules + note-stream signal policy, on zpc
src/    JUCE plugin shell
        PluginProcessor — APVTS soft keys, MIDI/MPE capture, transport-driven processBlock
                          feeding zpc::PatchEngine<NoteStream>
        PluginEditor    — thin host over zpc::WebEditor (shared catalog/preset bridge)
tests/  dsp_smoke.cpp (engines) · patchgraph_smoke.cpp (zpc graph, modules, JSON)
```

The note modules and the graph have no GUI dependency and are unit-tested without audio hardware or a plugin host. The patch (blocks, routing, mods) is zpc JSON the WebView edits and the plugin persists in its state.

---

## [0x05] BUILD

JUCE 8.0.13 is vendored via CMake `FetchContent` (no system install required).

```sh
cmake -S . -B build
cmake --build build
```

For parity with the MenkeTechnologies desktop apps, a `pnpm` wrapper drives the same CMake build: `pnpm build` (configure-if-needed + Release build), `pnpm dev` (build then launch the Standalone), `pnpm rebuild` / `pnpm clean` / `pnpm bust` / `pnpm nuke` (wipe `build/` + WebView caches and rebuild). The scripts live in `scripts/` and require no Node dependencies. `scripts/build.sh` configures with `-DCMAKE_BUILD_TYPE=Release`, so its artefacts land under a `Release/` config directory.

Build a single format/target instead of all of them:

```sh
cmake --build build --target Zmidifx_Standalone   # or _VST3 / _AU / _CLAP
```

On macOS the default build is a **universal binary** (`x86_64;arm64`) — the VST3/AU/CLAP load on both Intel and Apple Silicon hosts. For a faster host-only dev build, configure a fresh build dir with `-DCMAKE_OSX_ARCHITECTURES=arm64` (the architecture is cached).

`scripts/build_pkg.sh` bundles the built universal VST3/AU/CLAP into a macOS `.pkg` that installs into the system plug-in folders (`/Library/Audio/Plug-Ins/{VST3,Components,CLAP}`) and the Standalone app into `/Applications`; run it after building the `Zmidifx_VST3 Zmidifx_AU Zmidifx_CLAP Zmidifx_Standalone` targets → `dist/zmidifx-<version>.pkg`. Product name, version and bundle id are read from the build tree — nothing is hardcoded.

**Windows:** builds **VST3 + CLAP** (AU is macOS-only, auto-dropped); x64 and ARM64 are separate builds (no universal binary). `scripts/build_win.ps1` configures, builds each arch and stages to `dist\win\<arch>\` — `scripts\build_win.ps1 [-Arch x64|ARM64|both] [-Install]`. Requires Visual Studio 2022 (Desktop C++) + CMake; it installs the `Microsoft.Web.WebView2` NuGet package (needed by the WebView UI via `NEEDS_WEBVIEW2`) if missing. Validate with [pluginval](https://github.com/Tracktion/pluginval) (VST3) and [clap-validator](https://github.com/free-audio/clap-validator) (CLAP).

`COPY_PLUGIN_AFTER_BUILD` is `FALSE`, so the VST3/AU/CLAP are **not** auto-installed into the user plugin folders — copy them manually (or run `scripts/build_pkg.sh`) if you want the host to scan them. To build against a local JUCE clone (offline):

```sh
cmake -S . -B build -DFETCHCONTENT_SOURCE_DIR_JUCE=/path/to/JUCE
```

### Reference docs

`docs/reference.html` is the full module reference — every note-stream block with its inputs and parameters, grouped by category. It is generated from the **live module registry** (the same catalog the plugin's UI shows), so it never drifts from the build. `docs/reference.pdf` is the same content paginated for print, built from that same HTML.

```sh
# regenerate docs/reference.html from the registry
cmake --build build --target gen_reference
build/gen_reference_artefacts/<config>/gen_reference docs/reference.html   # <config> = Release via scripts/build.sh
# rebuild docs/reference.pdf (needs pandoc + xelatex) — also refreshes the HTML
scripts/reference_pdf.sh
```

`scripts/reference_pdf.sh` builds the dark screen edition by default. `PRINT=1` builds the print edition instead — the same content re-themed to a white page with a grayscale ramp (KDP bills a `\pagecolor` page at the premium-colour rate) and a 0.9in margin, written to `docs/reference-print.tex` / `docs/reference-print.pdf`; the screen PDF is left untouched. `scripts/print_cover.sh` then wraps that interior in a KDP full-wrap paperback cover (back · spine · front as one 300 DPI sRGB JPEG). The spine width is measured from the interior's page count, so the cover must be rebuilt whenever the interior is:

```sh
PRINT=1 scripts/reference_pdf.sh   # → docs/reference-print.pdf (+ .tex)
scripts/print_cover.sh             # → docs/cover-print.jpg (needs ImageMagick 7 + poppler)
```

`print_cover.sh` reads `INTERIOR` / `OUT` / `EDITION` from the environment if you want to point it at a different interior or output path.

The renderer (`zpc::renderReferenceHtml`) lives in zpwr-patch-core and is shared by all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw); per-block docs come from each block's `description`/`category` metadata.

---

## [0x06] TEST

```sh
ctest --test-dir build --output-on-failure
```

Coverage: the chord dictionary and voicing engine, scale quantizer, Euclidean generator, arpeggiator traversal, and the full patch graph — routing, pass-through, every module, the mod matrix (soft-key / aftertouch / envelope modulation) and JSON round-tripping.

The NOTE SAFETY prover (below) is pure JS with its own node test:

```sh
node libs/zpwr-patch-core/webui/zpc-note-safety.test.mjs
```

---

## [0x07] NOTE SAFETY (STATIC PROVER)

The note graph is a compiler problem, and nobody in the field treats it as one: Cthulhu,
Scaler, Bome and the Logic / Live MIDI-FX racks ship **no** static analysis. A hung note is
discovered by hearing it, and the industry's answer is a panic button.

NOTE SAFETY proves the defect absent **before playback**, over the whole reachable graph, by
abstract interpretation — the same technique the verified logic clips already use, on a new
domain. It decides two properties from the patch JSON alone, with no engine round-trip:

**1. Hung notes.** A block that can hold a note with no bounded release admits an input
sequence that leaves a note sounding forever, and the prover constructs that witness:

- `Sustain` — engage Hold, play a key, release it, leave Hold engaged.
- `MidiLatch` — strike a key once and stop (the latch releases only when that same pitch is
  struck again).

It is only a defect if the note reaches MIDI Out without passing a block that re-imposes a
bounded gate on **every** path (`StaccatoCut` / `TenutoHold` swallow the incoming note-off and
schedule their own, so they discharge the hold). A note-stream feedback loop reaching MIDI Out
is reported the same way: each block re-injects its own notes, so the count grows without bound.

**2. Polyphony budget.** An interval of simultaneously sounding notes is propagated from the
note inputs through each block's transfer function to the outputs, and compared against a
declared budget. `Chord`, `Harmonize`, `MidiCluster`, `MidiUnison`, `Drone` and `Cascade`
multiply; `NoteLimit` and `MaxPolyphony` are the only blocks that can clamp an unbounded stream
back to a bounded one; `Arp` collapses the held pool to one sounding note.

**Soundness.** Most note-stream blocks are count-preserving, so that is the default — but the
prover does not simply trust its table. It re-derives suspicion from the catalog: a block
carrying a count-shaped parameter (`Voices` / `Max` / `Steps` / `Width` / `Octaves` / …) or
sitting in a note-multiplying category with no modelled transfer drives the count to unbounded
and **reports itself as unmodelled**. A newly added multiplier therefore degrades the proof to
"cannot prove" and says which block did it — it never silently under-counts.

Findings compose into the whole-session SESSION PROOF report exactly like the patch analyzers:
a provable hang or an unbounded loop is an Error (it blocks a render), an unmodelled multiplier
or an unprovable budget is a Warning.

---

## [0x08] PRESETS

A factory bank ships with the plugin (Chord Arp, Strummed Chords, Euclidean Pulse, Fifth Harmonizer, Arp Echo, Random Walk, Step Melody, Tone Cluster, Jazz Voicing, MPE Spread and more) spanning arps, harmony, rhythm, generative and FX chains. User patches are saved as gzip-compressed JSON `zmidifx/Presets/*.zmp` under the user application data directory (data saved before the rename under `zpwr-midi-fx/` is copied across once on first launch, never overwriting a file of the same name) and managed from the PRESETS tab; the BROWSE tab exports/imports a **bank** — a `.zmb` collection of presets — via ⤓/⤒ BANK.

---

## [0xFF] LICENSE

© MenkeTechnologies. Part of the MTAudio audio stack alongside [zpwr-fx](https://github.com/MenkeTechnologies/zpwr-fx), [zpwr-synth](https://github.com/MenkeTechnologies/zpwr-synth), and [zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core).
