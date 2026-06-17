# zpwr-synth

A JUCE software synthesizer by MenkeTechnologies — a fully modular instrument
modeled on [SynthMaster 3](https://www.kv331audio.com/synthmaster3.aspx)
(KV331 Audio).

Builds as **VST3**, **AU**, **CLAP**, and **Standalone** on macOS (Apple Silicon / Intel)
and Linux (x86_64 / aarch64). CLAP via `clap-juce-extensions`.

## Architecture

The DSP core lives in `dsp/` as a pure-C++ static library with **no JUCE
dependency**, so it is unit-testable headless. The JUCE plugin wrapper in
`src/` owns the parameter tree and feeds the engine.

```
ZpwrSynthProcessor (JUCE AudioProcessor + APVTS)
  └─ zpwr::Instrument
       ├─ WavetableBank             # shared, band-limited, procedurally built
       └─ Layer[16]                 # SynthMaster 3 supports 16 layers/instrument
            ├─ params  (LayerParams)
            ├─ Voice pool            # polyphonic, round-robin voice stealing
            │    ├─ Generator (one of):
            │    │    ├─ Oscillator              # Basic: PolyBLEP sine/saw/square/tri
            │    │    ├─ VirtualAnalogOscillator # saw/pulse, PWM, unison, drift
            │    │    └─ WavetableOscillator     # mipmapped tables, position morph
            │    ├─ StateVariableFilter   # TPT/Zavalishin LP/HP/BP
            │    ├─ ADSR (amp)
            │    └─ ADSR (filter)
            ├─ LFO 1
            └─ ModMatrix             # 8 slots: source -> destination, depth
```

### Oscillator types

| Type | Engine | Key parameters |
|------|--------|----------------|
| Basic | Geometric PolyBLEP | waveform (sine/saw/square/triangle) |
| Virtual Analog | Band-limited saw/pulse | shape, pulse width, unison (1–7), detune, drift |
| Wavetable | Band-limited mipmapped tables | table (Basic Shapes / Harmonic Sweep / Formant), position |

Wavetables are generated additively at startup (no asset files) and stored as
12 band-limited mip levels selected by phase increment, so they are alias-free
and sample-rate independent.

### Modulation matrix

| Sources | Destinations |
|---------|--------------|
| LFO 1, Amp Env, Filter Env, Velocity, Mod Wheel, Key Track | Osc Pitch, Osc Level, Filter Cutoff, Filter Reso, Amp, LFO 1 Rate, Osc PWM, Osc WT Pos |

## Build

JUCE 8.0.13 is fetched automatically via CMake `FetchContent` — no system
install required.

```sh
cmake -B build -G Ninja          # or omit -G Ninja for Makefiles
cmake --build build
```

Artifacts land under `build/ZpwrSynth_artefacts/`. With
`COPY_PLUGIN_AFTER_BUILD`, the AU/VST3 are also copied into the user plugin
folders. Run the standalone directly:

```sh
open "build/ZpwrSynth_artefacts/Debug/Standalone/ZpwrSynth.app"   # macOS
```

## Roadmap

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Build + polyphonic Basic Osc → ADSR → SVF → LFO → mod matrix | done |
| 1 | Wavetable + Virtual Analog oscillators | osc done; multi-LFO + mod UI next |
| 2 | Up to 16 layers, per-layer insert FX chain (6) | planned |
| 3 | Additive, Vector, FM/PM/PD, Ring-mod synthesis methods | planned |
| 4 | Granular oscillator (512 grains), SFZ sample playback | planned |
| 5 | Preset browser + factory bank, custom editor skin | planned |

SynthMaster 3 reference: up to 16 layers/instrument, 16 modules/layer, 32 mod
sources and 6 insert FX per layer, 7 generator types, ~12 synthesis methods.
