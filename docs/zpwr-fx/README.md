# zpwr-fx

A **modular patch effects** plugin built on [JUCE](https://juce.com), in the
spirit of the Eventide H3000 Factory — wire primitive DSP blocks together to
build your own algorithms — wrapped in a cyberpunk WebView UI. Created by
MenkeTechnologies. The audio host for the shared
[`zpwr-patch-core`](../zpwr-patch-core/) engine, alongside
[`zpwr-synth`](../zpwr-synth/) and [`zpwr-midi-fx`](../zpwr-midi-fx/).

## Formats

- **VST3** — cross-platform
- **AU** — macOS (Logic, GarageBand)
- **CLAP** — via [`clap-juce-extensions`](https://github.com/free-audio/clap-juce-extensions)
- **Standalone** — local dev/test app

Targets macOS (arm64/x86_64) + Linux (x86_64/aarch64).

## Architecture

zpwr-fx is **not** a fixed slot rack. It is a free-routed **patch graph** from
`zpwr-patch-core`: modules are wired by selecting each input's source, fan-out and
feedback are allowed (cycles resolve with a one-sample delay), and the graph runs
once per sample frame. The two stereo outputs each select a source.

```
ext In L/R  →  [ Filter ]  →  [ Delay ]  →  …  →  Out
               ↑ mod matrix      ↑ per-cable gain + colour
   (any node → any node; feedback allowed)
```

- **Mod matrix** — every node param has a `(source, depth)` modulation entry.
- **Soft keys** — an expandable pool of automatable, patchable host params.
- **Layers** — each layer is a full engine copy (`zpc::LayeredEngine`); unlimited.
- **⚡ EZ WIRE** — auto-chains In → blocks → Out for linear hosts; full manual
  cabling stays available.
- **JSON patches** with versioning + source-id migration; lock-free live edits
  with an atomic graph swap on structural changes.

## Modules

**250+** audio/synth module types live in the shared registry
(`zpc::buildFxRegistry` / `registerAudioModules` in `zpwr-patch-core`), spanning
dynamics, EQ/filter, delay, reverb, modulation, distortion/saturation, pitch,
spectral (FFT), stereo, lo-fi, and creative/glitch families — plus the RT-safe
`Expr` scripting module that subsumes math/logic/phase primitives. Effect-by-effect
parity against every major DAW + plugin catalog is tracked in `FX_PARITY.md`.
(54 note-stream modules ship in `zpwr-midi-fx` — 300+ DSP blocks stack-wide.)

## Analog models

A dedicated pack of **35** named-circuit analog models (`registerAnalog`) — faithful
generic *topologies*, not sample/IR clones:

- **Synth filters (7)** — Minimoog, Jupiter-8, MS-20, Oberheim SEM, EMS VCS3, EDP
  Wasp, TB-303.
- **Compressors (6)** — Fairchild vari-mu, LA-2A opto, 1176 FET, SSL bus, dbx 160,
  Distressor.
- **EQs (6)** — Pultec EQP-1A, API 550, Neve 1073, SSL E, SSL G, Manley Massive Passive.
- **Preamps & tape (6)** — Neve 1073 pre, API 312 pre, tube console pre, SSL bus glue,
  Studer A800, Ampex ATR-102.
- **Distortion / pedals (7)** — Tube Screamer, RAT, Big Muff, Fuzz Face, Klon, DS-1,
  MXR Distortion+.
- **Phasers (3)** — MXR Phase 90, EHX Small Stone, Uni-Vibe.

## Adding a module

Modules are registered once in `zpwr-patch-core`
(`include/zpc/AudioModules.h`) with an `add (reg, "Name", desc, category, …)`
call and a `compute` callback; the new type then appears in every zpwr-* host that
builds the shared registry. No per-host wiring.

## Build

Requires CMake ≥ 3.22 and a C++20 compiler. Dependencies are vendored as git
submodules (JUCE 8.0.13, `clap-juce-extensions`, and `libs/zpwr-patch-core`).

```sh
git clone --recurse-submodules <repo-url>
cd zpwr-fx
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target ZpwrFX_All -j$(sysctl -n hw.ncpu)
```

Build artifacts land under `build/ZpwrFX_artefacts/`; `COPY_PLUGIN_AFTER_BUILD`
installs them into the user plugin folders.

Private — part of the paid MenkeTechnologies audio stack.
