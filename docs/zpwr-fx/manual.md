# Overview

zpwr-fx is a **modular patch-graph effects plugin** — not a fixed slot rack. A conventional
multi-effect gives you a chain of slots in a fixed order: input, then effect 1, then effect 2, then
output. zpwr-fx removes that assumption entirely. You are handed a bag of primitive DSP blocks
(oscillators, filters, delays, reverbs, dynamics, distortion, modulation, utilities) and a patch
field, and you wire them into whatever topology you want — the way the Eventide H3000 Factory let
engineers build algorithms from primitives rather than pick from a menu. The interface is a cyberpunk
WebView; the engine is the shared zpwr-patch-core graph, so the same patch concepts carry across
zpwr-synth and zpwr-midi-fx. It runs as VST3, AU, CLAP and Standalone on macOS, Linux and Windows.

What "modular" actually buys you, in practice:

- **Any-to-any routing.** Any block's output can feed any other block's input. There is no implied
  order; a reverb can sit *before* a distortion, a filter can read another filter, and you can split
  one source into three parallel chains and sum them back. The topology is yours.
- **Fan-out.** A single output can drive unlimited inputs. Split a signal to a dry path and several
  wet paths, process each differently, and recombine with a Mixer — true parallel processing instead
  of the serial-only chain of a slot rack.
- **Feedback.** Wire an output back to an earlier input and the graph resolves the loop with a
  one-sample delay. That single capability is the basis of combs, flangers, Karplus strings,
  resonators and self-oscillating reverbs — effects a strictly forward chain cannot express.
- **Modulation everywhere.** Every parameter has a modulation source and depth, and any signal in the
  patch — an LFO, an envelope, a macro knob, or another block's output — can be that source.
- **Layers.** Stack unlimited independent copies of the whole engine and mix them, for parallel
  timbres, wet/dry control or sheer thickness.

If you have never patched a modular before, start with **⚡ EZ WIRE** (it builds a working chain for
you) and rewire from there; if you have, the whole field is open.

# Core concepts

**Blocks (nodes).** The block is the unit of the patch. Each block has a type (Filter, Delay, LFO,
…), **three inputs** — In 1, In 2 and a dedicated **Mod** input — up to **six parameters**, and **one
output**. Every sample, a block reads its inputs, runs its algorithm, and writes a single output
value. Because there is exactly one output per block, you refer to a block by that output when you
patch — "the filter's output into the delay's input."

**Sources.** A "source" is anything an input can read. The full list: silence (an unpatched input
reads zero), the left and right audio inputs, an internal **Noise** generator, the macro **Soft
Keys**, the live **MIDI/MPE** dimensions (mod wheel, aftertouch, pitch bend, velocity, expression,
breath, sustain, note, and the MPE press / slide / bend), and **any block's output**. An unpatched
input is not "off" — it is silence (zero), which matters when a block sums its inputs.

**Signal vs control (there is no wall).** The same cables carry audio and control voltage. An LFO's
output is simply a signal that moves slowly; a filter's output is a signal that moves at audio rate.
Patch the LFO into a Filter's Mod input and it sweeps the cutoff; patch it into a VCA and it becomes
a tremolo; patch an audio-rate oscillator into the same Mod input and you get FM-style sidebands.
"Modulation" and "audio" are the same kind of thing moving at different speeds — which is exactly why
a modular can do things a fixed effect cannot.

**The graph and ordering.** On every structural edit (adding a block, drawing or cutting a cable) the
patch is re-sorted into dependency order, so each block runs only after the blocks it reads. When you
create a cycle — a cable from a later block back to an earlier input — the sort would be impossible,
so the loop is broken with a single-sample delay at that edge; the rest of the order is preserved.
This is why feedback "just works" and why a feedback patch has a one-sample latency in its loop (the
basis of its tuning for combs). Editing is lock-free: turning a knob is an atomic write that the
audio thread sees immediately; a structural change builds the new graph and swaps it atomically, so
audio never tears.

**Layers.** A layer is a complete copy of the engine with its own patch. Use layers for parallel
processing (a clean layer plus a crushed layer, blended), for octave or detune stacks, or for wet/dry
balance, and mix them in the **Mixer** tab with per-layer gain/pan and sends to the aux FX buses. A
layer is heavier than a block but lighter than a second plugin instance, and all layers share the
same transport and MIDI.

# Getting started

1. Open the plugin on an audio track. The **Patch** tab shows a grid of blocks, each with input jacks
   on one side and an output jack on the other, and a strip of macro knobs.
2. Press **⚡ EZ WIRE**. It auto-routes the input through whatever blocks you have to the output, so
   you hear signal immediately — the fastest way to confirm the plugin is passing audio before you
   start designing. It is non-destructive to your blocks; it only lays cables.
3. Press **+ ADD BLOCK** and pick a Filter, Delay or Reverb. Drag from one block's **output** jack
   onto another block's **input** jack to wire them. Drag the output to a *second* input to fan out.
