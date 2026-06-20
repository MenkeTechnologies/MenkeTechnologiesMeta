```
███████╗██████╗ ██╗    ██╗██████╗     ███████╗██╗  ██╗
╚══███╔╝██╔══██╗██║    ██║██╔══██╗    ██╔════╝╚██╗██╔╝
  ███╔╝ ██████╔╝██║ █╗ ██║██████╔╝    █████╗   ╚███╔╝ 
 ███╔╝  ██╔═══╝ ██║███╗██║██╔══██╗    ██╔══╝   ██╔██╗ 
███████╗██║     ╚███╔███╔╝██║  ██║    ██║     ██╔╝ ██╗
╚══════╝╚═╝      ╚══╝╚══╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝
```

![JUCE](https://img.shields.io/badge/JUCE-8.0.13-ff2a6d?style=flat-square)
![C++](https://img.shields.io/badge/C%2B%2B-20-05d9e8?style=flat-square)
![Version](https://img.shields.io/badge/version-0.1.14-ff2a6d?style=flat-square)
![Formats](https://img.shields.io/badge/VST3%20%C2%B7%20AU%20%C2%B7%20CLAP%20%C2%B7%20Standalone-39ff14?style=flat-square)
![MenkeTechnologies](https://img.shields.io/badge/MenkeTechnologies-audio%20stack-d300c5?style=flat-square)

### `[MODULAR PATCH EFFECTS]`

> *"Wire your own algorithm."*

A **modular patch effects** plugin built on [JUCE](https://juce.com), in the spirit of the Eventide H3000 Factory — wire primitive DSP blocks together to build your own algorithms — wrapped in a modern cyberpunk WebView UI. Created by MenkeTechnologies.

### [`zpwr-synth`](https://github.com/MenkeTechnologies/zpwr-synth) · [`zpwr-midi-fx`](https://github.com/MenkeTechnologies/zpwr-midi-fx) · [`zpwr-patch-core`](https://github.com/MenkeTechnologies/zpwr-patch-core)

---

## Table of Contents

- [\[0x00\] Overview](#0x00-overview)
- [\[0x01\] Formats](#0x01-formats)
- [\[0x02\] The Patch Model](#0x02-the-patch-model)
- [\[0x03\] Soft Keys](#0x03-soft-keys)
- [\[0x04\] Modules](#0x04-modules)
- [\[0x05\] The Expr Module](#0x05-the-expr-module)
- [\[0x06\] User Interface](#0x06-user-interface)
- [\[0x07\] Perform & Stereo](#0x07-perform--stereo)
- [\[0x08\] Presets](#0x08-presets)
- [\[0x09\] Build](#0x09-build)
- [\[0x0A\] Tests](#0x0a-tests)
- [\[0x0B\] Key Files](#0x0b-key-files)
- [\[0x0C\] Adding a Module](#0x0c-adding-a-module)
- [\[0x0D\] Known Limitations](#0x0d-known-limitations)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] OVERVIEW

The plugin is a **patch graph**: a dynamic set of DSP **blocks** (add or delete any number — there is no fixed node count, the practical limit is CPU) wired together by selecting each input's source. The two stereo outputs (Out L/R) are summing buses — drag any number of cables into each and they mix, exactly like a block input. The whole graph runs once per sample frame (mono blocks; stereo only at the In/Out nodes), so feedback and cross-modulation behave like a hardware patch.

```
INPUTS            BLOCKS (add/delete any N)     OUTPUTS
 In L ─┐     ┌─[B1 Filter]─┐                    Out L ◀─ B2
 In R  ├────▶│   In/Mod    │──▶[B2 Delay]──▶    Out R ◀─ B3
 Noise─┘     └─[B3 LFO]────┘   (feedback)
 SK1..N (soft keys, expandable, automatable, patchable as modulation)
```

The block palette is the shared audio module pack from
[`zpwr-patch-core`](https://github.com/MenkeTechnologies/zpwr-patch-core) —
**918 audio blocks** (1033 total across the audio/synth/MIDI stack, every name
globally unique). Any block type can be dropped into any node.

---

## [0x01] FORMATS

- **VST3** — cross-platform
- **AU** — macOS (Logic, GarageBand)
- **CLAP** — via [`clap-juce-extensions`](https://github.com/free-audio/clap-juce-extensions)
- **Standalone** — local dev/test app

Platforms: **macOS** (ARM + Intel; the default build is a universal binary) and **Linux** (x86_64 / aarch64). Windows builds VST3 + CLAP (AU is macOS-only and is dropped automatically).

---

## [0x02] THE PATCH MODEL

- **Sources** an input can read: silence, In L, In R, Noise, the Soft Keys, **MIDI/MPE** (Mod Wheel, Aftertouch, Pitch Bend, Velocity, Expression, Breath, Sustain, Note, and MPE Press/Slide/Bend), or any block's output (`src id = 100 + blockIndex`). The plugin accepts MIDI input; MPE is parsed via `juce::MPEInstrument` and aggregated to the most recent note.
- Each block has three inputs (**In 1, In 2, Mod**), six params, and one output.
- The graph is **topologically sorted** each rebuild; cycles (feedback) resolve with a one-sample delay automatically — wire any output back to an earlier input to build feedback patches.
- Any source can fan out to **unlimited destinations**.

### Patching the cables

- **Drag** an output jack to an input jack to wire it; drag an input away to disconnect; drop on a different output to rewire.
- **Right-click** a cable for its **level** (per-cable gain) and **colour**. The cable's brightness tracks its level.

### Mod matrix

Every block param has a **mod source + depth** (detail panel → MODULATION). Any source — LFO, Envelope, Soft Key, Noise, or another block — modulates the param by `source × depth` (in param units). Mod sources are part of the dependency graph, so modulating a param with a block's output is topologically ordered like any other connection.

---

## [0x03] SOFT KEYS

JUCE's parameter list must be static for host automation. So the **host-automatable params are the Soft Keys + Master In/Out/Bypass**; the patch itself (block types, routing, block params) is plugin state the UI edits and the plugin persists. The Soft Keys are an **expandable pool** — a fixed ceiling of host params is created up front, and the `+`/`−` controls above the knob row set how many are active (16 by default); the active count is saved with the plugin state. Soft keys are patchable as modulation sources — exactly the H3000 model. Editing is lock-free: atomic param writes for live tweaks, an atomic graph swap on structural edits.

---

## [0x04] MODULES

The block palette is the shared **audio module pack** registered on the core by `zpc::registerAudioModules` (re-exported as `zfx::registerAudioModules` in `src/dsp/AudioModules.h`). It is **918 audio blocks** — filters, delays, reverbs, distortions, dynamics, modulation, oscillators, utility math, sequencers, and a large circuit-modeled set (component-level analog emulations: zero-delay-feedback ladders/SVFs, Shockley-diode and Ebers-Moll clippers, Koren triode/EL34 amp stages, Jiles-Atherton tape, Lambert-W wavefolder, four-diode ring mod). Catalog and counts are kept in [`zpwr-patch-core/BLOCKS.md`](https://github.com/MenkeTechnologies/zpwr-patch-core/blob/main/BLOCKS.md), regenerated from the registration sites — never hand-typed here so they never drift.

The authoritative per-block reference (inputs + parameters, grouped by category) is `docs/reference.html` / `docs/reference.pdf`, generated from the live module registry — see [§0x09 Build → Reference docs](#0x09-build).

A few of the building blocks:

| Module | Params | Notes |
|--------|--------|-------|
| Gain   | Gain, Bias | |
| Mixer  | In 1, In 2, Mod Amt, Offset | sums all three inputs + DC |
| Filter | Cutoff, Reso, Mode (LP/HP/BP), Mod (oct), Drive, Mix | Mod input sweeps cutoff |
| Delay  | Time, Feedback, Mod, Damp, Mix | damped feedback, time-mod |
| LFO    | Rate, Shape (sin/tri/saw/pulse), Depth, Phase, Bias, Width | control source |
| Drive  | Drive, Output, Bias, Tone, Mix, Type (tanh/fold/clip) | |
| Expr   | P0..P5 + **code** | user-written per-sample algorithm |
| Envelope   | Attack, Release, Gain | follower → control |
| Ladder     | Cutoff, Reso, Mod, Drive | Moog 4-pole resonant low-pass |
| Comb       | Freq, Feedback, Damp, Mix | tuned resonator / karplus |

---

## [0x05] THE EXPR MODULE

`Expr` blocks run a user-written per-sample expression compiled by an in-house RT-safe VM (`src/dsp/ScriptEngine.*`). It can do things the fixed blocks can't, and it's edited live in the block's detail panel.

- **Vars:** `in` (In 1), `t`, `sr`, `p0..p7` (p0–p5 = knobs, p6 = In 2, p7 = Mod), `s0..s3` (persistent state), `pi tau e`.
- **Funcs:** `sin cos tan tanh … floor frac wrap saw sqr tri min max pow fmod clamp lerp if step noise rand`, and **`tap(d)`** — the block's own output `d` samples ago (fractional) for combs / karplus / feedback.
- Safe by construction: no loops, allocation, or memory access in the hot path; output is sanitized (NaN/Inf → 0); over-limit programs fail to compile.

Example wavefolder: `out = sin(in * (1 + p0 * 8) * pi)`

---

## [0x06] USER INTERFACE

A JUCE 8 `WebBrowserComponent` rendering an embedded cyberpunk UI (the strykelang neon theme: cyan/magenta on near-black, Orbitron + Share Tech Mono, grid + CRT scanlines), self-contained via `juce_add_binary_data` (no node build, no external files). The UI is shared with zpwr-synth and zpwr-midi-fx; the tab set:

- **Patch** — drag an output jack onto an input jack to wire it (drag an input away to disconnect); an **⚡ EZ WIRE** button (auto-wires In L → your blocks → Out L/R so a beginner gets sound without touching cables), an **INIT** button (unplug every cable & mod, keep the blocks), **🗑** (blank the whole patch), the **Stereo** / **🔒 LOCK** toggles (see §0x07), the soft-key strip, the sources / blocks / outputs grid with SVG cables, and a detail panel (params + code) for the selected block. Cables glow with each source block's live signal level, so the gain structure between blocks is visible while you patch.
- **Synth** — a fixed-layout panel showing every module's knobs in a grid, no cables (Serum/Spire-style).
- **Perform** — macros + XY pads only, no patching (see §0x07).
- **Clip** — draw a MIDI pattern and play it (with key/scale, key-trigger).
- **Mod Matrix** — every modulation connection in one list.
- **Mixer** — per-layer channel strips (gain / pan / mute / solo) with sends to the aux FX buses, the aux returns, and the master strip, with peak + LUFS metering.
- **Browse** — search, save, tag and load patches; filter by bank, type, style, character.
- **Settings** — Master In/Out + Bypass, **Auto Gain Stage** + target, the brickwall limiter, **MIDI Program Change / Bank Select** toggles (see §0x07), scale-key/scale quantize, UI scale, interface toggles.
- **About** — version + engine info.

### Auto gain staging

Stacked patch-cable gains and fanned-in summing buses make it easy to drive the signal *between* blocks far past 0 dBFS, which clips. Two Settings (both **on by default**) handle it, per block:

- **Auto Gain Stage** rides levels: each block's output runs through a fast-attack / slow-release peak follower whose smoothed gain (≤ 1) pulls the block down toward the **Auto-Gain Target** ceiling, so stages stay sanely staged.
- **Soft Clip** is the guarantee: an instant (sample-accurate) tanh bound at the same ceiling on every block output. The AGC's ~2 ms attack can let a fast transient slip over before it ducks, and cable gains apply downstream of the staging — Soft Clip catches all of it, smoothly, so nothing digitally clips between blocks. It's a soft tanh, not a hard clamp, so it saturates gently rather than adding harsh clipping.

Both are per block, so each stage is independent; the live cable glow tracks each block's level. Turn either off in Settings for raw gain. MIDI-effect blocks carry no audio level, so neither applies there. Distinct from the master **Brickwall Limiter**, a single hard ceiling on the final summed output.

---

## [0x07] PERFORM & STEREO

### Perform tab

A play-the-patch surface that drives only host-automatable params, so it works editor-closed and records as automation:

- **Preset Morph** — a 4-corner XY pad (A/B/C/D) that bilinearly interpolates between four captured patches; the corner snapshots live on the processor, X/Y are reserved host params (`morphX`/`morphY`), and a **🎲** assigns a random preset to all four corners.
- **Orb** — a radial pad where the puck's *angle* selects a scene and *distance* sets its intensity; **🎲** rolls a new random scene set, **⏺** records the puck's motion, and **▶** loops the recorded motion back through the host-automatable params (so a hands-free performance gesture becomes automatable param moves).
- **XY macro pads** — each with a per-pad **HOLD** / **SPRING** toggle (spring snaps back to centre on release).
- **Macro knobs** — the soft knobs surfaced as plain 0..1 APVTS params.
- **Scenes** — snapshot slots: click to recall, right-click to clear.
- **Controls band** — global dice/randomise, arp (mode / rate / latch), and **scale + key quantize** plus a **Chord** that stacks extra intervals on each key played on the on-screen keyboard.

### Stereo mode + Stereo Lock

- **Stereo** (off by default) mirrors the patch graph to the right channel, so blocks process L/R independently.
- **🔒 Lock** keeps the mirrored (clone) blocks tracking the left channel. It is **bidirectional and offset-preserving**: dragging a left knob moves its clone — and dragging a clone moves the left — each by the same delta, so the L/R offset (the width you dialled in plain Stereo) is preserved rather than reset. Set `🔒 LOCK` on for a perfect `L = R`. Both states persist in plugin state.

### MIDI Program Change / Bank Select

Both toggles default **on** (`PluginProcessor.cpp`):

- **Program Change** — an incoming PC selects the matching program (preset). Turn off to ignore PC.
- **Bank Select** — CC0 (MSB) / CC32 (LSB) are captured and combined with the next PC (`bank × 128 + program`) for banked preset addressing. Turn off and PCs address program 0..127 directly.

---

## [0x08] PRESETS

- **Factory** (in code): Stereo Slap, Filter Sweep, Comb Resonator, Wavefolder.
- **User** patches save as JSON (`patch` + soft-key values) under `<userAppData>/zpwr-fx/Presets/*.zfxpatch` (e.g. `~/Library/zpwr-fx/Presets`).
- The full plugin/host state (patch + all params) round-trips through JUCE's `get/setStateInformation`.

---

## [0x09] BUILD

CMake ≥ 3.22, a C++20 compiler. Dependencies are vendored git submodules (JUCE 8.0.13, `clap-juce-extensions`).

```sh
git clone --recurse-submodules <repo-url>
cd zpwr-fx
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target ZpwrFX_All -j$(sysctl -n hw.ncpu)
```

Already cloned without submodules: `git submodule update --init --recursive`. Launch the standalone: `open "build/ZpwrFX_artefacts/Debug/Standalone/ZpwrFx.app"`.

On macOS the default build is a **universal binary** (`x86_64;arm64`) — the VST3/AU/CLAP load on both Intel and Apple Silicon hosts. For a faster host-only dev build, configure with `-DCMAKE_OSX_ARCHITECTURES=arm64` (re-use a fresh build dir, since the architecture is cached).

### Installer package

`scripts/build_pkg.sh` bundles the built universal VST3/AU/CLAP into a macOS `.pkg` that installs into the system plug-in folders (`/Library/Audio/Plug-Ins/{VST3,Components,CLAP}`) and the Standalone app into `/Applications`. Product name, version and bundle id are read from the build tree — nothing is hardcoded.

```sh
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --target ZpwrFX_VST3 ZpwrFX_AU ZpwrFX_CLAP ZpwrFX_Standalone -j$(sysctl -n hw.ncpu)
scripts/build_pkg.sh        # -> dist/ZpwrFx-<version>.pkg
```

### Windows

Windows builds **VST3 + CLAP** (AU is macOS-only and is dropped automatically). There is no universal binary on Windows — x64 and ARM64 are separate builds. `scripts/build_win.ps1` configures and builds each requested arch and stages to `dist\win\<arch>\`. Requires Visual Studio 2022 (Desktop C++ workload) + CMake; it installs the `Microsoft.Web.WebView2` NuGet package (needed by the WebView UI via `NEEDS_WEBVIEW2`) if missing.

```powershell
scripts\build_win.ps1                 # x64 + ARM64 -> dist\win\<arch>\
scripts\build_win.ps1 -Arch x64       # single arch
scripts\build_win.ps1 -Install        # also copy into %CommonProgramFiles%\{VST3,CLAP}
```

Validate with [pluginval](https://github.com/Tracktion/pluginval) (VST3) and [clap-validator](https://github.com/free-audio/clap-validator) (CLAP), or load in a host.

### Reference docs

`docs/reference.html` is the full module reference — every patch block with its inputs and parameters, grouped by category. It is generated from the **live module registry** (the same catalog the plugin's UI shows), so it never drifts from the build. `docs/reference.pdf` is the same content paginated for print, built from that same HTML.

```sh
# regenerate docs/reference.html from the registry
cmake --build build --target gen_reference
build/gen_reference_artefacts/Debug/gen_reference docs/reference.html
# rebuild docs/reference.pdf (needs pandoc + xelatex) — also refreshes the HTML
scripts/reference_pdf.sh
```

The renderer (`zpc::renderReferenceHtml`) lives in zpwr-patch-core and is shared by all three plugins; per-block docs come from each block's `description`/`category` metadata.

---

## [0x0A] TESTS

Two headless unit tests (no GUI/audio device, CI-friendly):

```sh
cmake --build build --target ScriptEngineTest PatchGraphTest
build/ScriptEngineTest_artefacts/Debug/ScriptEngineTest
build/PatchGraphTest_artefacts/Debug/PatchGraphTest
```

---

## [0x0B] KEY FILES

The routing engine itself lives in **[zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core)** (a git submodule under `libs/`), shared with zpwr-synth and zpwr-midi-fx. zpwr-fx supplies the audio module pack and the external sources (In L/R, noise, soft keys, MIDI/MPE); the core does the routing, topo eval, mod matrix, cables, and JSON.

| File | Role |
|------|------|
| `libs/zpwr-patch-core/`  | Shared routing core (submodule): graph, mod matrix, serialization, `ScriptEngine` |
| `src/dsp/AudioModules.h` | Re-exports the shared `zpc::registerAudioModules` (918 audio blocks) as `zfx::` |
| `src/FxConfig.h`         | Soft-key/MIDI counts + external source-id layout |
| `src/PluginProcessor.*`  | `AudioProcessor`, soft-key/master params, MIDI/MPE, audio loop feeding the core |
| `src/PluginEditor.*`     | WebView editor: catalog/patch/preset native functions over `zpc::PatchEngine` |
| `webui/`                 | Cyberpunk patcher UI (`index.html`, `css/cyberpunk.css`, JS, fonts) |

---

## [0x0C] ADDING A MODULE

1. Add the enum to `ModType` and its name to `PatchDef::allTypeNames()`.
2. Add its param metadata to `blockParamSpecs()`.
3. Add per-sample compute + any state to `RuntimeGraph::Block` / `computeBlock()`.

The new type appears in every block's type dropdown automatically.

---

## [0x0D] KNOWN LIMITATIONS

- **Structural edits** (type/routing/script changes) rebuild the graph and reset block DSP state; live param tweaks are lock-free and don't.
- The per-sample graph is interpreted; a JIT path (via fusevm/Cranelift) is the performance endgame.

---

## [0xFF] LICENSE

© MenkeTechnologies. Part of the MenkeTechnologies audio stack alongside [zpwr-synth](https://github.com/MenkeTechnologies/zpwr-synth), [zpwr-midi-fx](https://github.com/MenkeTechnologies/zpwr-midi-fx), and [zpwr-patch-core](https://github.com/MenkeTechnologies/zpwr-patch-core).
