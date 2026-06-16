# zpwr-fx

A modular multi-effects audio plugin built on [JUCE](https://juce.com). One unit,
a rack of effect slots, every effect category. Created by MenkeTechnologies.

## Formats

- **VST3** — cross-platform
- **AU** — macOS (Logic, GarageBand)
- **CLAP** — via [`clap-juce-extensions`](https://github.com/free-audio/clap-juce-extensions)
- **Standalone** — local dev/test app (drop it from `FORMATS` in `CMakeLists.txt`
  to ship VST3/AU/CLAP only)

## Architecture

JUCE's parameter model (`AudioProcessorValueTreeState`) is **static** — the host
needs the full parameter list at construction time. A truly dynamic
"add/remove arbitrary effects at runtime" rack fights that and breaks host
automation. So the rack is built as a fixed set of **ordered slots**, each with a
user-selectable effect type and a bank of generic macro parameters:

```
Input → [ Slot 0 ] → [ Slot 1 ] → … → [ Slot 7 ] → Output
          type=Filter   type=Delay        type=None
          bypass/mix     bypass/mix        (passthrough)
```

- `kNumSlots` slots (default 8), processed in order 0 → N-1.
- Each slot: a **type** selector (`AudioParameterChoice`), a **bypass** toggle, a
  **mix** (dry/wet) knob, and `kMacroParams` (default 8) normalized macro knobs.
- Each effect maps the 0..1 macro values onto its own engineering ranges
  (`ParamSpec` in `src/dsp/Effect.h`), so every parameter stays host-automatable
  while the knob labels/units follow whichever effect is loaded.
- Reorder/swap = change which effect sits in each slot position.

Every parameter is fixed at construction, so host automation, preset save/load,
and parameter-by-name lookups all work normally.

### Key files

| File | Role |
|------|------|
| `src/dsp/Effect.h`         | `Effect` interface + `ParamSpec` normalized↔engineering mapping |
| `src/dsp/EffectFactory.*`  | Registry of every effect type — **add new effects here** |
| `src/dsp/EffectRack.*`     | Slot chain: param layout, RT-safe reads, bypass + dry/wet blend |
| `src/dsp/effects/*.h`      | The effect implementations (built on `juce::dsp`) |
| `src/PluginProcessor.*`    | `AudioProcessor` + APVTS state + block routing |
| `src/PluginEditor.*`       | Rack GUI: per-slot type selector and contextual macro knobs |

## Effects (current set)

| Category   | Effect      | Macro params |
|------------|-------------|--------------|
| Dynamics   | Gain        | Gain |
| Dynamics   | Compressor  | Threshold, Ratio, Attack, Release |
| Filter     | Filter      | Cutoff, Resonance, Mode (LP/HP/BP) |
| Distortion | Drive       | Drive, Output (tanh saturation) |
| Modulation | Chorus      | Rate, Depth, Delay, Feedback |
| Modulation | Tremolo     | Rate, Depth |
| Time       | Delay       | Time, Feedback |
| Time       | Reverb      | Size, Damp, Width |

This is the starter set proving the rack across every major DSP category. The
factory is the single extension point toward "every fx possible".

## Adding an effect

1. Subclass `zfx::Effect` (see any header in `src/dsp/effects/`). Implement
   `typeId()`, `params()`, `prepare()`, `reset()`, `process()`. Render fully wet —
   the rack handles dry/wet and bypass.
2. Register it in `EffectFactory::EffectFactory()` (`src/dsp/EffectFactory.cpp`)
   with a one-line `registry.push_back (make<YourEffect> ("Display Name"));`.

The new type appears in every slot's selector automatically. Keep `params()` ≤
`kMacroParams`; raise that constant in `src/dsp/Config.h` if an effect needs more.

## Build

Requires CMake ≥ 3.22 and a C++20 compiler. Dependencies are vendored as git
submodules (JUCE pinned to 8.0.13, plus `clap-juce-extensions`).

```sh
git clone --recurse-submodules <repo-url>
cd zpwr-fx
cmake -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build --target ZpwrFX_All -j$(sysctl -n hw.ncpu)
```

Already cloned without submodules:

```sh
git submodule update --init --recursive
```

Build artifacts land under `build/ZpwrFX_artefacts/`, and `COPY_PLUGIN_AFTER_BUILD`
installs them into the user plugin folders. Launch the standalone build directly:

```sh
open "build/ZpwrFX_artefacts/Debug/Standalone/zpwr-fx.app"
```

## Known limitations (v1)

- **Effect instantiation on type change happens on the audio thread** — a one-time
  allocation when a slot's type changes (not per block). Fine for editing, but a
  glitch risk during live automation of the type parameter. The clean fix is to
  build/prepare the effect on the message thread and hand it to the audio thread
  via a lock-free swap.
- **Macro defaults** sit at the host-param default (0.5 normalized), not each
  effect's preferred default, because per-slot params are type-agnostic.
- **Macro knobs are linear in normalized space**; the `ParamSpec` skew only shapes
  the displayed value, not the knob travel.
