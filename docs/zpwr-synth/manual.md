# Overview

zpwr-synth is a **fully modular patch-graph synthesizer**. Each voice is not a fixed signal path
but a free patch graph you build from oscillators, filters, envelopes, modulators and shapers —
the same wire-anything engine as zpwr-fx, made polyphonic. Stack up to **16 layers**, each its own
voice pool, route any source to any parameter through the mod matrix, and run the whole thing into
a master + 2-aux **FX-bus rack** carrying the full shared audio-effects pack. It runs as VST3, AU,
CLAP and Standalone on macOS, Linux and Windows.

# Getting started

1. Open the plugin on an instrument track and play a note (the on-screen keyboard is at the bottom,
   or use the QWERTY home row — click a key once to focus, then type).
2. Toggle **⚡ EZ MODE**. It lays down a complete playable voice — your generators feed a VCA
   opened by an amp envelope, into a filter swept by a second envelope, to the output — so any
   oscillator you add is summed straight into the sound.
3. Press **+ ADD BLOCK** to add oscillators, filters and modulators, then drag output jacks onto
   input jacks to wire your own voice.
4. Double-click a block for its detail panel — parameters, unison, and modulation routing.

**INIT** unplugs every cable and modulation route while keeping the blocks; **🗑** blanks the patch.

# The voice graph

Every voice is a patch of **nodes**, each with a type, inputs, up to eight parameters and one
output. Generators read the played **Note**, **Gate** and **Velocity** directly, so a single patch
definition plays polyphonically across the voice pool. The two outputs select the left/right
sources that feed the layer.

Every oscillator (Osc, Wt, Supersaw, FM, Sub, Sync, Additive) has a **Voices** unison control
(1–11) plus **Detune** in cents — detuned copies summed and loudness-normalised; `Voices = 1` is
classic mono. A first-class **Trigger** source (a one-sample impulse on each note-on) sits
alongside Note / Gate / Velocity for modular routing.

# Node types

| Node | Role | Key params |
|------|------|------------|
| **Osc** | analog oscillator (note-driven) | wave, octave, fine, PW |
| **Wt** | wavetable oscillator | table, position, octave, fine |
| **Supersaw** | 7 detuned saws (JP-8000 style) | octave, detune, mix |
| **FM** | 2-operator phase-modulation sine | ratio, index, octave |
| **Karplus** | plucked-string physical model | octave, damping, feedback |
| **Additive** | summed sine harmonics | partials, rolloff, odd/even |
| **Sync** | hard-sync sawtooth | tune, sync ratio, octave |
| **ChordOsc** | one note → a 3-saw chord | type, octave, detune |
| **Vector** | 4-source XY-morph oscillator (Prophet-VS) | octave, X, Y, detune |
| **HardKick** | hardstyle kick (pitch-sweep + tanh drive) | tune, punch, psweep, decay, drive |
| **Screech** | hardstyle screech lead (saws → drive → formant) | octave, detune, drive, formant |
| **Hoover** | Alpha-Juno hoover / Mentasm | octave, PWM, chorus, sweep |
| **Reese** | DnB / neurofunk Reese bass | octave, detune, voices, tone, drive |
| **Sub** | sub-oscillator below the note | octave, wave, level |
| **Noise** | white / pink noise source | color, level |
| **Sample / Granular** | sample playback / granular | slot, start, size, rate |
| **Env** | ADSR envelope (gate-driven) | A, D, S, R |
| **VCA** | `in1 × in2` (audio × CV) | — |
| **Filter** | TPT state-variable | cutoff, reso, mode, mod |
| **DiodeLadder** | 4-pole diode-ladder LP (303 grit) | cutoff, reso, mod, drive |
| **Folder** | sine wavefolder (west-coast) | fold, bias, mix |
| **Waveshaper** | 4-curve shaper | drive, shape, mix |
| **Crusher** | bit + sample-rate reduction | bits, downsample, mix |
| **Glide** | portamento on the note CV | time |
| **SampleHold** | clocked sample-and-hold CV | rate, glide |
| **StepLFO** | stepped LFO (stair / random S&H) | rate, steps, shape, smooth |
| **NoiseLFO** | coloured-noise CV + S&H | rate, color, depth |
| **Scaler** | scale / offset / curve a CV | scale, offset, curve |
| **Delay / LFO / RingMod / Drive / Gain / Mixer** | shaping + modulation | per-type |

# The interface

