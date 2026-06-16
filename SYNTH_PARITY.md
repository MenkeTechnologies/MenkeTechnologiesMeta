# Synth Feature Parity — research-grounded gap analysis + port checklist

Purpose: a single source of truth for "which reference-synth features do we already have, which
are genuinely portable and still missing (→ the work list), and which are *not* portable (proprietary
content / undisclosed algorithms / closed engines)." Every reference column below is web-verified
against the cited primary sources — see `## Sources`. Uncertain items are marked `?`.

**Engine reality check:** ours is a *modular patch graph* (zpc), so most "features" of a fixed-architecture
synth (Sylenth1's 2-osc layout, Spire's signal flow, Massive X's voice tree) are *patches*, not code.
Code work = missing **module types** (oscillators / filters / modulators / effects) + a few engine-level
capabilities. The checklist at the bottom is only those.

Reference synths: **SynthMaster 3 (SM3), Serum 2 (S2), Massive X (MX), Vital (Vi), Pigments (Pi),
Omnisphere 2 (O2), Sylenth1 (Sy), Spire (Sp)**.

---

## What we already have (registered modules, June 2026)

- **zpc audio-fx pack** (`AudioModules.h`): Filter, Ladder, DiodeLadder, Comb, Formant, EQ, Shelf, Notch,
  DJFilter, Wah, AutoWah, Phaser · Delay, TapeDelay, Reverb, Massive(FDN), Spring, Chorus, Ensemble,
  Flanger, Vibrato, Rotary, Stutter, Reverse · Drive, Tube, Waveshaper, Shaper(12-mode), Wavefolder,
  Rectify, Bitcrush, Lofi, Clip, Exciter, RingMod, Octaver, TranceGate · Compressor, Limiter, Gate,
  Expander, Transient · LFO, StepSeq, SampleHold, Slew, Chaos, Envelope, Drift · VAnalog, Vector, FM,
  Additive, Noise, Oscillator, Unison.
- **zpc MoreOscillators** (`MoreOscillators.h`): Susaw, Sampler, SwitcherLFO, Sync, DAHDSR, Glide, Sub,
  **Warp** (Massive X modifiers: Neutral/Wrap/Grain/Hardsync/HardUpDown/Bend), **Spire** (Classic/Noise/
  FM/AMSync/SawPWM/HardFM/Vowel + unison).
- **synth voice pack** (`SynthModules.cpp`): Osc, Wt, Supersaw, FM, Sub, Additive, Sync, ChordOsc,
  Karplus, Sample, Granular, Noise, Vector, DiodeLadder, StepLFO, NoiseLFO, Scaler, Env, VCA, Filter,
  Folder, Waveshaper, Crusher, Glide, SampleHold, LFO, RingMod, Drive, Gain, Mixer.
- **midi pack** (`MidiModules.cpp`): Arp, Euclid, Chord, Scale, Transpose, Velocity, Chance, Harmonize,
  Echo, Merge, LFO, Env, Octave, NoteFilter, Mono, Latch, Strum, Quantize, Channel, FixedNote, Random,
  SampleHold, Slew, VelCurve, RandOctave, Humanize, Ratchet, KeySwitch, Fold, NoteLength, Accent,
  VelClip, Invert, Unison, Ramp.
- **Engine**: `LayeredEngine` (unlimited layers, per-layer gain/pan/**width**/mute/solo + key/vel zones),
  per-param mod matrix, expandable soft-key macros, master-FX bus, shared `EngineSettings`
  (A4 tuning / brickwall limiter / tempo / param smoothing), preset browser + tag editor.

---

## Oscillators / sound sources

| Capability | who has it | us |
|---|---|---|
| Virtual-analog (saw/pulse/tri/sine + PWM) | all | ✅ Osc, VAnalog |
| Unison (detuned voice stack) | all | ✅ Voices param + Susaw/Supersaw/Unison |
| Wavetable | S2,MX,Vi,Pi,SM3 | ✅ Wt |
| Sample / multisample (SFZ) | S2,O2,Pi,SM3 | ✅ Sample/Sampler (SFZ import = host) |
| Granular | S2,O2,Pi,SM3 | ✅ Granular |
| FM / PM | all | ✅ FM (+ Spire HardFM, Warp) |
| Hard sync + sync-variants | all | ✅ Sync, Warp(Hardsync/HardUpDown), Spire(AMSync) |
| Additive / harmonic | SM3,Pi,O2 | ✅ Additive |
| Physical modeling / modal | MX,Pi,SM3 | ✅ Karplus (modal = partial) |
| Vector (XY morph) | SM3,O2 | ✅ Vector |
| Vowel/formant oscillator | Sp,MX | ✅ Spire(Vowel), Formant filter |
| Massive-X wavetable modifiers | MX | ✅ Warp (6 of MX's 10 modes) |
| Noise (white/pink/brown) | all | ✅ Noise, NoiseLFO |
| **Spectral resynthesis** (harmonic-level, indep time/pitch) | S2,Vi,O2 | ❌ **GAP** |
| **PM osc bank** (MX sine/tri variants: Tri/TriB1-3/SinN) | MX | ❌ gap (FM partial) |
| **Noise "Geiger"** | S2 | ❌ minor gap |
| MX modes not yet done: Mirror, ART, Gorilla, Random, Jitter | MX | ◑ Warp has 6/10 |

## Filters

| Capability | who | us |
|---|---|---|
| SVF LP/HP/BP/Notch (12/24 dB) | all | ✅ Filter, Notch, Shelf, EQ |
| Moog/transistor ladder | all | ✅ Ladder |
| Diode ladder (303) | S2,Vi,Pi | ✅ DiodeLadder |
| Comb / flange / phaser filter | all | ✅ Comb, Phaser, Flanger |
| Formant / vowel | most | ✅ Formant, Wah, AutoWah |
| **Allpass / diffuser** | O2,MX | ❌ **GAP** (easy) |
| Proprietary models (Wasp, EMS, SEM, Mini, Jup-8, MS-20, Perfecto/Infecto/Acido, Asimov, Groian, Scanner, Creak) | S2,Pi,Sp,MX | ⛔ **not portable** — undisclosed algorithms |
| Drawable/morphable filter (PZ-SVF) | S2 | ❌ gap (UI-heavy) |

## Modulation

| Capability | who | us |
|---|---|---|
| ADSR / DAHDSR envelopes | all | ✅ Env, DAHDSR |
| LFO (sync, shapes) | all | ✅ LFO |
| Morphing / switcher LFO | MX,Vi,Pi | ✅ SwitcherLFO |
| Step LFO / stepped mod | all | ✅ StepLFO, StepSeq |
| Sample & hold / random | all | ✅ SampleHold, NoiseLFO |
| Slew / glide / scaler | SM3,Sp | ✅ Slew, Glide, Scaler |
| Macros (soft keys) | all | ✅ expandable soft-key pool |
| Mod matrix (sources → params, depth) | all | ✅ per-param mod routes |
| Chaos LFO — logistic | — | ✅ Chaos |
| **Chaos LFO — Lorenz / Rossler** (XY out) | S2 | ❌ **GAP** |
| **Path / XY vector LFO** (draw a 2-D path → X/Y) | S2 | ❌ gap |
| **Combinate** (logic/math combine of mod sources) | Pi | ❌ gap |
| **MSEG** (multi-segment env w/ curve editor) | S2,Vi,Pi,SM3 | ❌ gap — needs a curve-editor UI (large) |
| Trackers (map MIDI → mod) | MX | ◑ via mod sources |

## Effects

| Capability | who | us |
|---|---|---|
| Distortion / drive / waveshaper / wavefold / bitcrush / decimate | all | ✅ Drive, Tube, Shaper, Wavefolder, Bitcrush, Lofi, Clip |
| Filter / EQ / multi-EQ | all | ✅ EQ, Shelf, Filter (3-band = chain) |
| Chorus / ensemble / flanger / phaser | all | ✅ Chorus, Ensemble, Flanger, Phaser |
| Delay (+ tape) / reverb (+ FDN) | all | ✅ Delay, TapeDelay, Reverb, Massive, Spring |
| Compressor / limiter / gate / transient | all | ✅ Compressor, Limiter, Gate, Expander, Transient |
| Rotary / tremolo / trance-gate | most | ✅ Rotary, Tremolo, TranceGate |
| **Frequency shifter** (Bode / SSB) | S2,MX | ❌ **GAP** (inharmonic ≠ pitch shift) |
| **Multiband compressor** (X-Comp) | Sp,Pi | ❌ **GAP** |
| **Stereo / dimension expander** (widener) | MX,Pi,Sy | ❌ gap (we have *per-layer* width) |
| **Shimmer reverb** (pitch + verb) | Pi | ❌ gap |
| **Convolution** | S2 | ❌ gap — FFT/IR, large |
| **Vocoder** | Pi | ❌ gap — large |
| Splitter / multiband routing (L/M/H, M/S) | S2 | ◑ via cables |

## Architecture

| Capability | who | us |
|---|---|---|
| Layers / parts (multitimbral) | SM3(16),O2(8parts×4layers),Sy(A/B) | ✅ LayeredEngine (unlimited) |
| Per-layer gain/pan/width/mute/solo + key/vel zones | SM3,Sy,O2 | ✅ |
| Series/parallel filter & FX routing | all | ✅ free cabling |
| Master FX bus | all | ✅ (synth) |
| **Multiple FX buses** (S2 dual-bus, Pi A/B/AUX) | S2,Pi | ❌ gap (1 master bus today) |
| Arp / sequencer | all | ✅ midi pack Arp/Euclid/Random + Ratchet |
| Audio-engine settings (tune/limiter/tempo) | SM3 | ✅ EngineSettings |
| Preset browser w/ facet tags + tag editor | SM3,O2,Sp | ✅ |
| Microtuning / Scala | SM3,Pi | ❌ gap (have A4 tune only) |
| MPE | most | ✅ (synth perf sources) |

---

## ⛔ Explicitly NOT portable (do not fake these)

- **Omnisphere**: the ~14,000-sound library, recorded Soundsources, the closed **STEAM** engine, hardware-synth
  profile integration. This is *content + a closed engine*, not algorithms.
- **Named proprietary filter/osc models** with undisclosed DSP (Spire Perfecto/Infecto/Acido/Scorpio;
  Pigments SEM/Mini/Matrix-12/Jup-8/MS-20; MX Asimov/Groian/Scanner/Creak; S2 Wasp/EMS). We ship *generic*
  equivalents (SVF/Ladder/Diode/Comb/Formant) instead — honest, not a clone.
- Exact skins / UI chrome / factory preset libraries.

---

## ✅ PORT CHECKLIST (genuinely missing + faithfully portable — the work list)

Ordered by value/effort. Each is standard DSP we can implement faithfully; tick when shipped + verified.

**Oscillators / sources**
- [ ] `Spectral` oscillator — harmonic-bin resynthesis (additive bank w/ independent partial control)
- [ ] `PMOsc` — phase-mod oscillator bank (sine/tri variants, MX-style)
- [ ] Warp: add MX modes `Mirror`, `Random`, `Jitter` (ART/Gorilla = need NI algo, skip)
- [ ] Noise `Geiger` mode (sparse impulse noise)

**Filters**
- [x] `Allpass` / `Diffuser` (phase-rotation building block)

**Modulators**
- [x] `LorenzLFO` (Rossler pending) — strange-attractor chaos mod with X/Y outputs
- [ ] `PathLFO` — drawable XY vector path → X/Y outputs (needs small UI)
- [x] `Combinate` — combine two mod inputs (add/mult/min/max/AND/XOR) → 1 output
- [ ] `MSEG` — multi-segment envelope (DEFER: needs curve-editor UI)

**Effects**
- [ ] `FreqShift` — Bode frequency shifter (Hilbert/SSB, inharmonic)
- [ ] `MultiComp` — 3-band compressor (Spire X-Comp)
- [ ] `Widener` — stereo/dimension expander (M/S width + Haas, on the master bus)
- [ ] `Shimmer` — pitch-shifted reverb feedback
- [ ] `Convolve` — convolution reverb (DEFER: FFT/IR infra, large)
- [ ] `Vocoder` — band-vocoder (DEFER: large)

**Architecture**
- [ ] 2nd/3rd FX bus (parallel/aux), per Serum 2 / Pigments
- [ ] Scala / microtuning table (beyond A4)

---

## Sources (web-verified, June 2026)

- SynthMaster 3 — musicmarketing.ca review; kv331audio.com
- Serum 2 — xferrecords.com/products/serum-2 + official "What's New in Serum 2" PDF (v1.0.0)
- Massive X — native-instruments.com manual (wavetable-oscillators / insert-effects / routing / modulation)
- Vital — vital.audio; davidmvogel.com Vital UserGuide; audiopluginsforfree.com
- Pigments — arturia.com overview; support.arturia.com Effects FAQ; musicradar.com guide
- Omnisphere 2 — support.spectrasonics.net manual (oscillator / filters(34) / hierarchy / fx / lfos)
- Sylenth1 — vintagesynth.com/lennar-digital/sylenth1; lennardigital.com manual
- Spire — kvraudio.com/product/spire-by-reveal-sound (revealsound.com cert expired)
