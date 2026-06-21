# Overview

zpwr-midi-fx is a **modular MIDI-effects plugin** that transforms the note stream *before* it reaches
an instrument. Where a normal MIDI effect gives you one fixed transform (an arpeggiator, say, with a
few knobs), zpwr-midi-fx hands you the same free-routed patch graph as zpwr-fx — instantiated on a
stream of note events instead of audio samples — so you wire note-transform modules into your own
chains. Turn single keys into voiced chords, scale-lock for intelligent harmony, run notes through a
polymetric step arpeggiator with Euclidean rhythm generation, split the keyboard, add probability and
humanisation — in any order and combination you wire. It runs as VST3, AU, CLAP and Standalone on
macOS, Linux and Windows, registering as a MIDI-effect where the host supports it.

The modular advantage for MIDI: order is yours (harmonise then arpeggiate, or arpeggiate then
harmonise, are different and both available), transforms can be modulated (an LFO sweeping a transpose,
velocity driving a chord type), and you can fan a note stream into parallel branches (bass one way,
chords another) and merge them.

# Core concepts

**The note stream.** Where zpwr-fx processes audio samples, zpwr-midi-fx processes a stream of note
events — note-ons, note-offs, velocities and controllers. Each block reads notes coming in, transforms
them (adds, removes, retimes, retunes, re-velocities), and passes notes out. Placed before an
instrument, it rewrites what the instrument actually receives, so a single key can arrive as a strummed
seventh chord locked to your scale.

**Blocks.** A dynamic set you add, remove and reorder. Each block has a module type, note-stream
inputs and a scalar **Mod** input (any number of cables per input, summed), up to six parameters, and
one output. The two outputs, **Out A** and **Out B**, merge to the plugin's MIDI out — so you can
build two parallel chains and combine them.