4. **Double-click** any block to open its detail panel: its parameters, a modulation source + depth
   for each parameter, and (for the Expr block) a code editor.
5. Tweak knobs and listen. The cable feeding each block **glows** in proportion to that block's live
   level, so the gain structure of the whole patch is visible while you work — a dim cable is a quiet
   signal, a hot glow is a stage being driven hard.

Two reset buttons let you start over without losing your layout: **INIT** unplugs every cable and
modulation route but leaves all your blocks in place (ideal for re-patching a fixed set of blocks a
new way), and **🗑** blanks the whole patch back to empty.

# Patching cables

Wiring is direct manipulation:

- **Wire** — drag an output jack onto an input jack.
- **Disconnect** — drag an input jack away and drop on empty space; that input returns to silence.
- **Rewire** — drop an existing connection onto a different output to move it.
- **Fan out** — drag from the same output again to another input; an output feeds any number of
  destinations with no penalty to the original path.
- **Cable level & colour** — **right-click** a cable for a per-cable **level** (a gain on just that
  connection) and a **colour** swatch. Level is the main tool for balancing a patch by hand: a value
  of `0` mutes the connection without deleting it (useful for A/B-ing), and the cable's brightness and
  width track the level so you can read it at a glance. Colour is cosmetic and saved with the patch.

