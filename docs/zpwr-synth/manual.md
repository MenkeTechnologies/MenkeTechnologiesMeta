# Overview

zpwr-synth is a **fully modular patch-graph synthesizer**. Each voice is not a fixed signal path but
a free patch graph you build from oscillators, filters, envelopes, modulators and shapers — the same
wire-anything engine as zpwr-fx, made polyphonic. Stack up to **16 layers**, each its own voice pool,
route any source to any parameter through the mod matrix, and run the whole thing into a master +
2-aux **FX-bus rack** carrying the full shared audio-effects pack. It runs as VST3, AU, CLAP and
Standalone on macOS, Linux and Windows.

# Core concepts

**The voice graph.** You design one patch — a graph of nodes — and the engine instantiates it across
a pool of voices. Each node has a type, inputs, up to eight parameters and one output. Generators
read the played **Note**, **Gate** and **Velocity** directly, so the single patch definition plays
polyphonically: press a chord and the same graph runs once per held note.

**Outputs.** The patch's two outputs select the left and right sources that feed the layer. Anything
in the graph can be the output — the raw oscillator, the filter, a VCA, a sum.

**Signal vs control.** As in zpwr-fx, cables carry both audio and control. An LFO or envelope is just
a signal; patch it into a Filter's cutoff mod, a VCA, or any parameter to modulate it.

**Layers.** A layer is an independent voice pool running its own copy of the patch. Stack layers to
split/detune (two layers an octave apart), to blend timbres, or to build huge unisons, and balance
them in the layered mixer feeding the FX-bus rack.

**Unison.** Separately from layers, every oscillator has its own **Voices** (1–11) and **Detune**
controls — detuned copies summed and loudness-normalised within a single voice — for supersaw-style
width without spending polyphony on layers.

# Getting started

1. Open the plugin on an instrument track and play a note (the on-screen keyboard is at the bottom,
   or use the QWERTY home row — click a key once to focus, then type).
2. Toggle **⚡ EZ MODE**. It lays down a complete playable voice — your generators feed a VCA opened
   by an amp envelope, into a filter swept by a second envelope, to the output — so any oscillator
   you add is summed straight into the sound. Start here, then customise.
3. Press **+ ADD BLOCK** to add oscillators, filters and modulators, and drag output jacks onto input
   jacks to wire your own voice.
4. **Double-click** a block for its detail panel — parameters, unison (Voices/Detune), and
   modulation routing.

**INIT** unplugs every cable and modulation route while keeping the blocks; **🗑** blanks the patch.

# Building a voice

A typical subtractive voice, by hand:

1. Add an **Osc** (or Supersaw / Wt / FM). It already follows the played note.
2. Add an **Env** and a **VCA**; wire Osc → VCA In 1 and Env → VCA In 2, so the envelope opens the
   amplitude on each note. Make the VCA an output.
3. Add a **Filter**; insert it between Osc and VCA. Add a second **Env** and route it to the Filter's
   cutoff mod for a filter sweep on each note.
4. Add an **LFO** and route it to pitch or cutoff for vibrato or movement.

Swap the oscillator type at any time — the rest of the voice keeps working — to go from analog to
wavetable, FM, additive, supersaw, vector, sync or physical-model character.

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

