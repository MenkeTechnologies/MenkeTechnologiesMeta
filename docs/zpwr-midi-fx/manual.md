# Overview

zpwr-midi-fx is a **modular MIDI-effects plugin** that transforms the note stream *before* it
reaches an instrument — turning single keys into voiced chords, scale-locking for intelligent
harmony, and running notes through a polymetric step arpeggiator with Euclidean rhythm generation.
It is the same free-routed patch graph as zpwr-fx, instantiated on the note stream instead of audio
samples, so you wire note-transform modules into your own chains rather than picking from a fixed
rack. It runs as VST3, AU, CLAP and Standalone on macOS, Linux and Windows.

# Getting started

1. Place the plugin before an instrument (in a MIDI-effect slot, or on a MIDI track routed to an
   instrument).
2. Press **⚡ EZ WIRE** — it auto-wires MIDI In → your blocks → Out so a chain works immediately.
3. Press **+ ADD BLOCK** to add a Chord, Arp or Scale module, then drag output jacks onto input
   jacks to build your own note pipeline.
4. Every control has a hover tooltip; double-click a block for its parameters and modulation.

**INIT** unplugs every cable and modulation while keeping the blocks; **🗑** blanks the patch.

# The patch model

A dynamic set of blocks (add, remove, reorder), each with a module type, note-stream inputs and a
scalar **Mod** input, up to six parameters, and one output. Inputs select any source; the two
outputs (**Out A**, **Out B**) merge to the plugin's MIDI out. The graph is evaluated once per
audio block in topological order, and note-offs are scheduled across block boundaries so a note
never hangs.

The **Inputs** column exposes every patchable source as a jack — the note input, every scalar
modulator (Random plus the performance / MPE controllers) and the soft keys — so anything usable in
the mod matrix can be cabled straight into a block.

**Cables** are drawn between jacks and dragged to re-patch. Right-click a cable for its editor: a
**Level** (scales note velocity on that connection — `0` mutes it, and the cable's brightness and
width follow the level), a **Colour** swatch, and **Disconnect**.

# Module library

The library spans harmony, sequencing, probability, routing, control sources, dynamics, tuning and
MPE/voicing, plus a family of cellular-automaton sequencers. A representative selection:

| Module | What it does |
|--------|--------------|
| **Chord** | one key → a voiced chord (165 types, inversion, spread, octave-double, transpose, strum) |
| **Arp** | host-synced arpeggiator (9 play modes, divisions, gate, octaves, swing) |
| **Scale** | snap every note onto the nearest in-key pitch (20 scales) |
| **Transpose** | shift notes by semitones (modulatable) |
| **Velocity** | scale / offset note velocity (modulatable) |
| **SeqEuclid** | retrigger held notes on a Euclidean (Bjorklund) rhythm |
| **Chance** | per-note probability gate |
| **Harmonize** | stack up to three fixed intervals |
| **Echo** | MIDI delay with feedback (decaying repeats) |
| **Merge** | combine two note streams |
| **LFO** | scalar control source (sine / tri / saw / square) |
| **Env** | ADSR follower gated by held notes — a control source |
| **Octave** | add octave-up / octave-down copies |
| **NoteFilter** | pass only notes within a note + velocity range (key zone) |
| **Mono** | collapse to monophonic with note priority (last / lowest / highest) |
| **Latch** | toggle-hold notes — sustain until re-pressed |
| **Strum** | spread simultaneous notes in time (up / down) |
| **Quantize** | snap note timing to a grid (rate + strength) |
| **Channel** | remap the output MIDI channel |
| **FixedNote** | force every note to one pitch (drum triggering) |
| **Random** | clock-driven random-note generator over a range |
| **SampleHold** / **Slew** | sample or smooth a scalar source — control sources |
| **VelCurve** | reshape velocity through a gamma curve |
| **RandOctave** | randomly shift notes by ± octaves (probability) |
| **Humanize** | jitter timing and velocity for a played feel |
| **SeqRatchet** | split each note into N rapid retriggers |
| **KeySwitch** | keyboard split — one zone plays, the other holds back |
| **Fold** | octave-fold every note into a fixed window |
| **NoteLength** | force every note to a fixed gate length |
| **Accent** | boost the velocity of every Nth note (downbeat) |
| **Invert** | melodic inversion around a pivot |
| **Unison** | layer each note as N copies, optional MPE channel spread |
| **Ramp** | velocity crescendo / decrescendo over N notes |

The **Module Reference** lists every block with its inputs and parameters, generated from the live
registry so it never drifts.

# Modulation

A dynamic list of routes, each mapping a **scalar source → any block parameter** with a depth.
Sources:

- **Soft keys** — an expandable pool of host-automatable macros (16 active by default, `+` / `−`
  to add or remove).
- **LFO** and **Env** block outputs, and **Random**.
- **Performance controllers** — mod wheel, pitch bend, aftertouch, velocity, expression (CC11),
  sustain (CC64).
- **MPE** — per-note bend, pressure and slide (CC74), read from the most recently active note.

The same sources are available on each block's **Mod** input; depth is a live, lock-free tweak.

# Stereo

**⊞ Stereo** mirrors every block, cable and mod into an independent right-channel chain, kept in
sync as you edit while knobs stay independent so you can dial width. **🔒 Lock** keeps the mirrored
knobs tracking the left channel — bidirectional and offset-preserving, so a width you dialled in
isn't reset. Locked clone blocks are dimmed.

# Perform & macros

The **Perform** tab is a macros-and-pads view with no patching, for live play:

- **Preset Morph** — a 4-corner XY pad bilinearly interpolating four captured presets; **🎲** fills
  all four at random.
- **Orb** — the puck's *angle* picks one of eight random scenes, its *distance* scales intensity;
  **🎲** rolls new scenes, **⏺** records the gesture and **▶** loops it.
- **XY macro pads** — each drives a pair of soft keys, with per-pad **HOLD** / **SPRING**.
- **Macro knobs**, eight **Snapshots** of the macro surface, and a **🎲 Randomize**.
- **On-screen keyboard** — global **Key + Scale** quantize and a **Chord** selector (Off / Oct /
  5th / Maj / Min / Maj7 / Min7 / Sus4 / Power) stacking intervals on each played key, plus a
  global arp (mode / rate / latch) distinct from the per-block Arp module.
- **MIDI In** toggles — **Program** and **Bank**, both on by default: an incoming Program Change
  switches presets, with Bank Select (CC0 MSB / CC32 LSB) captured for the next Program Change.

# Presets

A factory bank ships with the plugin — Chord Arp, Strummed Chords, Euclidean Pulse, Fifth
Harmonizer, Arp Echo, Random Walk, Step Melody, Tone Cluster, Jazz Voicing, MPE Spread and more —
spanning arps, harmony, rhythm, generative and FX chains. Your own patches save and load from the
**Presets** tab.