A subtlety worth internalising: when several cables land on the *same* input, they **sum**. That is
how you mix without a Mixer block — fan three outputs into one input and it adds them (subject to each
cable's level). And because the **Mod** input is just another input, you can treat it as a per-block
modulation bus: patch a control signal there in addition to the per-parameter mod slots.

# The interface

The editor is a set of tabs, each a different view of the same patch:

- **Patch** — the main workspace. The node grid with drag-to-wire cables, the macro soft-key strip,
  and the detail panel for the selected block. It carries **⚡ EZ WIRE**, **INIT**, **🗑**, and the
  **Stereo** / **🔒 Lock** toggles. The cable glow makes gain structure visible here.
- **Synth** — a fixed-layout view that shows every block's knobs in a grid with no cables, like a
  Serum or Spire panel. Once your routing is set, this is the fastest surface for sound design because
  every control is visible at once.
- **Perform** — macros, XY pads, Morph and Orb only, with no patching. Everything here drives
  host-automatable parameters, so it works with the editor closed and records as automation; this is
  the live-performance and automation surface.
- **Clip** — draw a MIDI clip and play the patch from it, with key/scale and key-trigger, to audition
  a patch melodically without an external sequencer.
- **Mod Matrix** — every modulation connection in the patch gathered into one editable list, so you
  can audit and rebalance the whole modulation scheme without hunting through block panels.
- **Mixer** — per-layer channel strips (gain, pan, mute, solo) with sends to the aux FX buses, the aux
  returns and the master strip, plus peak and LUFS metering — the mixdown stage for multi-layer
  patches.
- **Browse** — a tagged preset browser: search, save, tag and load patches, filtering by bank, type,
  style and character.
- **Settings** — master in/out and bypass, **Auto Gain Stage** and its target, the brickwall limiter,
  scale/key quantize, UI scale and interface toggles.
- **About** — version and engine info.

# Modulation in depth

Modulation is patching by another name. There are two routes:

1. **Per-parameter mod slot.** In a block's detail panel, every parameter carries a **source** and a
   **depth**. The effective value is `base + source × depth`, computed in the parameter's own units.
   This is the key to predictable modulation: the same LFO at depth `2400` on a pitch parameter sweeps
   two octaves (pitch is in cents), while at depth `0.2` on a mix parameter it nudges the blend by a
   fifth of its range. Choose depth in the units of the thing you are modulating.
2. **Mod input.** Patch a control signal straight into a block's **Mod** input for a per-block
   modulation bus that sums with the parameter slots.

Any source is fair game: an **LFO** block (for cyclic movement), an **Envelope** follower (for
dynamics-driven movement), a **macro Soft Key** (for hand or automation control), **Noise** (for
randomness, often via a sample-and-hold), a **performance controller**, or **another block's output**.
That last one is the deep part: because modulators are ordinary nodes in the dependency graph, you can
modulate a parameter with a *processed* signal — a filtered, delayed or distorted version of something
else — and the engine orders it correctly like any cable. Audio-rate modulation (one oscillator into
another's Mod) gives you FM and cross-modulation timbres, not just slow sweeps.

The **Mod Matrix** tab is the bird's-eye view: it lists every route as (source → destination, depth)
so you can see and adjust the entire modulation design at once.

# Macro soft keys

The **Soft Keys** are an expandable pool of macro knobs — 16 active by default, with `+` / `−`
controls above the knob row to change the active count (saved with the patch). They exist for one
structural reason and one creative reason:

- **Structural:** a plugin's host-automatable parameter list must be fixed, but a patch's blocks and
  routing change constantly. The soft keys are that fixed, host-facing list. The patch itself — block
  types, cables, parameters — is plugin state the editor changes and the plugin saves; the soft keys
  (plus master in/out/bypass) are what your DAW sees and automates.
- **Creative:** because a soft key is patchable anywhere as a modulation source, one knob can drive
  many destinations at once. Assign a single soft key to a filter cutoff, a delay mix and a drive
  amount, and you have a one-knob macro that opens the whole patch up — and it records as automation
  and appears on the Perform surfaces.

This is exactly the H3000 "soft function key" model: a small set of performance controls mapped into
the guts of an algorithm.

# Gain staging

Because cable levels stack and inputs sum, it is easy to drive the signal *between* blocks well past
0 dBFS — which would clip digitally. Two per-block settings (both **on by default**) prevent that:

- **Auto Gain Stage** rides levels. Each block's output runs through a peak follower with a fast
  attack and a slow release; its smoothed gain (never above 1) pulls the block down toward the
  **Auto-Gain Target** ceiling. The effect is gentle, automatic level-matching between stages as you
  build, so one hot block doesn't blow out the next.
- **Soft Clip** is the guarantee the follower can't make alone. The follower's ~2 ms attack lets a
  fast transient through before it ducks, and cable gains are applied *downstream* of the staging, so
  something can still exceed the ceiling momentarily. Soft Clip is an instant, sample-accurate tanh
  bound at the same ceiling on every block output — it catches whatever slips past, and because it is
  a tanh it saturates gently rather than clipping squarely.

Both are per block and independent, and the cable glow tracks each block's post-staging level. Turn
either off in Settings when you *want* raw, intentional gain or clipping. They are separate from the
master **Brickwall Limiter**, which is a single hard ceiling on the final summed output (the last line
of defence, not a per-stage tool). MIDI-effect blocks carry no audio level, so neither stage applies
to them.

# The Expr block

The **Expr** block runs a short per-sample expression you write in its detail panel — an escape hatch
for anything the fixed blocks don't cover, edited live while audio runs:

- **Variables:** `in` (In 1), `t` (running time), `sr` (sample rate), `p0`–`p7` (where `p0`–`p5` are
  the six knobs, `p6` is In 2 and `p7` is the Mod input), `s0`–`s3` (four state variables that persist
  across samples, for filters and feedback), and the constants `pi`, `tau`, `e`.
- **Functions:** trig (`sin cos tan tanh`), shaping (`floor frac wrap saw sqr tri`), math
  (`min max pow fmod clamp lerp`), control (`if step noise rand`), and the standout **`tap(d)`** — the
  block's own output `d` samples ago, with fractional interpolation, which makes combs, Karplus
  strings, delays and feedback trivial to express.
- **Safe by construction:** the language has no loops, allocation or arbitrary memory access in the
  audio path; the output is sanitised so any NaN or Inf becomes 0; and a program that exceeds the
  complexity limit simply fails to compile rather than glitching audio.

Worked snippets:

- **Wavefolder** — `out = sin(in * (1 + p0 * 8) * pi)`: as p0 rises the input is folded into more
  harmonics.
- **Bit reducer** — `out = floor(in * (1 + p0 * 32)) / (1 + p0 * 32)`: quantises amplitude to a
  staircase whose steps p0 controls.
- **Tuned comb / pluck** — `out = (in + tap(sr / (60 + p0 * 1000))) * p1`: adds a delayed copy of the
  output tuned by p0, with p1 as the feedback/decay — feed it noise and it rings at a pitch.
- **Sample-and-hold** — `s0 = if(p6 > 0.5, noise(), s0); out = s0`: holds a random value, re-sampling
  each time the clock on In 2 (p6) goes high.

# Worked examples

**Filter sweep (auto-wah).** Add a Filter and an LFO. Wire In L → Filter → Out. In the Filter, set the
cutoff's mod **source = LFO** with a depth of a couple of octaves and pick a band-pass mode; set the
LFO Rate slow. The cutoff now sweeps cyclically. Swap the LFO for an **Envelope** follower of the
input and the sweep tracks your playing dynamics instead — a real auto-wah.

**Stereo slap.** Turn **Stereo** on and leave **🔒 Lock** off so the two sides are independent. Add a
Delay on each side and set slightly different Times left and right; feed each side's input straight to
its output as well so the dry passes. The small L/R time difference widens the slapback across the
stereo field.

**Comb resonator.** Add an Expr block and wire its output back to its own In 1. Use
`out = (in + tap(sr / (60 + p0 * 1000))) * p1`. In 1 is the live input plus a tuned, fed-back tap, so
noise or transients ring at a pitch set by p0, with p1 as the resonance/decay — a string you tuned by
hand.

**Parallel crush.** Open the Mixer and add a second layer. Keep layer 1 clean; on layer 2 add a
Crusher and a Drive. Blend the dirty layer under the clean one with the layer faders — parallel
distortion that adds grit while keeping the body and transients of the dry signal intact.

**Self-oscillating space.** Add a Reverb and feed a little of its output back to its input through a
Filter and a low cable level. Raise the feedback cable level slowly: the reverb tips toward
self-oscillation, the filter shapes the resonance, and you have an evolving drone — the kind of patch
a fixed reverb slot can never make.

# Perform & macros

The **Perform** tab is a play-the-patch surface that drives only host-automatable parameters, so it
runs with the editor closed and everything you do records as automation:

- **Preset Morph** — a 4-corner XY pad (A/B/C/D) that bilinearly interpolates between four captured
  patches as you move the puck. The X/Y axes are reserved host parameters, so the morph automates and
  recalls; **🎲** loads a random preset into all four corners for instant exploration.
- **Orb** — a radial pad where the puck's *angle* selects a scene and its *distance* sets that scene's
  intensity. **🎲** rolls a fresh random scene set, **⏺** records the puck's motion as you drag, and
  **▶** loops the recording back through the host-automatable parameters — a hands-free gesture turned
  into recorded, editable automation.
- **XY macro pads** — each drives a pair of soft keys, with a per-pad **HOLD** / **SPRING** toggle:
  HOLD leaves the dot where you drop it, SPRING snaps both axes back to centre on release for
  momentary moves.
- **Macro knobs** — the soft keys exposed as plain knobs.
- **Scenes** — snapshot slots for the whole macro surface: click to recall, right-click to clear.
- **Controls band** — a global randomise, an arpeggiator (mode / rate / latch), and **scale + key**
  quantize plus a **Chord** that stacks extra intervals on each key played on the on-screen keyboard.

The throughline: every Perform control writes to soft keys (host params), so a live performance and a
recorded automation lane are the same thing.

# Stereo & stereo lock

- **Stereo** (off by default) mirrors the entire patch graph to a second, right-channel copy, so each
  block processes the left and right channels independently. Dial a per-knob offset between the two
  sides for width — slightly different delay times, filter cutoffs or detune amounts left vs right.
- **🔒 Lock** keeps the mirrored (clone) blocks tracking the left channel. It is **bidirectional and
  offset-preserving**: moving a left knob moves its clone, and moving a clone moves the left, each by
  the *same delta* — so the L/R offset (the width you dialled in plain Stereo) is preserved rather than
  collapsed. Turn Lock on with no offset for a perfect `L = R` mono-in-stereo. Both states save with
  the patch, and locked clone blocks render dimmed so you can see which side is following.

# MIDI & MPE

The plugin accepts MIDI and MPE; MPE is parsed and aggregated to the most recently played note. Every
MIDI dimension is exposed as a modulation source — mod wheel, aftertouch (channel and poly), pitch
bend, velocity, expression, breath, sustain, note, and the MPE press / slide / bend — so you can play
an effect expressively from a controller (mod wheel to delay mix, aftertouch to filter cutoff, and so
on). Two response toggles, both **on by default**:

- **Program Change** — an incoming Program Change message selects the matching preset. Turn it off to
  ignore Program Change (e.g. when your controller sends it unintentionally).
- **Bank Select** — CC0 (MSB) and CC32 (LSB) are captured and combined with the next Program Change as
  `bank × 128 + program` for banked preset addressing. Turn it off and Program Changes address presets
  0–127 directly.

# Presets & browsing

Factory patches ship in code as starting points — **Stereo Slap, Filter Sweep, Comb Resonator,
Wavefolder** — each a small, legible example of a different technique. Save your own from the
**Browse** tab with facet tags (bank / type / style / character); the browser's filters are driven by
those tags, so a well-tagged library stays searchable. The full plugin state — the patch plus every
parameter and soft-key value — round-trips through your host's project file, and an incoming Program
Change can recall presets live for set-based performance.

# The module library

The block palette is the full shared audio pack — over a thousand module types. They fall into
families you combine freely:

- **Oscillators & sources** — analog, wavetable, FM, additive, supersaw, sync, vector and physical
  models, plus a Noise generator. In an effect context they are carriers for ring modulation, test
  tones, sub-bass reinforcement, or — fed by the input — the basis of vocoder-style work.
- **Filters** — state-variable (low-pass, high-pass, band-pass, notch), Moog and diode ladders,
  formant filters, comb filters, and the modeled analog filters below. Each has a Mod input so the
  cutoff can be swept by an LFO, envelope or another signal.
- **Delays** — clean, damped-feedback, tape, ping-pong, multi-tap and granular delays. Modulating the
  delay time turns a delay into a chorus or flanger; long feedback turns it into a resonator.
- **Reverbs** — rooms, halls, plates, springs, and shimmer/feedback reverbs for everything from a
  tight ambience to an infinite wash.
- **Distortion & saturation** — soft drives, tube and diode clippers, wavefolders, bit and
  sample-rate crushers, and the modeled pedals below.
- **Dynamics** — compressors, limiters, gates, transient shapers, and the modeled studio units below.
- **Modulation effects** — chorus, flanger, phaser, tremolo, ring modulator and auto-pan.
- **Pitch & spectral** — pitch shift, frequency shift, harmonisers and spectral processors.
- **Utilities** — mixers, gains, math, sample-and-hold, slew limiters, logic, panners and the routing
  helpers that glue a patch together.

The **Module Reference** (linked from the docs hub, and the full catalogue at the back of this manual)
documents every block with its inputs, parameters and a description, generated from the live registry
so it never drifts from the build.

# Touring the module library

This is a guided walk through the families, naming standout blocks so you know what to reach for.
Every block here is real and documented in the catalogue at the back; this is the "what should I
grab?" view.

**Filters.** Beyond the plain `Filter` (a state-variable LP/HP/BP/notch) the library is deep:
`Ladder` and `DiodeLadder` for Moog and 303 character, `MS20Filter`, `SteinerParker`,
`OberheimSEM` and `WaspFilter` for famous analog voicings, `Formant` and `VocalFilter` for vowel
sounds, `CombBank` and `FixedFilterBank` (a Moog 914) for fixed resonant banks, `GraphicEQ`, `EQ`
and `ParaEQ` for surgical tone, `AutoWah` and `DJFilter` for performance sweeps, and a whole set of
**resonators** (`BarReson`, `BellReson`, `GlassReson`, `DrumheadReson`, `HarpReson`) that ring a
struck or noisy input into tuned, physical tones. Reach for a resonator when you want a delay or
noise burst to *sing* at a pitch.

**Delays.** `Delay` is the workhorse; `DubDelay` adds the filtered, saturating feedback of a tape
echo, `PingPong` bounces L/R, `Multitap` and `Rainmaker` spray rhythmic taps, `GrainDelay` and
`Morphagene` chop the buffer into grains, `Looper` and `Freeze` capture and hold, and `BBDDelay`
models a bucket-brigade's gentle hiss and warble. The modulation effects live here too because they
*are* short modulated delays: `Chorus`, `Ensemble`, `Flanger` and `PeakFlanger`. If you want
movement, a delay is usually the root of it.

**Reverbs.** `Reverb` and `Plate` for bread-and-butter space, `Spring` for drip and boing,
`Shimmer` and `Crystals` for pitched, ascending tails, `Convolution` for sampled spaces, `ErbeVerb`
and `Massive` for modeless, ambient washes, `GatedVerb` for the 80s chop, `ReverseVerb` for swells,
and `Gravity` / `Aetherizer` for unreal, infinite atmospheres. Feed a little reverb back through a
filter for self-oscillating drones.

**Distortion & saturation.** `Drive` and `Fuzz` for the staples, `Bitcrush` and `Decimator` for
digital grit, `Diode` and `Chebyshev` for specific harmonic curves, `Exciter` for sheen, `Lofi` and
`Erosion` for degradation, `CabSim` / `AmpSim` for guitar tone, and `DrumBuss` for one-stop drum
glue-and-grit. Pair any of them with a Filter before and after to shape what gets distorted and what
survives.

**Dynamics.** `Compressor`, `Limiter` and `Gate` cover the essentials; `OTT` is the famous multiband
upward/downward squash, `MultiComp` and `MBDynamics` give per-band control, `Transient` shapes attack
and sustain, `DeEsser` tames sibilance, `Maximizer` and `Squash` push loudness, `Ducker` / `Pump` do
sidechain pumping, and `EnvFollow` turns any signal into a control source for your own dynamics tricks.

**Modulation sources.** The `LFO` is the start, but the library runs deep into **chaos**: strange
attractors like `Lorenz`, `Chua`, `Clifford`, `Aizawa` and `ChenLee` give organic, never-repeating
modulation, and `Clock` / `ClockDiv` / `ClockMult` keep things in time. Patch a chaotic source at low
depth into tuning or cutoff for life an LFO can't give.

**Oscillators & generators.** Over three hundred of them — analog and wavetable cores, FM and
additive voices, physical models (`Bowed`, `Blown`, `BowedString`), drums and percussion (`Bongo`,
`Agogo`, `Anvil`, `Basimilus`), and sound-effect generators (`Applause`, `Birds`, `AirHorn`,
`Alarm`). In an effect they are carriers for ring-mod, sub reinforcement, or test tones.

**Stereo.** `MidSide` for M/S processing, `Haas` for width by tiny delay, `Imager` / `StereoWidth`
for spread, `AutoPan` and `Rotate` for movement, `Binaural` and `Crossfeed` for headphone realism,
and `MonoMaker` to keep the low end centred.

**Pitch.** `PitchShift` and `Harmonizer` for intervals, `H910` and `MicroShift` for the classic
doubling and detune, `Octaver` / `Octavox` for sub and stacked octaves, `FreqShift` for inharmonic
metallic shifts, and `PitchCorrect` for tuning.

**Spectral.** `SpecFreeze` to hold a spectrum, `SpecBlur` / `SpecMorph` for smeared evolving texture,
`SpecGate` and `Soothe` for spectral cleanup, and `MatchEQ` to match one signal's tone to another.

**Utilities.** The connective tissue: `Mixer`, `Gain`, `Constant`, math (`Clamp`, `Average`,
`Compare`, `Counter`), `SampleHold` and `Slew` for shaping control signals, `ClockDiv` / `ClockMult`
for timing, and `Analyzer` to see what's happening. You'll use these constantly to glue a patch
together.

# Analog models

A large portion of the library is **component-level analog emulation** — modeled from the circuit
topology rather than from impulse responses or samples — so the blocks respond to drive, bias and
dynamics the way the originals do. Pushing the input harder pushes the model into its non-linear
region; backing off cleans it up. They are grouped by the gear they model:

- **Filters** — Minimoog ladder, Jupiter-8, MS-20, Oberheim SEM, EMS VCS3, Wasp, TB-303.
- **Compressors & limiters** — 1176, LA-2A, LA-3A, Fairchild, dbx 160, SSL bus, API 2500, Distressor,
  Sta-Level.
- **EQs & front-ends** — Pultec, API 550, Neve 1073, SSL E/G, Manley, Helios, GML, plus preamp and
  tape stages.
- **Pedals** — Tube Screamer, RAT, Big Muff, Klon, DS-1, MXR, Octavia, OCD, Metal Zone.
- **Amps & cabs** — Fender, Marshall, Vox and Mesa voicings.
- **Time & space** — EMT 140 plate, AKG BX20 spring, Roland RE-201 Space Echo, Binson Echorec,
  Memory Man, plus enhancers, phaser/tremolo and chorus.

Use them like any block: feed the input, set the drive/character, and modulate the controls. Because
they are real topologies you can stack them — a 1073-style pre into an 1176-style compressor into a
Pultec-style EQ — and they interact the way a hardware chain would.

# Tutorials

**A dub delay throw.** Add a Delay and a Filter. Wire In L → Delay → Filter → Out, and also feed
In L → Out so the dry passes. Set the Delay Time to a musical division and its Feedback fairly high;
make the Filter a band-pass after it so each repeat darkens as it trails. Assign one **soft key** to
the Delay Feedback and another to its Mix, then automate them on the **Perform** tab to throw the
delay in and out of the mix live — the classic dub move, built from primitives.

**A flanger from scratch.** Add a Delay with a very short Time and an LFO. Route the LFO into the Delay
Time mod with a small depth and a slow Rate, then mix the delayed signal back with the dry — the
swept short delay is a flanger. Raise the Delay Feedback for resonance, and speed the LFO up to cross
into chorus territory. You now understand why flange and chorus are the same effect at different
settings.

**A wavefolder lead processor.** Add an Expr block with `out = sin(in * (1 + p0 * 8) * pi)`. Patch an
**Envelope** follower of the input into p0 so the fold amount tracks dynamics — quiet notes stay
clean, loud notes bloom into harmonics. Follow with a Filter to tame the top and a touch of Reverb for
space.

**Sidechain-style ducking.** Add an Envelope follower reading a control source (or the input) and a
VCA on your main signal, then route the follower's output into the VCA so the main signal ducks when
the source is loud. You have built a sidechain compressor from a follower and a VCA — and you can
shape its attack/release by filtering the follower's output.

**Parallel grit.** Use two layers. Keep layer 1 clean. On layer 2 add a modeled pedal (RAT or Big
Muff) and a Filter to carve the distorted band. Blend layer 2 under layer 1 with the layer faders, so
the grit adds harmonics and presence without losing the dry signal's body and transients.

# Modulation cookbook

- **Vibrato** — LFO → an oscillator's pitch mod, small depth, ~5 Hz.
- **Auto-wah** — Envelope follower of the input → Filter cutoff mod.
- **Tremolo** — LFO → a VCA, or LFO → a Gain block.
- **Stepped random** — Noise → a Sample-and-Hold clocked by an LFO → any parameter.
- **Analog drift** — a very slow LFO or smoothed Noise at tiny depth on tuning or cutoff.
- **Velocity → brightness** — MIDI velocity → Filter cutoff mod, so harder notes open up.
- **Mod-wheel macro** — mod wheel → a soft key, then that soft key → several parameters at once.
- **Cross-modulation** — an audio-rate oscillator → another oscillator's (or filter's) Mod input for
  metallic, FM-style timbres.

# A short DSP primer

If the blocks make more sense when you know what's happening inside, here is the quick theory — just
enough to patch with intent.

**Filters** remove or emphasise frequencies. A *low-pass* keeps lows and rolls off highs (darkening);
a *high-pass* does the opposite (thinning); a *band-pass* keeps a slice; a *notch* removes one. The
**cutoff** is where the rolloff begins and **resonance** is a boost right at the cutoff — push
resonance high and a filter rings, even self-oscillates into a sine. A *comb* filter adds a signal to
a short-delayed copy of itself, reinforcing some frequencies and cancelling others (the basis of
flanging and tuned resonance). A *formant* filter parks several resonant peaks where a human voice's
do, producing vowels.

**Delays** store the signal and play it back later. A long delay is an echo; shorten it and add
**feedback** (output fed back to input) and the repeats blur into resonance; shorten it to a few
milliseconds and modulate the time and you get **flanging** (a sweeping comb) or **chorus** (a
detuned thickening). All three are the same mechanism at different time scales.

**Reverb** is what a thousand tiny delays sound like — the dense, decaying reflections of a space.
**Size** sets how big the room feels, **decay** how long the tail rings, and **damping** how quickly
the highs die away (a bright tiled room vs a soft carpeted one).

**Distortion** reshapes the waveform, adding harmonics that weren't there. A gentle *soft clip*
rounds the peaks (warmth); a *hard clip* squares them (aggression); a *wavefolder* reflects peaks
back on themselves (bright, metallic, unpredictable); a *bit/sample-rate crusher* quantises the
signal in level or time (digital grit). More drive means more harmonics.

**Modulation** is a slow (or fast) signal changing a parameter over time. An **LFO** is a repeating
shape (sine, triangle, square, ramp); an **envelope** is a one-shot contour triggered by an event;
**noise** and **chaos** are unpredictable. Patch any of them to a parameter and that parameter moves.
Move it fast enough (audio rate) and you cross from "modulation" into "synthesis" — FM, ring
modulation, sidebands.

**Dynamics** change level based on level. A **compressor** turns down what's too loud (evening out a
performance or gluing a mix); a **gate** turns down what's too quiet (removing bleed); a **limiter**
is a brick wall the signal can't cross; a **transient shaper** independently scales the attack and
the sustain. An **envelope follower** measures a signal's loudness and hands it to you as a control
source — the seed of every sidechain trick.