Every oscillator (Osc, Wt, Supersaw, FM, Sub, Sync, Additive) carries the **Voices**/**Detune**
unison pair. A first-class **Trigger** source — a one-sample impulse on each note-on — sits alongside
Note / Gate / Velocity for modular-style routing (e.g. trigger a sample-and-hold per note).

# The interface

- **Patch** — the node grid with drag-to-wire cables, the macro soft-key strip (`+` / `−` to add or
  remove; 16 active by default), and the **INIT**, **🗑**, **⚡ EZ MODE**, **Stereo** and **Stereo
  Lock** controls. Double-click a block for its detail modal.
- **Perform** — a play surface with no patching (see below).
- **Settings** — master in/out and bypass, **Auto Gain Stage** and target, the brickwall limiter, and
  the rest of the audio-engine settings.

# Modulation

Modulation is the patching itself: any LFO or envelope node output, any stepped/noise CV source, or
any macro **Soft Key**, patched into a node input — or routed to a parameter as `base + source ×
depth` — is a modulation connection. The host-automatable parameters are the **soft keys** (an
expandable pool, 16 active by default) plus master in / out / bypass; the patch itself is saved as
plugin state. The **Scaler** node reshapes a control signal (scale / offset / curve) when you need to
bend a modulation source before it hits a destination.

# The FX-bus rack

The summed output of all layers runs through a **master + 2-aux FX-bus rack** built from the same
shared audio pack as zpwr-fx — so the full library of filters, delays, reverbs, dynamics, distortion
and analog-modeled effects is available on the synth's output, once, after the voices mix down. Send
voices to the aux buses for shared reverb/delay, and process the master bus for glue.

# Gain staging

Two per-block Settings (both **on by default**) keep the signal between blocks from clipping no matter
how hot the cable gains are, inside every voice graph and on the FX buses:

- **Auto Gain Stage** rides levels with a fast-attack / slow-release peak follower pulling each block
  toward the **Auto-Gain Target** ceiling.
- **Soft Clip** is the guarantee — an instant tanh bound at the same ceiling, catching the fast
  transients the follower would miss, saturating gently rather than clipping.

Turn either off in Settings for raw gain; the master **Brickwall Limiter** is a separate final ceiling.

# Stereo & stereo lock

**Stereo** mirrors every block into an independent right-channel clone (a dual-mono voice per side);
knobs stay independent so you can dial width. **🔒 Lock** (shown when Stereo is on) keeps the two
channels in sync — moving a knob on either side moves its clone by the *same delta*, so the L/R offset
is preserved rather than reset, and the link is bidirectional. Locked clone blocks are dimmed.

# Perform & macros

The **Perform** tab is a macros-and-pads surface for live play, driving only host-automatable
parameters so it works editor-closed and records as automation:

- **Preset Morph** — a 4-corner XY pad bilinearly interpolating between four corner presets
  (A/B/C/D); **🎲** fills all four at random.
- **Orb** — drag the puck where the *angle* selects one of eight randomised scenes and the *distance*
  scales intensity; **🎲** rolls fresh scenes, **⏺** records the gesture and **▶** loops it back
  through the macro parameters.
- **XY macro pads** — each drives a pair of soft keys, with per-pad **HOLD** (leave the dot) /
  **SPRING** (snap back to centre).
- **Macro knobs**, eight **Snapshots** of the whole macro surface (click empty to save, filled to
  recall, right-click to clear), and a **🎲 Randomize** of all macros.
- **Scale / key** quantize and a **Chord** stacker (Oct / 5th / Maj / Min / Maj7 / Min7 / Sus4 /
  Power), an on-screen keyboard with pitch-bend and mod wheels, and the **ARP** controls — mode
  (Up / Down / Up-Down / Random / As-Played), rate (`1/4`…`1/16T`) and **Latch** (keep arpeggiating
  held notes after the keys release).
- **MIDI In** toggles — **Program** (respond to Program Change) and **Bank** (respond to Bank Select
  CC0/CC32), both on by default.

# Presets

**256 factory voices** ship across **Factory 1** and **Factory 2** (128 each), with category prefixes
— `BA` bass, `LD` lead, `PD` pad, `KY` keys, `PL` pluck, `BR` brass, `BE` bell, `ST` strings, `DR`
perc, `SEQ` / `FX` — spanning subtractive, FM, additive, supersaw, wavetable, vector, sync and
Karplus voices. Three further genre banks are designed from documented production techniques:

- **Trance** — stacked supersaw pluck-leads, slow-swell pads, a `1/16` square-LFO trance gate, and
  saw-LFO sidechain-pumped rolling bass.
- **Hard Techno** — Drumcode-style FM stabs with a fully env-swept dirty low-pass, screaming diode 303
  acid, detuned reese/rumble, hoover and driven lead-bass.
- **Schranz** — bitcrushed/folded metallic stabs, filtered-noise sweeps, `1/16` gated-noise loops,
  two-octave siren wails and distorted hypnotic pulses (~160 BPM).

Every preset carries facet tags (Type / Character / Style) so the browser's facets stay populated, and
ships with named macro knobs plus mod-wheel / velocity routing so it loads playable. Your own patches
save and load from the preset manager. Factory voices can also be exported as Native Kontrol Standard
`.nksf` presets with a Komplete Kontrol audio preview for hardware browsing.

# Playing

The on-screen keyboard sits at the bottom of the editor; the computer keyboard's home row
(`A W S E D F T G Y H U J K …`) plays a chromatic octave around C4. Click a key once to give the
keyboard focus, then type. Pitch-bend and mod wheels sit beside the keyboard, and the Perform tab's
arp, chord and scale controls shape what you play.

# Sound-design tutorials

**A fat supersaw lead.** Add a **Supersaw**; raise its **Voices** to 7–11 and **Detune** for width.
Add an **Env** + **VCA** for the amp shape, and a **Filter** opened by a second **Env** with a quick
decay for a bright attack. Add a slow **LFO** to the Filter cutoff for movement, and a touch of
**Glide** for portamento between notes. Stack a second **layer** an octave down for weight.

**An FM bass.** Add an **FM** node; set a low **ratio** (1–2) and moderate **index**, with a short
amp envelope. Route an **Env** to the FM index so the bite decays into a rounder body. Follow with a
**DiodeLadder** filter for grit and a **Drive** for saturation.

**A 303 acid line.** Add an **Osc** (saw) → **DiodeLadder** (high resonance) → amp **Env**. Route a
fast **Env** to the ladder cutoff for the squelch, add **Glide** for slides, and push the ladder
**drive**. Play with the **Accent**-style velocity routing to brightness for classic acid dynamics.

**A wavetable pad.** Add a **Wt** oscillator; route a slow **LFO** to its **position** so the timbre
evolves. Long amp **Env** attack/release, a gently swept **Filter**, unison **Voices** for thickness,
and an aux send to reverb on the **FX-bus rack** for space.

**A plucked string.** Add a **Karplus** node; set **damping** and **feedback** to taste, a percussive
amp envelope, and a short delay. Velocity → brightness makes it dynamic.

# Sound-design cookbook

- **Movement** — slow LFO → wavetable position, filter cutoff, or oscillator detune.
- **Punch** — fast envelope → filter cutoff with a short decay for a bright transient.
- **Width** — raise oscillator **Voices**/**Detune**, or run **Stereo** with a small L/R offset.
- **Octave stack** — a second **layer** transposed an octave for thickness without retuning the patch.
- **Random per note** — **Trigger** source → **SampleHold** → pitch or cutoff for per-note variation.
- **Sidechain pump** — an LFO synced to the beat → a VCA on the output for rhythmic ducking.
- **Velocity feel** — velocity → filter cutoff and amp level so dynamics translate.