- **Patch** — the node grid with drag-to-wire cables, the macro soft-key strip (`+` / `−` to add
  or remove; 16 active by default), and the **INIT**, **🗑**, **⚡ EZ MODE**, **Stereo** and
  **Stereo Lock** controls. Double-click a block for its detail modal.
- **Perform** — a play surface with no patching (see below).
- **Settings** — master in/out and bypass, **Auto Gain Stage** and target, the brickwall limiter,
  and the rest of the audio-engine settings.

# Modulation

Modulation is the patching itself: any LFO or envelope node output, or any macro soft key, patched
into a node input — or mod-routed to a parameter — is a modulation connection. The host-automatable
parameters are the **soft keys** (an expandable pool, 16 active by default) plus master in / out /
bypass; the patch itself is saved as plugin state.

# Gain staging

Two per-block Settings (both **on by default**) keep the signal between blocks from clipping no
matter how hot the cable gains are, inside every voice graph and the FX buses:

- **Auto Gain Stage** rides levels with a fast-attack / slow-release follower toward the
  **Auto-Gain Target** ceiling.
- **Soft Clip** is the guarantee — an instant tanh bound at the same ceiling, catching transients
  the follower would miss, saturating gently rather than clipping.

Turn either off in Settings for raw gain; the master **Brickwall Limiter** is a separate final
ceiling.

# Stereo & stereo lock

**Stereo** mirrors every block into an independent right-channel clone (a dual-mono voice per
side); knobs stay independent so you can dial width. **🔒 Lock** (shown when Stereo is on) keeps
the two channels in sync — moving a knob on either side moves its clone by the *same delta*, so the
L/R offset is preserved rather than reset, and the link is bidirectional. Locked clone blocks are
dimmed.

# Perform & macros

The **Perform** tab is a macros-and-pads surface for live play, driving only host-automatable
parameters so it works editor-closed and records as automation:

- **Preset Morph** — a 4-corner XY pad bilinearly interpolating between four corner presets
  (A/B/C/D); **🎲** fills all four at random.
- **Orb** — drag the puck where the *angle* selects one of eight randomised scenes and the
  *distance* scales intensity; **🎲** rolls fresh scenes, **⏺** records the gesture and **▶** loops
  it back through the macro parameters.
- **XY macro pads** — each drives a pair of soft keys, with per-pad **HOLD** (leave the dot) /
  **SPRING** (snap back to centre).
- **Macro knobs**, plus eight **Snapshots** of the whole macro surface (click empty to save, filled
  to recall, right-click to clear) and a **🎲 Randomize**.
- **Scale / key** quantize and a **Chord** stacker (Oct / 5th / Maj / Min / Maj7 / Min7 / Sus4 /
  Power), an on-screen keyboard with pitch-bend and mod wheels, and the **ARP** controls — mode
  (Up / Down / Up-Down / Random / As-Played), rate (`1/4`…`1/16T`) and **Latch**.
- **MIDI In** toggles — **Program** (respond to Program Change) and **Bank** (respond to Bank
  Select CC0/CC32), both on by default.

# Presets

**256 factory voices** ship across **Factory 1** and **Factory 2** (128 each), with category
prefixes — `BA` bass, `LD` lead, `PD` pad, `KY` keys, `PL` pluck, `BR` brass, `BE` bell, `ST`
strings, `DR` perc, `SEQ` / `FX` — spanning subtractive, FM, additive, supersaw, wavetable, vector,
sync and Karplus voices. Three further genre banks are designed from documented production
techniques:

- **Trance** — stacked supersaw pluck-leads, slow-swell pads, a `1/16` square-LFO trance gate, and
  saw-LFO sidechain-pumped rolling bass.
- **Hard Techno** — Drumcode-style FM stabs with a fully env-swept dirty low-pass, screaming diode
  303 acid, detuned reese/rumble, hoover and driven lead-bass.
- **Schranz** — bitcrushed/folded metallic stabs, filtered-noise sweeps, `1/16` gated-noise loops,
  two-octave siren wails and distorted hypnotic pulses (~160 BPM).

Every preset carries facet tags (Type / Character / Style) so the browser's facets are fully
populated, and ships with named macro knobs plus mod-wheel / velocity routing so it loads playable.
Your own patches save and load from the preset manager. Factory voices can also be exported as
Native Kontrol Standard `.nksf` presets with a Komplete Kontrol audio preview for hardware browsing.

# Playing

The on-screen keyboard sits at the bottom of the editor; the computer keyboard's home row
(`A W S E D F T G Y H U J K …`) plays a chromatic octave around C4. Click a key once to give the
keyboard focus, then type.
