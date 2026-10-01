```
███████╗██████╗ ██╗    ██╗██████╗ 
╚══███╔╝██╔══██╗██║    ██║██╔══██╗
  ███╔╝ ██████╔╝██║ █╗ ██║██████╔╝
 ███╔╝  ██╔═══╝ ██║███╗██║██╔══██╗
███████╗██║     ╚███╔███╔╝██║  ██║
╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═╝
███████╗██╗   ██╗███╗   ██╗████████╗██╗  ██╗
██╔════╝╚██╗ ██╔╝████╗  ██║╚══██╔══╝██║  ██║
███████╗ ╚████╔╝ ██╔██╗ ██║   ██║   ███████║
╚════██║  ╚██╔╝  ██║╚██╗██║   ██║   ██╔══██║
███████║   ██║   ██║ ╚████║   ██║   ██║  ██║
╚══════╝   ╚═╝   ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝
```

![JUCE](https://img.shields.io/badge/JUCE-8.0.13-ff2a6d?style=flat-square)
![C++](https://img.shields.io/badge/C%2B%2B-20-05d9e8?style=flat-square)
![Formats](https://img.shields.io/badge/AU%20%C2%B7%20VST3%20%C2%B7%20CLAP%20%C2%B7%20Standalone-39ff14?style=flat-square)
![MTAudio](https://img.shields.io/badge/MTAudio-audio%20stack-d300c5?style=flat-square)

### `[FULLY MODULAR SYNTHESIZER]`

> *"The patch is the voice."*

A JUCE software synthesizer by MTAudio — a **fully modular** instrument in the lineage of [VCV Rack](https://vcvrack.com), [Cherry Audio Voltage Modular](https://cherryaudio.com) and [NI Reaktor Blocks](https://www.native-instruments.com): there is no fixed signal path, you build the entire voice by wiring DSP blocks with cables. Builds as **AU**, **VST3**, **CLAP**, and **Standalone** on macOS (Apple Silicon / Intel) and Linux (x86_64 / aarch64).

### [`zpwr-fx`](https://github.com/MenkeTechnologies/zpwr-fx) · [`zpwr-midi-fx`](https://github.com/MenkeTechnologies/zpwr-midi-fx) · [`zpwr-patch-core`](https://github.com/MenkeTechnologies/zpwr-patch-core)

### [`Read the Docs`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-synth) &middot; [`Engineering Report`](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-synth/report)

---

## Table of Contents

- [\[0x00\] Overview](#0x00-overview)
- [\[0x01\] Architecture](#0x01-architecture)
- [\[0x02\] User Interface](#0x02-user-interface)
- [\[0x03\] Soft Keys & Automation](#0x03-soft-keys--automation)
- [\[0x04\] Node Types](#0x04-node-types)
- [\[0x05\] Build, Test & Run](#0x05-build-test--run)
- [\[0x06\] Playing](#0x06-playing)
- [\[0x07\] Roadmap](#0x07-roadmap)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] OVERVIEW

**The whole synth is one modular patch graph.** The graph engine is the shared [**zpwr-patch-core**](https://github.com/MenkeTechnologies/zpwr-patch-core) (`libs/zpwr-patch-core`, a git submodule) — the same signal-agnostic cable-routing core that powers [zpwr-fx](https://github.com/MenkeTechnologies/zpwr-fx). A patch — a grid of DSP nodes wired by per-input source selection — *is* the voice, instantiated across a polyphonic pool.

The default voice is `Osc(Note) → VCA ← Env(Gate)`.

---

## [0x01] ARCHITECTURE

```
ZsynthProcessor (JUCE AudioProcessor)
  └─ zsynth::PolyEngine                 # pool of voices, one zpc::RuntimeGraph each
       └─ zpc::RuntimeGraph (per voice) # the shared core graph, evaluated per sample
            ├─ nodes[N]   each: type + 4 inputs + up to 12 params + 1 output
            │    types: Osc, Wt, Supersaw, FM, Karplus, Additive, Sync, ChordOsc,
            │           HardKick, Screech, Hoover, Reese, Sub, Noise, Sample,
            │           Granular, Env, VCA, Filter, Folder, Waveshaper, Crusher,
            │           Glide, SampleHold, Delay, LFO, RingMod, Drive, Gain, Mixer …
            ├─ external sources fed per voice (id → value, supplied each sample):
            │    In L/R, Noise, Soft Keys (expandable pool), Note, Gate, Velocity, Mod Wheel,
            │    Pitch Bend, Aftertouch, MPE Pressure / Slide / Bend
            ├─ mods[ ]     route list: source → (node, param) × depth
            └─ out L / out R  (each selects a source)
```

The synth-specific node types (`dsp/SynthModules.cpp`, namespace `zsynth`) are a DSP pack registered onto the core registry; the generators (`Osc`, `Wt`, `Sample`, `Granular`) read each voice's `Note`/`Gate` straight from the core's `ComputeContext::external` array, so one patch definition plays polyphonically.

> The DSP module pack and per-voice graph are headless-unit-tested (`tests/synth_modules_test.cpp`: oscillator tuning, ADSR, generators). MIDI/MPE reaches the synth from the host or the standalone's MIDI input.

---

## [0x02] USER INTERFACE

The editor is a **WebView** hosting the **shared zpwr-patch-core cyberpunk patcher** (`libs/zpwr-patch-core/webui`, served from `BinaryData`) — byte-for-byte the same UI zpwr-fx uses: drag-to-patch neon cables (fan-out, feedback, per-cable gain + colour), a dynamic block grid (**+ ADD BLOCK** / delete any number — no fixed node count), double-click a block for its detail modal, and a per-param mod matrix. Panes:

- **PATCH** — the node grid + cable routing + an expandable row of soft-key macro knobs (`+`/`−` to add/remove; 16 active by default). The toolbar carries an **INIT** button (unplug every cable & mod, keep the blocks) and **🗑** (blank the whole patch). An **⚡ EZ MODE** toggle lays down (and keeps) a playable voice — generators(Note) → VCA ← amp Env(Gate), then VCA → Filter (cutoff swept by a second filter Env) → out. While on, oscillators you add are summed straight into the voice; your generator types are kept. Two toolbar toggles drive the stereo image: **Stereo** mirrors every block into a right-channel clone (an independent dual-mono voice per side), and **Stereo Lock** (shown only when Stereo is on) keeps the two channels in sync — moving a knob on either side moves its clone by the *same delta*, so the L/R offset you dialled in is preserved rather than reset, and the mirror is bidirectional (dragging the clone moves the original too).
- **PERFORM** — a play surface with no patching. A **PRESET MORPH** pad bilinearly interpolates between four corner presets (A/B/C/D, host-automatable `morphX`/`morphY` so it runs editor-closed; 🎲 fills all four corners at random). An Omnisphere-style **ORB**: drag the puck where the **angle** selects one of 8 randomised scenes and the **distance** from centre scales intensity, 🎲 rolls fresh scenes, and ⏺ / ▶ record the orb gesture and loop it back (the recorded motion drives the same host-automatable macro params). XY macro pads (each drives a pair of soft keys, per-pad **HOLD**/**SPRING** release: HOLD leaves the dot, SPRING snaps both axes back to centre), a row of macro knobs, eight macro-surface **SNAPSHOTS** (click empty to save, filled to recall, right-click to clear), dice/🎲 **RANDOMIZE** for all macros, **scale/key** quantize + **CHORD** stacking (Oct/5th/Maj/Min/Maj7/Min7/Sus4/Power), and an on-screen keyboard with pitch-bend / mod wheels that follow an external MIDI keyboard's wheels. The control panel also carries the **MIDI IN** toggles (**PROGRAM** = respond to MIDI Program Change, **BANK** = respond to Bank Select CC0/CC32; both default ON) and the **ARP** controls — mode (Up/Down/Up-Down/Random/As-Played), rate (`1/4`…`1/16T`) and **LATCH** (keep arpeggiating held notes after the keys are released).
- **PRESETS** — **256 general factory voices** across **Factory 1 + Factory 2** (128 each; category-prefixed names: `BA` bass, `LD` lead, `PD` pad, `KY` keys, `PL` pluck, `BR` brass, `BE` bell, `ST` strings, `DR` perc, `SEQ`/`FX` etc.) spanning subtractive, FM, additive, supersaw, wavetable, vector, sync and Karplus voices, **plus three genre banks designed from documented production techniques** — an **uplifting `Trance` bank** (stacked supersaw pluck-leads, no-sustain plucks, slow-swell pads, a square-LFO `1/16` trance gate, and saw-LFO sidechain-pumped rolling bass), a **`Hard Techno` bank** (Drumcode-style FM stabs with a 100%-env-swept dirty low-pass and `1/4` resonance LFO, screaming `DiodeLadder` 303 acid, detuned reese/rumble, hoover, and driven lead-bass), and a **`Schranz` bank** (bitcrushed/folded metallic stabs, filtered-noise sweeps and `1/16` gated-noise loops, two-octave siren wails, and distorted hypnotic pulses, ≈160 BPM). Each is generated by an offline tool in `tools/gen_*_bank.cpp` (shared scaffolding in `tools/preset_gen.h`). Every preset carries facet tags (Type / Character / Style / Author / Desc) stored in the preset JSON, so the browser's TYPE / CHARACTER / STYLE / BANK facets are fully populated. Every patch ships with named soft-knob macros plus mod-wheel / velocity routed to its own nodes, so each loads playable. The browser's BANK facet groups presets by their JSON bank name (Factory 1 = 0–127, Factory 2 = 128–255, then Trance, Hard Techno, Schranz). Plus user presets (gzip JSON `.zsp` under `~/Library/zsynth/Presets`; data saved before the rename under `~/Library/zpwr-synth` — presets, user modules, block presets, favourites — is copied across once on first launch, never overwriting a file of the same name and leaving the old directory untouched); the BROWSE tab exports/imports a **bank** — a `.zsb` collection of presets — via ⤓/⤒ BANK.
- **NKS export** — every factory voice can be written as a Native Kontrol Standard `.nksf` preset (RIFF/NIKS container: NISI summary metadata from the facet tags, PLID plugin match, PCHK = the real plugin state, NICA controller page). Each also gets a Komplete Kontrol preview — a 7 s offline render (single sustained C3 + release tail, faded, 44.1 kHz Ogg Vorbis) written to `<bank>/.previews/<name>.nksf.ogg`. Launch the standalone with `ZPWR_EXPORT_NKS=<dir>` to export every factory voice (`.nksf` + previews) into one subfolder per bank (`<dir>/<bank name>/`, e.g. `Factory 1`, `Factory 2`, `Trance`). (NICNT library/controller registration is the remaining step to full hardware browsing.)
- **SETTINGS** — master in/out (dB) + bypass, **Auto Gain Stage** + target, the brickwall limiter, the rest of the audio-engine settings, about.

### Auto gain staging

Two Settings (both **on by default**) keep the signal *between* blocks from clipping no matter how hot the patch-cable gains are, per block, inside every voice graph (and the FX buses):

- **Auto Gain Stage** rides levels — a fast-attack / slow-release peak follower whose smoothed gain (≤ 1) pulls each block toward the **Auto-Gain Target** ceiling.
- **Soft Clip** is the guarantee — an instant (sample-accurate) tanh bound at the same ceiling on every block output, catching the fast transients the AGC's ~2 ms attack would miss. Soft tanh, not a hard clamp, so it saturates gently instead of digitally clipping.

The live cable glow tracks each block's level; turn either off in Settings for raw gain. Shared with zpwr-fx via the same `zpwr-patch-core` engine. Distinct from the master **Brickwall Limiter** (a single hard ceiling on the final output).

---

## [0x03] SOFT KEYS & AUTOMATION

Host-automatable parameters are the **soft keys** (`sk0`…, an expandable pool, ceiling 32; 16 active by default, the active count saved in plugin state), `master_in` / `master_out` / `master_bypass`, **plus a reserved pool of 96 `Auto N` host params** — right-click any block param to bind it (the Kontakt/Reaktor model), so any module parameter becomes host-automatable and CC-mappable. 32 soft keys + 96 auto params = **128 CC-mappable slots**, one per MIDI CC. Everything else lives in the patch (saved as JSON in plugin state). Modulation is the patching itself: any LFO / Env node output or soft key patched into a node input — or mod-routed to a param — is a mod-matrix connection.

---

## [0x04] NODE TYPES

| Node | Role | Key params |
|-------|------|-----------|
| Osc | analog oscillator (note-driven) | wave, octave, fine, PW |
| Wt | wavetable oscillator | table, position, octave, fine |
| Supersaw | 7 detuned saws (JP-8000 style) | octave, detune, mix |
| FM | 2-operator phase-modulation sine | ratio, index, octave |
| Karplus | plucked-string physical model | octave, damping, feedback |
| Additive | summed sine harmonics | partials, rolloff, octave, odd/even |
| Sync | hard-sync sawtooth | tune, sync ratio, octave |
| ChordOsc | one note → 3-note chord of saws | type, octave, detune |
| HardKick | hardstyle/rawstyle kick (gate-struck pitch-sweep + tanh drive) | tune, punch, psweep, decay, click, drive |
| Screech | hardstyle/gabber screech lead (detuned saws → drive → formant BP) | octave, fine, detune, drive, formant, reso |
| Hoover | Alpha Juno "What The" hoover / Mentasm (saw + sawtooth-PWM comb + square sub + note-on pitch sweep) | octave, fine, PWM, chorus, sweep, sweepT |
| Reese | DnB / neurofunk Reese bass (detuned beating saws → LP → drive) | octave, fine, detune, voices, tone, drive |
| Sub | sub-oscillator below the note | octave, wave, level |
| Noise | white/pink noise source | color, level |
| Sample / Granular | sample playback / granular | slot, start/pos, size, rate |
| Env | ADSR (gate-driven) | A, D, S, R |
| VCA | `in1 × in2` (audio × CV) | — |
| Filter | TPT state-variable | cutoff, reso, mode, mod |
| Folder | sine wavefolder (west-coast) | fold, bias, mix |
| Waveshaper | 4-curve shaper | drive, shape, mix |
| Crusher | bit + sample-rate reduction | bits, downsample, mix |
| Glide | portamento on the note CV | time |
| SampleHold | clocked sample-and-hold CV source | rate, glide |
| Vector | 4-source XY-morph oscillator (Prophet-VS) | octave, X, Y, detune |
| DiodeLadder | 4-pole diode-ladder LP (TB-303 grit) | cutoff, reso, mod, drive |
| StepLFO | stepped LFO (stair / random S&H) | rate, steps, shape, smooth |
| NoiseLFO | coloured-noise CV (white/pink/brown) + S&H | rate, color, depth |
| Scaler | scale/offset/curve a CV (waveshaper for mod) | scale, offset, curve |
| Delay / LFO / RingMod / Drive / Gain / Mixer | shaping + modulation | per-type |

Every oscillator (`Osc`, `Wt`, `Supersaw`, `FM`, `Sub`, `Sync`, `Additive`) has a **Voices** (1–11) unison param plus **Detune** (cents) — detuned copies summed and loudness-normalised. `Voices = 1` is the classic mono behaviour, so existing patches are unchanged. A first-class **Trigger** modulation source (a 1-sample impulse on each note-on edge) sits alongside Note / Gate / Velocity for modular-style routing.

### Spectrum bake (`✻ BAKE`, on any `Wt` block)

Serum and Vital resynthesise a wavetable from an **audio file**. Neither can resynthesise from a
node inside its own voice graph, because neither has a patchable graph to tap. Here that tap
already exists: the analyser display and the FFT-behind-envelope read a node's live signal from
`PolyEngine::readScope`, so *freezing what you are looking at* is a capability that only exists
where the graph is user-wired.

`✻ BAKE` on a `Wt` block's detail panel takes the signal currently running at the selected node
and appends it to that block's wavetable as a new frame, in place, while the patch is sounding.
The method is harmonic resynthesis, not a waveform grab
([`zpc/dsp/SpectralBake.h`](https://github.com/MenkeTechnologies/zpwr-patch-core)):

1. estimate the period by normalised autocorrelation with a first-peak octave guard, refined to
   sub-sample resolution by a parabolic fit;
2. measure each harmonic directly at `k*f0` with quadrature correlators over a whole number of
   periods — evaluating at the true harmonic frequency rather than reading the nearest FFT bin
   keeps leakage skirts out of the table permanently;
3. reconstruct one cycle from those harmonics, band-limited at birth (nothing above Nyquist is
   ever synthesised) and peak-normalised, so the frame captures timbre and not level.

Repeated bakes **append** frames (up to 64), so sweeping a filter and baking as you go builds a
morphing table out of the patch's own evolution. A signal with no stable pitch — silence, noise,
a dead node — is **refused** with a reason rather than frozen into a garbage table. Baked frames
live in the same user-wavetable store as imports, so they persist with the patch.

Covered headless by `SpectralBakeTest` in zpwr-patch-core.

---

## [0x05] BUILD, TEST & RUN

JUCE 8.0.13 and clap-juce-extensions are fetched automatically via CMake `FetchContent` — no system install required. The `libs/zpwr-patch-core` submodule must be checked out first.

```sh
git submodule update --init --recursive   # one-time: pull zpwr-patch-core
cmake -B build                            # configure (Unix Makefiles); add -G Ninja for Ninja
cmake --build build                       # build AU + VST3 + CLAP + Standalone
```

For parity with the MenkeTechnologies desktop apps, a `pnpm` wrapper drives the same CMake build: `pnpm build` (configure-if-needed + Release build), `pnpm dev` (build then launch the Standalone), `pnpm rebuild` / `pnpm clean` / `pnpm bust` / `pnpm nuke` (wipe `build/` + WebView caches and rebuild). The scripts live in `scripts/` and require no Node dependencies.

`cmake --build build` builds all three plugin formats (AU/VST3/CLAP) plus the Standalone. Build a single target with `cmake --build build --target Zsynth_Standalone`. Artifacts land under `build/Zsynth_artefacts/<config>/` (`<config>` = `Release`, `Debug`, … per `CMAKE_BUILD_TYPE`; defaults to an unnamed config with Makefiles):

```
build/Zsynth_artefacts/<config>/Standalone/Zsynth.app
build/Zsynth_artefacts/<config>/VST3/Zsynth.vst3
build/Zsynth_artefacts/<config>/AU/Zsynth.component
build/Zsynth_artefacts/<config>/CLAP/Zsynth.clap
```

On macOS the default build is a **universal binary** (`x86_64;arm64`) — the VST3/AU/CLAP load on both Intel and Apple Silicon hosts, matching the "macOS (Apple Silicon / Intel)" claim above. For a faster host-only dev build, configure a fresh build dir with `-DCMAKE_OSX_ARCHITECTURES=arm64` (the architecture is cached).

`scripts/build_pkg.sh` bundles the built universal VST3/AU/CLAP into a macOS `.pkg` that installs into the system plug-in folders (`/Library/Audio/Plug-Ins/{VST3,Components,CLAP}`) and the Standalone app into `/Applications`; run it after building the `Zsynth_VST3 Zsynth_AU Zsynth_CLAP Zsynth_Standalone` targets → `dist/Zsynth-<version>.pkg`. Product name, version and bundle id are read from the build tree — nothing is hardcoded.

**Windows:** builds **VST3 + CLAP** (AU is macOS-only, auto-dropped); x64 and ARM64 are separate builds (no universal binary). `scripts/build_win.ps1` configures, builds each arch and stages to `dist\win\<arch>\` — `scripts\build_win.ps1 [-Arch x64|ARM64|both] [-Install]`. Requires Visual Studio 2022 (Desktop C++) + CMake; it installs the `Microsoft.Web.WebView2` NuGet package (needed by the WebView UI via `NEEDS_WEBVIEW2`) if missing. Validate with [pluginval](https://github.com/Tracktion/pluginval) (VST3) and [clap-validator](https://github.com/free-audio/clap-validator) (CLAP).

`COPY_PLUGIN_AFTER_BUILD` is `FALSE`, so the AU/VST3/CLAP are **not** auto-installed into the user plugin folders — copy them manually if you want the host to scan them.

To build against a local JUCE clone (offline): `cmake -B build -DFETCHCONTENT_SOURCE_DIR_JUCE=/path/to/JUCE`.

### Run (dev)

The Standalone is the dev driver — it hosts the full WebView editor and takes MIDI from any connected input:

```sh
open "build/Zsynth_artefacts/Release/Standalone/Zsynth.app"   # macOS
# or run the binary directly to see stdout/logs:
build/Zsynth_artefacts/Release/Standalone/Zsynth.app/Contents/MacOS/Zsynth
```

Export the full NKS factory banks (every voice + Komplete Kontrol previews) by launching the standalone with `ZPWR_EXPORT_NKS=<dir>` set.

### Test

The tests are headless C++ — no JUCE GUI or audio hardware needed — registered with CTest and runnable in CI on Linux. They cover the per-block DSP module pack (oscillator tuning, ADSR, generators, analog circuit models), the modular voice-pool engine the plugin runs (note on/off + release, unison, polyphony, mono mode, live edits), and validation of every shipped factory voice (each parses, references only registered blocks, wires an output, and renders finite audio).

```sh
cmake --build build                          # builds the test executables alongside the plugin
ctest --test-dir build --output-on-failure   # run the whole suite
ctest --test-dir build -R poly               # run a subset by name regex
```

### Reference docs

`docs/reference.html` is the full node reference — every patchable synth module with its inputs and parameters, grouped by category. It is generated from the **live module registry** (the same catalog the plugin's UI shows), so it never drifts from the build. `docs/reference.pdf` is the same content paginated for print, built from that same HTML.

```sh
# regenerate docs/reference.html from the registry
cmake --build build --target gen_reference
build/gen_reference docs/reference.html
# rebuild docs/reference.pdf (needs pandoc + xelatex) — also refreshes the HTML
scripts/reference_pdf.sh
```

`scripts/reference_pdf.sh` builds the dark screen edition by default. `PRINT=1` builds the print edition instead — the same content re-themed to a white page with a grayscale ramp (KDP bills a `\pagecolor` page at the premium-colour rate) and a 0.9in margin, written to `docs/reference-print.tex` / `docs/reference-print.pdf`; the screen PDF is left untouched. `scripts/print_cover.sh` then wraps that interior in a KDP full-wrap paperback cover (back · spine · front as one 300 DPI sRGB JPEG). The spine width is measured from the interior's page count, so the cover must be rebuilt whenever the interior is:

```sh
PRINT=1 scripts/reference_pdf.sh   # → docs/reference-print.pdf (+ .tex)
scripts/print_cover.sh             # → docs/cover-print.jpg (needs ImageMagick 7 + poppler)
```

`print_cover.sh` reads `INTERIOR` / `OUT` / `EDITION` from the environment if you want to point it at a different interior or output path.

The renderer (`zpc::renderReferenceHtml`) lives in zpwr-patch-core and is shared by all four plugins (zpwr-synth, zpwr-fx, zpwr-midi-fx, zpwr-daw); per-module docs come from each block's `description`/`category` metadata.

---

## [0x06] PLAYING

The editor has an on-screen keyboard at the bottom plus computer-keyboard input: the home/QWERTY rows (`A W S E D F T G Y H U J K …`) play a chromatic octave around C4. Click a key once to give the keyboard focus, then type.

---

## [0x07] ROADMAP

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Build + polyphonic Basic Osc → ADSR → SVF → LFO → mod matrix | done |
| 1 | Wavetable + analog oscillators | `Osc` + `Wt` nodes done |
| 2 | Unlimited layers (full engine copy each) + per-layer parallel/series bus routing | done |
| 3 | Additive, Vector, FM/PM/PD, Ring-mod + Modal/LowPassGate/Blown/Bowed/FOF/WaveTerrain/Pulsar/Scanned | done |
| 4 | Granular oscillator (16 grains), sample playback + `.sfz` multisample + IR loader | done |
| 5 | Preset browser + factory bank + settings + Scala microtuning | done |

SynthMaster 3 reference: up to 16 layers/instrument, 16 modules/layer, 32 mod sources and 6 insert FX per layer, 7 generator types, ~12 synthesis methods.

---

## [0xFF] LICENSE

© MenkeTechnologies. Part of the MTAudio audio stack alongside [zpwr-fx](https://github.com/MenkeTechnologies/zpwr-fx), [zpwr-midi-fx](https://github.com/MenkeTechnologies/zpwr-midi-fx), and [zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core).