# Tips & best practices

- Start from **⚡ EZ MODE** (or a factory voice near your target) and modify, rather than building from
  silence.
- Use **unison Voices/Detune** for width inside one voice; use **layers** for parallel timbres or
  octave stacks.
- Keep **Auto Gain Stage** / **Soft Clip** on while patching; the FX-bus rack and hot cable gains can
  otherwise overshoot.
- Name your **soft-key macros** for the parameters you perform, so presets load playable and the
  Perform pads make sense.
- Audition with the **Perform** Morph/Orb to find variations of a patch quickly.

# FAQ

**No sound when I play.** Toggle **⚡ EZ MODE**, or check that an oscillator reaches the output through
a VCA opened by an envelope (a closed VCA is silent).

**My patch only plays one note.** Each held note runs its own voice automatically — if it sounds
mono, you may have a **Mono**-style routing or a single shared envelope; otherwise just play a chord.

**How do I add effects?** The **FX-bus rack** on the output carries the full audio pack; send voices
to the aux buses or process the master bus.

**Can I use hardware browsing?** Export factory voices as Native Kontrol Standard `.nksf` presets with
previews for Komplete Kontrol.

**Which formats / OSes?** VST3, AU, CLAP and Standalone on macOS, Linux and Windows (AU is macOS only;
Windows ships VST3 + CLAP).

# Glossary

- **Voice** — one instance of your patch graph, one per held note across the pool.
- **Layer** — an independent voice pool running its own copy of the patch.
- **Unison (Voices/Detune)** — detuned oscillator copies summed inside one voice.
- **Soft key / macro** — a host-automatable knob, also patchable as a mod source.
- **FX-bus rack** — the master + 2-aux effects rack on the summed output.
- **EZ Mode** — a one-toggle playable voice you can then customise.