# More techniques

**Tape-style chorus.** A short `Delay` (10–25 ms) with its time gently swept by an `LFO`, mixed 50/50
with the dry. Two such delays at different LFO phases, panned left and right, give a lush `Ensemble`.

**Frozen pad from a transient.** Send a sound into `Freeze` (or `SpecFreeze`); capture a moment and
hold it into an infinite bed, then filter and reverb it — an ambient pad grown from a single hit.

**Rhythmic gate.** Patch a square `LFO` (or a `Clock`-derived signal) into a `VCA` on your full
signal so it chops in time — the trance gate. Vary the LFO shape for different gate envelopes.

**Resonant ping.** Patch a trigger or a noise burst into a high-resonance `BarReson` or `BellReson`,
or a `Filter` with resonance near self-oscillation; each hit rings at the tuned pitch — instant
tuned percussion you can play from MIDI.

**Lo-fi tape bed.** Chain `Lofi` → `BBDDelay` → a gentle `Wow`/drift LFO on the delay time → a
band-pass `Filter`. The result is a worn, warbling, band-limited texture under anything.

**Spectral wash.** `SpecBlur` or `SpecMorph` on a sustained source smears it into an evolving cloud;
follow with `Shimmer` for an ascending, pitched tail.

# A cookbook of complete patches