**Scalar sources.** Alongside notes the graph carries scalar control signals — LFOs, envelopes,
Random, the macro soft keys, and the performance/MPE controllers. Patch these into a block's **Mod**
input or route them to a parameter to animate a transform (an LFO slowly shifting a Transpose, velocity
driving an Arp's gate, MPE slide steering harmony).

**Topological evaluation, no hung notes.** The graph is evaluated once per audio block in dependency
order, so each module runs after the modules it reads. Note-offs are scheduled across audio-block
boundaries, so even with delays, ratchets, probability and long echoes in the chain, every note that
starts is guaranteed to stop — the engine tracks the pairing for you.

# Getting started

1. Place the plugin before an instrument — in a MIDI-effect slot, or on a MIDI track routed to an
   instrument.
2. Press **⚡ EZ WIRE** — it auto-wires MIDI In → your blocks → Out so a chain works immediately,
   before you touch a cable.
3. Press **+ ADD BLOCK** to add a Chord, Arp or Scale module, then drag output jacks onto input jacks to
   build your own note pipeline. Drag an output to a second input to fan the stream into two branches.
4. Every control has a hover tooltip; **double-click** a block for its parameters and modulation.

**INIT** unplugs every cable and modulation while keeping the blocks; **🗑** blanks the patch.

# The patch model

The **Inputs** column exposes every patchable source as a jack — the note input, every scalar modulator
(Random plus the performance / MPE controllers) and the soft keys — so anything usable in the mod
matrix can be cabled directly into a block as well.

**Cables** are drawn between jacks and dragged to re-patch. Right-click a cable for its editor: a
**Level** that scales note velocity on that connection (`0` mutes it, and the cable's brightness and
width follow the level — a built-in way to A/B a branch without deleting it), a **Colour** swatch, and
**Disconnect**. Level is a live tweak; colour is cosmetic and persists with the patch.

A simple chord-then-arp chain wires as `MIDI In → Chord → Arp → Out A → MIDI Out`. Because order is
explicit, reversing it (`Arp → Chord`) is a different musical result — arpeggiate the single keys
first, then voice each arpeggiated note into a chord — and you choose which you want by how you wire.

# Module library

The library spans several families. A representative selection follows; the **Module Reference** lists
every block with its inputs and parameters, generated from the live registry so it never drifts.

**Harmony** — turn one key into many notes, or bend pitch into key:

| Module | What it does |
|--------|--------------|
| **Chord** | one key → a voiced chord (165 types, inversion, spread, octave-double, transpose, strum) |
| **Harmonize** | stack up to three fixed intervals |
| **Scale** | snap every note onto the nearest in-key pitch (20 scales) |
| **Transpose** | shift notes by semitones (modulatable) |
| **Octave** | add octave-up / octave-down copies |
| **Invert** | melodic inversion — reflect notes around a pivot |
| **Fold** | octave-fold every note into a fixed [low, high] window |

**Sequencing & rhythm** — generate and reshape timing:

| Module | What it does |
|--------|--------------|
| **Arp** | host-synced arpeggiator (9 play modes, divisions, gate, octaves, swing) |
| **SeqEuclid** | retrigger held notes on a Euclidean (Bjorklund) rhythm |
| **SeqRatchet** | split each note into N rapid retriggers |
| **Echo** | MIDI delay with feedback (decaying repeats) |
| **Strum** | spread simultaneous notes in time (up / down) |
| **Quantize** | snap note timing to a grid (rate + strength) |
| **Random** | clock-driven random-note generator over a range |
| **Ramp** | velocity crescendo / decrescendo over N notes |

**Dynamics & feel** — velocity and timing:

| Module | What it does |
|--------|--------------|
| **Velocity** | scale / offset note velocity (modulatable) |
| **VelCurve** | reshape velocity through a gamma curve |
| **VelClip** | clamp velocity into a [min, max] window |
| **Accent** | boost the velocity of every Nth note (downbeat) |
| **Humanize** | jitter timing and velocity for a played feel |
| **NoteLength** | force every note to a fixed gate length |

**Routing, probability & control** — gate, split and steer:

| Module | What it does |
|--------|--------------|
| **Chance** | per-note probability gate |
| **NoteFilter** | pass only notes within a note + velocity range (key zone) |
| **KeySwitch** | keyboard split — one zone plays, the other holds back |
| **Mono** | collapse to monophonic with note priority (last / lowest / highest) |
| **Latch** | toggle-hold notes — sustain until re-pressed |
| **FixedNote** | force every note to one pitch (drum triggering) |
| **Channel** | remap the output MIDI channel |
| **Unison** | layer each note as N copies, optional MPE channel spread |
| **Merge** | combine two note streams |
| **RandOctave** | randomly shift notes by ± octaves (probability) |
| **LFO / Env / SampleHold / Slew** | scalar control sources for the mod matrix |

A family of **cellular-automaton sequencers** (Game of Life, Brian's Brain, Langton's Ant) evolve
patterns from simple rules for generative, ever-changing chains.

# Harmony & rhythm primer

A little theory makes the harmony and rhythm modules far more powerful.

**Chords and voicings.** A chord is a set of notes stacked over a root — a major triad is the root,
its major third and its fifth. **Inversions** rotate which note is on the bottom (smoother voice
leading between chords); **spread** opens the voicing across octaves (lush, less muddy); **octave
doubling** reinforces the root. The `Chord` module does all of this from a single key, so you can
play a progression with one finger and let the voicing do the musical work.

**Scales and keys.** A scale is the set of pitches that "belong" in a key. The `Scale` module snaps
every incoming note to the nearest scale tone, so a wrong note becomes a right one. Place it *after*
your generators and harmonisers and nothing you produce can ever be out of key — which is why
generative patches (`Random` → `Scale`) always sound musical.

**Intervals and harmony.** `Harmonize` stacks fixed intervals (a fifth above, an octave below) for
parallel harmony; `Invert` reflects a melody around a pivot note for a mirror line; `Transpose`
shifts everything by semitones. Combine them for counterpoint from a single played line.

**Arpeggios.** An arpeggio plays a chord's notes one at a time. The `Arp` module's **mode** sets the
order (up, down, up-down, as-played, random, and more), the **division** sets the speed relative to
the host tempo, the **gate** sets how long each note rings, and **octaves** extend the pattern across
the keyboard. Hold a chord and the arp spells it out in time.

**Euclidean rhythm.** A Euclidean pattern distributes a number of hits as evenly as possible across a
number of steps — 3 hits in 8 steps gives the familiar `x..x..x.` tresillo. `SeqEuclid` gates your
notes on such a pattern, and because you set hits and steps independently of your loop length, two
Euclidean parts of different lengths drift in and out of phase for endlessly evolving polymetric
rhythms.

**Velocity and feel.** Real performances breathe. `Humanize` adds small random timing and velocity
variations; `Accent` pushes the downbeat; `VelCurve` reshapes how hard you have to play for a given
loudness; `Strum` spreads a chord's notes slightly in time like a guitar. A pinch of each turns a
robotic sequence into something that feels played.

# Example chains

- **Instant harmony** — `Chord → Scale`: play single keys; Chord voices them and Scale locks every
  resulting note to your key, so nothing is ever out, no matter what you press. Add **Strum** for a roll.
- **Generative pluck** — `Random → Scale → Arp`: Random makes notes over a range, Scale locks them to
  key, Arp orders them rhythmically — an endless in-key sequence. Modulate Random's range with an LFO
  for slowly shifting registers.
- **Polymetric arp** — `Arp → SeqEuclid`: set the Arp division and the Euclid step length differently
  so the two cycles drift against each other for evolving rhythms; add **Echo** for trailing repeats.
- **Humanised live keys** — `Chord → Humanize → VelCurve`: voiced chords with subtle timing/velocity
  jitter and a velocity curve matched to your controller, so a stiff performance feels played.
- **Bass + chords split** — `KeySwitch` into two branches: the low zone through `Mono → Transpose`
  (down an octave) for a bass line, the high zone through `Chord` for voiced chords — both hands from
  one keyboard, merged to one instrument.

# Modulation

A dynamic list of routes, each mapping a **scalar source → any block parameter** with a depth. Sources:

- **Soft keys** — an expandable pool of host-automatable macros (16 active by default, `+` / `−` to add
  or remove, count saved with the patch).
- **LFO** and **Env** block outputs, and **Random**.
- **Performance controllers** — mod wheel, pitch bend, aftertouch, velocity, expression (CC11), sustain
  (CC64).
- **MPE** — per-note bend, pressure and slide (CC74), read from the most recently active note's channel,
  so an MPE controller animates the transforms expressively (slide → chord type, pressure → velocity).

The same sources feed each block's **Mod** input. Routing a source/destination rebuilds the graph;
depth is a live, lock-free tweak, so you can ride a modulation amount in real time without glitching.

# Stereo

**⊞ Stereo** mirrors every block, cable and mod into an independent right-channel chain, kept in sync
as you edit while the two sides' knobs stay independent so you can dial width into the patch. **🔒 Lock**
keeps the mirrored knobs tracking the left channel — bidirectional and offset-preserving, so a width
you dialled in isn't reset to identical sides. Locked clone blocks are dimmed.

# Perform & macros

The **Perform** tab is a macros-and-pads view with no patching, for live play:

- **Preset Morph** — a 4-corner XY pad bilinearly interpolating four captured presets; **🎲** fills all
  four at random.
- **Orb** — the puck's *angle* picks one of eight random scenes, its *distance* scales intensity; **🎲**
  rolls new scenes, **⏺** records the gesture and **▶** loops it.
- **XY macro pads** — each drives a pair of soft keys, with per-pad **HOLD** / **SPRING**.
- **Macro knobs**, eight **Snapshots** of the macro surface, and a **🎲 Randomize**.
- **On-screen keyboard** — global **Key + Scale** quantize and a **Chord** selector (Off / Oct / 5th /
  Maj / Min / Maj7 / Min7 / Sus4 / Power) stacking intervals on each played key, plus a global arp
  (mode / rate / latch). The global arp is a quick performance layer; the **Arp** *module* is a
  patchable block you can place anywhere and modulate, with its own latch — use the global one to jam,
  the module when the arp is part of the design.
- **MIDI In** toggles — **Program** and **Bank**, both on by default: an incoming Program Change switches
  presets, with Bank Select (CC0 MSB / CC32 LSB) captured for the next Program Change.

# Presets

A factory bank ships with the plugin — Chord Arp, Strummed Chords, Euclidean Pulse, Fifth Harmonizer,
Arp Echo, Random Walk, Step Melody, Tone Cluster, Jazz Voicing, MPE Spread and more — spanning arps,
harmony, rhythm, generative and FX chains, so the factory set doubles as worked examples of the module
families. Your own patches save and load from the **Presets** tab, and the whole patch round-trips with
your host project.

# Tips & best practices

- Order matters. Put **Scale** *after* harmony modules so every generated note is locked to key, and
  put **Humanize** last so it isn't undone by a later quantiser.
- Use **⚡ EZ WIRE** to chain quickly, then reorder by re-patching cables — reordering is musical, not
  just cosmetic.
- A cable **Level** of `0` mutes a connection without deleting it — the fastest way to A/B a module's
  contribution.
- Assign performance moves (arp rate, chord type, transpose) to **soft keys** so they automate and live
  on the Perform pads.
- If repeats pile up, lower **Echo** feedback — note-offs are always scheduled safely, but very long
  tails can overlap into dense clusters by design.

# FAQ

**No notes reach my instrument.** Press **⚡ EZ WIRE**, or check that a chain reaches **Out A** / **Out
B** and that the plugin sits before the instrument in the signal path.

**My chords are out of key.** Add a **Scale** module at the end of the chain, set to your key and scale.

**How is the global arp different from the Arp module?** The Perform tab's global arp is a quick
performance layer over everything; the **Arp** module is a patchable block you place in the graph and
modulate, with its own independent latch.

**Does it support MPE?** Yes — per-note bend, pressure and slide are modulation sources, and **Unison**
can spread copies across MPE channels for per-note expression downstream.

**Which formats and OSes?** VST3, AU, CLAP and Standalone on macOS, Linux and Windows (AU is macOS
only; Windows ships VST3 + CLAP). It registers as a MIDI-effect category where the host supports it.

# Glossary

- **Note stream** — the flow of note events the plugin transforms before the instrument.
- **Block / module** — one note-transform unit: note inputs, a scalar Mod input, up to six params, one
  output.
- **Out A / Out B** — the two outputs that merge to the MIDI out (build two branches and combine them).
- **Scalar source** — an LFO/Env/Random/controller/soft-key value driving the mod matrix.
- **MPE** — per-note expression (bend, pressure, slide) usable as a modulation source.
- **EZ Wire** — one-click auto-routing of MIDI In → blocks → Out.