Ten finished patches you can build start to finish. Each names real blocks; wire them in the order
written and tweak to taste.

**1. Vocal doubler.** `In L → H910` (or `MicroShift`) with a few cents up, `In L → H910` a few cents
down, pan the two copies hard left and right, mix the dry up the middle. Add a slow `Chorus` across
both for thickness. Instant wide, natural doubling for vocals or leads.

**2. Eighties gated snare.** `In L → Reverb` (`Plate`, large) `→ GatedVerb` (or a `Gate` keyed by the
dry input's `EnvFollow`). The tail blooms then chops off hard — the unmistakable 80s drum ambience.

**3. Dub siren.** An `Osc` (sine) with its pitch swept by a slow `LFO`, into a `DubDelay` with high,
filtered feedback, into a `Spring` reverb. Ride the delay feedback on a soft key for live dub throws.

**4. Multiband saturator.** Split `In L` into three `Crossover` bands; on each band add a different
`Drive`/`Diode`/`Chebyshev` flavour and a `Gain`, then sum with a `Mixer`. Distort the lows gently,
the mids harder, and add `Exciter` sheen on top — controlled, band-aware grit.

**5. Shimmer pad machine.** `In L → Reverb` (long) with a `PitchShift` (+12) in the reverb's feedback
path, fed back through a `Filter`. Each pass rises an octave into an angelic, infinite `Shimmer`.
Hold a chord and let it bloom.

**6. Lo-fi tape loop.** `In L → Lofi → BBDDelay` (medium time, moderate feedback) with a slow `LFO`
on the delay time for wow, into a band-pass `Filter`, with a sprinkle of `Erosion`. Warbling,
band-limited, nostalgic.

**7. Sidechain pump on a bus.** `EnvFollow` a kick (or a `Clock`-driven `LFO`) → a `VCA` (or `Pump`)
on your full signal. The signal ducks on every beat — the house/EDM pump, built from a follower and a
VCA so you control the exact shape.

**8. Robot voice.** `In L → RingMod` with a fixed-frequency `Osc` carrier (try 200–800 Hz), into a
`Formant` filter for vowel character, a touch of `Bitcrush`. Metallic, talking-machine timbre.

**9. Granular cloud.** `In L → GrainDelay` (or `Morphagene`) with small grain size and high density,
its position swept by an `LFO`, into a `DiffuseDelay` and `Reverb`. A shimmering, textural cloud from
any source.

**10. Self-playing drone.** An `Osc` → `Ladder` filter with high resonance, the filter cutoff modulated
by a slow `Lorenz` chaos source, into a long `ErbeVerb`. Patch a little of the reverb output back
through a `Filter` to the input at a low cable level. It evolves forever, never repeating — set it and
listen.

# Mixing & mastering with zpwr-fx

Because the same library carries studio-grade dynamics and EQ, the plugin doubles as a channel strip
or mastering chain you wire yourself:

- **Channel strip:** `Gate` (clean up bleed) → `Compressor` (even the level) → `EQ`/`ParaEQ` (tone)
  → a gentle `Drive` or modeled `Tube` (harmonics). Reorder to taste — EQ before or after the
  compressor are different sounds.
- **Bus glue:** a slow `Compressor` or the `SSL`-style bus comp at a low ratio across a group, with a
  touch of `Exciter` and `StereoWidth`.
- **Master chain:** `DynEQ`/`MatchEQ` for tonal balance → multiband `OTT`/`MultiComp` (gently!) →
  `Maximizer` or `Limiter` for loudness, with the master `Brickwall Limiter` as the true ceiling.
  Watch the **LUFS** meter in the Mixer.
- **Mid/side:** put a `MidSide` encoder first and a decoder last, and process the mid and side paths
  independently in between — widen the sides, tighten the middle.

# Tips & best practices

- Start with **⚡ EZ WIRE** to get sound, then rewire piece by piece — it is faster than building from
  an empty field.
- Read the **cable glow** constantly. A dim cable into a block means it is being driven quietly; a
  blown-out glow means you are slamming the next stage. Use cable **levels** to balance instead of
  reaching for a Gain block every time.
- Leave **Auto Gain Stage** and **Soft Clip** on while building; switch them off only when you want
  raw, intentional clipping or saturation.
- Reach for **layers** when you want parallel processing — don't force a parallel idea into a serial
  chain.
- Put anything you will tweak live on a **soft key** so it records as automation and shows up on the
  Perform surfaces.
- Build feedback patches carefully: start the feedback cable **level** low and raise it gradually,
  since the one-sample loop can run away into self-oscillation faster than you expect.

# FAQ

**I get no sound.** Press **⚡ EZ WIRE**, or check that something is wired to the output jack — the
output must have an incoming cable, and the chain must trace back to the input or a source.

**A patch is clipping.** Confirm Auto Gain Stage / Soft Clip are on (Settings), lower the cable levels
feeding the hot stages, or pull Master Out down. The master Brickwall Limiter is the final ceiling but
shouldn't be doing the heavy lifting.

**Can I use it as an instrument?** Yes — add oscillators driven by the MIDI **note** source and it
plays like a synth; or use zpwr-synth, which is this same engine built for polyphony.

**Where do my presets live?** Saved patches appear in the **Browse** tab with their tags, and the whole
patch and its parameters also save inside your host project, so a session reopens exactly as you left
it.

**Why does my feedback patch hum at a pitch?** The one-sample (plus your delay) loop tunes the
feedback to a frequency; that is the comb/Karplus mechanism. Shorten the delay for a higher pitch,
lengthen it for a lower one, and lower the feedback level to shorten the ring.

**Which formats and OSes?** VST3, AU, CLAP and Standalone for macOS, Linux and Windows (AU is macOS
only; Windows ships VST3 + CLAP).

# Mouse & keyboard reference

- **Drag output → input** — wire a cable.
- **Drag input → empty** — disconnect (the input returns to silence).
- **Right-click cable** — open the level + colour editor; level `0` mutes without deleting.
- **Double-click block** — open its detail panel (parameters, mod slots, code).
- **+ ADD BLOCK** — add a block; select a block and press delete to remove it.
- **⚡ EZ WIRE** — auto-route input → blocks → output.
- **INIT** — unplug all cables/mods, keep blocks. **🗑** — blank the patch.

# Glossary

- **Block / node** — one DSP unit in the patch: three inputs (In 1, In 2, Mod), up to six parameters,
  one output.
- **Source** — anything an input can read (audio in, Noise, a soft key, a MIDI dimension, another
  block's output). An unpatched input reads silence.
- **Mod (CV)** — a control signal modulating a parameter as `base + source × depth`, in the
  parameter's units.
- **Soft key / macro** — a host-automatable knob, also patchable as a modulation source; the fixed
  host-facing parameter list.
- **Layer** — a full copy of the engine with its own patch, mixed with the other layers.
- **Feedback** — a cable from a later block back to an earlier input, resolved with a one-sample delay.
- **Fan-out** — one output feeding multiple inputs.
- **EZ Wire** — one-click auto-routing of input → blocks → output.
- **Brickwall Limiter** — the single hard ceiling on the final summed output (distinct from per-block
  Soft Clip).
