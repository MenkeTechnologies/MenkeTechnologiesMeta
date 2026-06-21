# Overview

zpwr-synth is a **fully modular patch-graph synthesizer**. In a normal synth the voice is a fixed
path — oscillators, then a filter, then an amplifier — and you adjust knobs along that path. Here
there is no fixed path: each voice is a **free patch graph** you build from oscillators, filters,
envelopes, modulators and shapers, exactly like wiring an effect in zpwr-fx, but the whole graph is
instantiated per note across a polyphonic voice pool. On top of that you can stack up to **16 layers**
(each its own voice pool and patch), route any source to any parameter through the mod matrix, and run
the summed output through a master + 2-aux **FX-bus rack** that carries the full shared audio-effects
pack. It runs as VST3, AU, CLAP and Standalone on macOS, Linux and Windows.

The payoff of "modular" for a synth: a single oscillator can modulate another at audio rate (FM you
wired yourself), an envelope can drive anything (not just amp and filter), feedback loops let you
build Karplus strings and resonators, and you decide where the filter sits — before the VCA, after
it, in parallel, or twice.

# Core concepts

**The voice graph.** You design one patch — a graph of nodes — and the engine runs a copy of it for
each held note. Each node has a type, inputs, up to eight parameters and one output. Generators read
the played **Note**, **Gate** (held = 1, released = 0) and **Velocity** directly from the voice, so
the same patch definition becomes polyphonic automatically: press a chord and the graph runs once per
note, each with its own note number, gate and envelopes.

**Outputs.** The patch has two outputs that select the left/right sources feeding the layer. Anything
in the graph can be an output — the raw oscillator (for a buzzy lead), a VCA (for a shaped voice), a
filter, or a sum of several paths.

**Signal vs control.** As in zpwr-fx, the cables carry both audio and control with no hard wall. An
envelope or LFO is just a slow signal you patch into a parameter's mod input or a VCA; an oscillator
patched into another oscillator's mod input is audio-rate FM. The same wire, different speed.

**Layers vs unison.** Two different ways to thicken sound. A **layer** is an independent voice pool
running its own copy of the patch — use it for parallel timbres, octave or detune stacks, or splits,
and balance layers in the mixer feeding the FX-bus rack. **Unison** is per-oscillator: every
oscillator has its own **Voices** (1–11) and **Detune** controls that sum detuned copies *within a
single voice*, for supersaw width without spending extra polyphony. Reach for unison for width inside
a sound, layers for stacking whole timbres.

**Modulation is the patching.** There is no separate "mod section": any LFO, envelope, stepped/noise
CV source or macro soft key, patched into a node input or routed to a parameter, is modulation.

# Getting started

1. Open the plugin on an instrument track and play a note (the on-screen keyboard is at the bottom, or
   use the QWERTY home row — click a key once to focus, then type).
2. Toggle **⚡ EZ MODE**. It lays down a complete playable voice — your generators feed a VCA opened by
   an amp envelope, into a filter swept by a second envelope, to the output — so any oscillator you add
   is summed straight into the sound. It is the fastest way to get a playable starting point; build
   from there.
3. Press **+ ADD BLOCK** to add oscillators, filters and modulators, and drag output jacks onto input
   jacks to wire your own voice.
4. **Double-click** a block for its detail panel — parameters, unison (Voices/Detune), and modulation
   routing.

**INIT** unplugs every cable and modulation route while keeping the blocks (re-patch a fixed set a new
way); **🗑** blanks the patch entirely.

# Building a voice

The classic subtractive voice, wired by hand, shows the model:

1. Add an **Osc** (or Supersaw / Wt / FM). It already follows the played note's pitch.
2. Add an **Env** and a **VCA**. Wire Osc → VCA In 1 and Env → VCA In 2, and make the VCA an output.
   Now the amp envelope opens and closes the level on each note — without this, a held VCA stays open
   and the voice never articulates.
3. Insert a **Filter** between Osc and VCA. Add a second **Env** and route it to the Filter's cutoff
   mod with a short decay for a bright attack that settles — the single most recognisable subtractive
   gesture.
4. Add an **LFO** to pitch (vibrato) or cutoff (movement), and a **Glide** node for portamento between
   notes.

Because the oscillator is just one node, you can swap **Osc → Wt → FM → Supersaw → Vector → Karplus**
at any time and the rest of the voice keeps working — the same envelope, filter and amp shell hosts a
completely different timbre. That is the advantage of a graph over a fixed voice: the structure and the
sound source are decoupled.

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

Every oscillator (Osc, Wt, Supersaw, FM, Sub, Sync, Additive) carries the **Voices**/**Detune** unison
pair, so any oscillator can be a single voice or a detuned stack. A first-class **Trigger** source — a
one-sample impulse on each note-on — sits alongside Note / Gate / Velocity, for per-note events like
re-sampling a SampleHold or restarting an LFO.

# Synthesis methods

Because the oscillator is just a swappable node, this one synth covers every major synthesis method.
Knowing what each does helps you pick the right core for a sound.

**Subtractive** (`Osc` → `Filter`). Start with a harmonically-rich wave (saw or pulse) and carve
frequencies away with a filter. This is the classic analog model — warm, immediate, and the basis of
most basses, leads and pads. The saw is your everything-wave; the pulse with PWM is hollow and
animated.

**FM / phase modulation** (`FM`). One oscillator modulates another's phase, generating sidebands
whose spacing depends on the **ratio** and whose density depends on the **index**. Low integer ratios
give harmonic, tonal results (basses, e-pianos, bells); non-integer ratios go clangorous and
metallic. Route an envelope to the index and the timbre evolves over the note — the signature FM
move.

**Additive** (`Additive`). Build a tone by summing sine harmonics directly, controlling the partial
count and rolloff. Pure, organ-like and glassy; great for clean pads and bell tones where you want
exactly the harmonics you ask for and nothing else.

**Wavetable** (`Wt`). Sweep through a sequence of single-cycle waveforms with the **position**
control. Modulate position with an LFO or envelope and the timbre morphs continuously — the source of
modern evolving pads, growls and vocal-ish leads.

**Vector** (`Vector`). Crossfade between four waveforms on an XY pad. Animate X and Y for
four-corner morphing timbres in the Prophet-VS tradition.

**Supersaw / unison.** `Supersaw` stacks seven detuned saws for instant trance width; the
**Voices**/**Detune** unison controls on every oscillator do the same for any core. Width comes from
many slightly-out-of-tune copies beating against each other.

**Physical modelling** (`Karplus`, plus `Bowed`/`Blown` voices). Simulate a real resonator — a
plucked string is a short feedback delay tuned to pitch, damped over time. Naturally dynamic and
organic; play with damping and feedback for anything from a harp to a muted thud.

**Sample & granular** (`Sample`, `Granular`). Play back recorded audio, or chop it into overlapping
grains for clouds, time-stretching and texture.

**Sync** (`Sync`). Hard-sync a slave oscillator to a master so it restarts each cycle, producing the
bright, vocal, tearing sweep when you move the sync ratio — the classic aggressive lead.

Mix methods freely: layer a subtractive `Osc` under an `FM` operator, or run a `Wt` through the same
filter and envelope as an `Osc`. The voice structure doesn't care which core feeds it.

# The interface

- **Patch** — the node grid with drag-to-wire cables, the macro soft-key strip (`+` / `−` to change
  the active count; 16 by default), and the **INIT**, **🗑**, **⚡ EZ MODE**, **Stereo** and **Stereo
  Lock** controls. Double-click a block for its detail modal. The cable glow shows each block's live
  level so you can read the voice's gain structure.
- **Perform** — a play surface with no patching, for live macro control (below).
- **Settings** — master in/out and bypass, **Auto Gain Stage** and target, the brickwall limiter, and
  the rest of the audio-engine settings.

# Modulation

Modulation is the patching itself. Patch any **LFO** or **Env** output, a **StepLFO** / **NoiseLFO**
CV, or a macro **Soft Key** into a node input, or route it to a parameter as `base + source × depth`
in that parameter's units. Because modulators are ordinary nodes in the dependency graph, you can
modulate with a *processed* signal — an envelope through a **Scaler** to reshape its curve, or one
oscillator into another's mod input for audio-rate FM. The **Scaler** node (scale / offset / curve)
is the swiss-army knife for bending a modulation source before it reaches its destination.

The host-automatable parameters are the **soft keys** (an expandable pool, 16 active by default) plus
master in / out / bypass; the patch itself — nodes, cables, parameters — is saved as plugin state. A
soft key is both a macro you perform and a mod source you can patch anywhere, so one knob can open a
filter, push a drive and widen a detune at once, and that move records as host automation.

# The FX-bus rack

After all voices and layers mix down, the summed output runs through a **master + 2-aux FX-bus rack**
built from the same shared audio pack as zpwr-fx — the full library of filters, delays, reverbs,
dynamics, distortion and analog-modeled effects, available *once* on the output rather than per voice.
Send voices to the aux buses for shared reverb and delay (so every note shares one tail, the way a
real send works), and process the master bus for glue compression, EQ and saturation across the whole
patch.

# Gain staging

Two per-block Settings (both **on by default**) keep the signal between blocks from clipping no matter
how hot the cable gains are, inside every voice graph and on the FX buses:

- **Auto Gain Stage** rides levels with a fast-attack / slow-release peak follower that pulls each
  block toward the **Auto-Gain Target** ceiling, so stacked oscillators and resonant filters don't
  blow out the stages downstream.
- **Soft Clip** is the guarantee — an instant, sample-accurate tanh bound at the same ceiling on every
  block output, catching the fast transients the follower's attack would miss, saturating gently
  rather than clipping squarely.

Turn either off in Settings for raw gain (useful when you *want* a screaming, clipped lead). The master
**Brickwall Limiter** is a separate final ceiling on the output.

# Stereo & stereo lock

**Stereo** mirrors every block into an independent right-channel clone — a dual-mono voice per side —
and the two sides' knobs stay independent so you can dial width by offsetting them (slightly different
detune, cutoff or LFO phase left vs right). **🔒 Lock** (shown when Stereo is on) keeps the two channels
in sync: moving a knob on either side moves its clone by the *same delta*, so the L/R offset you dialled
in is preserved rather than collapsed to `L = R`, and the link is bidirectional. Locked clone blocks
render dimmed.

# Perform & macros

The **Perform** tab is a macros-and-pads surface for live play, driving only host-automatable
parameters so it works editor-closed and records as automation:

- **Preset Morph** — a 4-corner XY pad bilinearly interpolating between four corner presets (A/B/C/D);
  **🎲** fills all four at random, so you can sweep between four versions of a sound with one pad.
- **Orb** — drag the puck where the *angle* selects one of eight randomised scenes and the *distance*
  scales intensity; **🎲** rolls fresh scenes, **⏺** records the gesture and **▶** loops it back through
  the macro parameters for a hands-free evolving performance.
- **XY macro pads** — each drives a pair of soft keys, with per-pad **HOLD** (leave the dot) /
  **SPRING** (snap to centre on release) for sustained vs momentary moves.
- **Macro knobs**, eight **Snapshots** of the whole macro surface (click empty to save, filled to
  recall, right-click to clear), and a **🎲 Randomize** of all macros.
- **Scale / key** quantize and a **Chord** stacker (Oct / 5th / Maj / Min / Maj7 / Min7 / Sus4 /
  Power), an on-screen keyboard with pitch-bend and mod wheels, and the **ARP** controls — mode (Up /
  Down / Up-Down / Random / As-Played), rate (`1/4`…`1/16T`) and **Latch** (keep arpeggiating held
  notes after the keys release, so you can play over a running pattern).
- **MIDI In** toggles — **Program** (respond to Program Change) and **Bank** (respond to Bank Select
  CC0/CC32), both on by default.

# Presets

**256 factory voices** ship across **Factory 1** and **Factory 2** (128 each), with category prefixes
— `BA` bass, `LD` lead, `PD` pad, `KY` keys, `PL` pluck, `BR` brass, `BE` bell, `ST` strings, `DR`
perc, `SEQ` / `FX` — spanning subtractive, FM, additive, supersaw, wavetable, vector, sync and Karplus
voices, so the factory set doubles as a tour of every synthesis type the engine offers. Three further
genre banks are designed from documented production techniques:

- **Trance** — stacked supersaw pluck-leads, no-sustain plucks, slow-swell pads, a `1/16` square-LFO
  trance gate, and saw-LFO sidechain-pumped rolling bass.
- **Hard Techno** — Drumcode-style FM stabs with a fully env-swept dirty low-pass, screaming diode 303
  acid, detuned reese/rumble, hoover and driven lead-bass.
- **Schranz** — bitcrushed/folded metallic stabs, filtered-noise sweeps, `1/16` gated-noise loops,
  two-octave siren wails and distorted hypnotic pulses (~160 BPM).

Every preset carries facet tags (Type / Character / Style) so the browser's facets stay populated, and
ships with named macro knobs plus mod-wheel / velocity routing so it loads playable rather than as a
raw oscillator. Your own patches save and load from the preset manager. Factory voices can also be
exported as Native Kontrol Standard `.nksf` presets with a Komplete Kontrol audio preview, for browsing
on hardware.

# Sound-design tutorials

**A fat supersaw lead.** Add a **Supersaw**; raise its **Voices** to 7–11 and **Detune** for width.
Add an **Env** + **VCA** for the amp shape, and a **Filter** opened by a second **Env** with a quick
decay for a bright attack. Add a slow **LFO** to the Filter cutoff for movement and a little **Glide**
for portamento, then stack a second **layer** an octave down for weight. Add an aux send to reverb on
the FX-bus rack for space.

**An FM bass.** Add an **FM** node; set a low **ratio** (1–2) and a moderate **index** with a short amp
envelope. Route an **Env** to the FM index so the metallic bite decays into a rounder body — the
signature FM-bass evolution. Follow with a **DiodeLadder** for grit and a **Drive** for saturation.

**A 303 acid line.** Add an **Osc** (saw) → **DiodeLadder** (high resonance) → amp **Env**. Route a
fast **Env** to the ladder cutoff for the squelch, add **Glide** for the slides, and push the ladder
**drive**. Route **velocity** to cutoff so accented notes open brighter — the classic acid accent.

**A wavetable pad.** Add a **Wt** oscillator and route a slow **LFO** to its **position** so the timbre
morphs continuously. Use a long amp **Env** attack/release, a gently swept **Filter**, unison **Voices**
for thickness, and an aux reverb send for depth.

**A plucked string.** Add a **Karplus** node; set **damping** and **feedback** to taste, give it a
percussive amp envelope and a short delay, and route **velocity → brightness** so it responds to touch.

# Sound-design cookbook

- **Movement** — slow LFO → wavetable position, filter cutoff or oscillator detune.
- **Punch** — fast envelope → filter cutoff with a short decay for a bright transient.
- **Width** — raise oscillator **Voices**/**Detune**, or run **Stereo** with a small L/R offset.
- **Octave stack** — a second **layer** transposed an octave for weight without retuning the patch.
- **Per-note variation** — **Trigger** → **SampleHold** → pitch or cutoff for a different value each
  note.
- **Sidechain pump** — a beat-synced LFO → a VCA on the output for rhythmic ducking.
- **Velocity feel** — velocity → filter cutoff and amp level so dynamics translate to brightness and
  loudness.

# A voice for every genre

Ten voices to build, each naming the core and the moves that define it.

**House bass.** `Osc` (saw) → `Filter` (low-pass) → amp `Env`. Short decay, a little resonance, and a
beat-synced `LFO` → a `VCA` for the sidechain pump. Keep it mono with `Glide` for slides.

**Reese bass.** The `Reese` core (or two detuned `Osc` saws) → `DiodeLadder` → `Drive`. Movement comes
from the detuned saws beating; sweep the filter slowly with an `LFO`. The neurofunk staple.

**Dubstep growl.** `Wt` oscillator with its **position** modulated fast by an `LFO` (or `StepLFO`)
synced to the beat → `DiodeLadder` → `Folder`/`Waveshaper` → `Drive`. The rhythmic position+filter
movement is the "talking" growl.

**Trance supersaw lead.** `Supersaw` (Voices 9–11, wide Detune) → `Filter` opened by a quick `Env` →
a slow `LFO` on cutoff. Stack a `Sub` and a second layer an octave down; send to reverb on the
FX-bus.

**FM e-piano.** `FM` (ratio 1, moderate index) with an `Env` → index so the bite decays into a round
body, gentle amp envelope, a little `Chorus` on the FX-bus. Velocity → index for touch sensitivity.

**Ambient pad.** `Wt` with a very slow `LFO` → position, long amp `Env` attack/release, gentle
`Filter` sweep, unison `Voices` for width, and a long reverb send. Add slow `Vector` morphing for
extra evolution.

**Plucked harp.** `Karplus` with moderate damping and feedback, a percussive amp `Env`, `velocity →
brightness`, a short `Delay`. Light and dynamic.

**Acid 303.** `Osc` (saw) → `DiodeLadder` (high reso) → amp `Env`; a fast `Env` → cutoff for the
squelch, `Glide` for slides, push the ladder **drive**, and `velocity → cutoff` for accents.

**Hard-techno stab.** `FM` or `Osc` → `Filter` with a 100%-deep envelope sweep and high resonance →
`Drive`. Very short, percussive amp envelope. Layer a `HardKick` for weight.

**Glass bell.** `Additive` (sparse, odd-leaning partials) or `FM` (non-integer ratio) → long amp
`Env` release → `Shimmer`/reverb send. Pure and metallic; velocity → level for dynamics.

# Ten more voices

**Hoover stab.** The `Hoover` core (PWM + chorus + note-on pitch sweep) → `Filter` → `Drive`. Short,
aggressive, rave-era. Layer a `Sub` for weight.

**Screech lead.** The `Screech` core (detuned saws → drive → formant) → high-resonance `Filter`. The
hardstyle/gabber lead; route an envelope to the formant for movement.

**Vector morph pad.** `Vector` with X and Y each swept by a slow `LFO` at different rates, long
envelope, gentle filter, reverb send. The timbre drifts around the four-corner space forever.

**Granular texture.** `Granular` over a sample with small grain size and high overlap, position swept
by an `LFO`, into the filter and a reverb send. Evolving, cloud-like beds.

**Sync sweep lead.** `Sync` with the sync ratio swept by an `Env` (or the mod wheel) → filter. The
bright, tearing, vocal sweep of hard sync.

**Additive organ.** `Additive` with several harmonics, no filter movement, a fast amp envelope, a
little `Chorus` and `RingMod` on the bus for a tonewheel/Leslie flavour.

**Detuned reese.** Two `Osc` saws (or `Reese`) detuned a few cents → `DiodeLadder` → `Drive`; sweep
the filter slowly. The wide, growling DnB sub.

**Plucked sitar.** `Karplus` with low damping and high feedback → a band-pass `Filter` → a buzzing
`Waveshaper` for the jawari, short delay. Eastern, droning pluck.

**Noise sweep riser.** `Noise → Filter` (band-pass) with the cutoff swept up by a long `Env`, into a
reverb send. The classic build-up riser; automate the envelope time for length.

**Chiptune lead.** `Osc` (pulse) with PWM, no filter, a hard `Crusher` for 8-bit grit, fast envelope,
a `Glide` for slides. Add an arp on the Perform tab.

# Modulation & movement

A static patch is a starting point; movement is what makes it musical. The synth gives you several
movers, each with a different feel:

- **Envelopes (`Env`)** are one-shot contours fired by the note. Use them for anything that should
  happen *per note*: the amp shape, a filter sweep on the attack, a pitch blip, an FM-index decay.
  Short decays give punch; long releases give pads their tails.
- **LFOs (`LFO`)** are repeating shapes for ongoing motion: vibrato (pitch), tremolo (level), filter
  wobble, wavetable drift. Sync them to tempo for rhythmic gating and dubstep growls.
- **Stepped & random (`StepLFO`, `NoiseLFO`, `SampleHold`)** give stair-stepped or random movement —
  sequenced filter patterns, per-note pitch variation (via the **Trigger** source), analog drift.
- **The `Scaler`** bends a modulation signal before it lands: scale it down, offset it, or curve it so
  an envelope's shape or an LFO's range hits the destination just right.
- **Performance controllers** — velocity, the mod wheel, aftertouch and MPE — let the *player*
  modulate. Velocity → cutoff is the single most important "feel" routing; mod wheel → vibrato depth
  or filter is the classic expressive control.

The art is layering movers at different rates: a fast envelope for the attack, a slow LFO for drift,
and velocity for touch, all on the same filter, gives a sound that feels alive rather than looped.

# Tips & best practices

- Start from **⚡ EZ MODE** or a factory voice near your target and modify, rather than building from
  silence.
- Use **unison Voices/Detune** for width inside one voice; use **layers** for parallel timbres or
  octave stacks — they cost differently (unison is cheaper than a whole extra layer).
- Keep **Auto Gain Stage** / **Soft Clip** on while patching; stacked oscillators, resonance and the
  FX-bus rack can otherwise overshoot 0 dBFS.
- Name your **soft-key macros** for what they perform, so presets load playable and the Perform pads
  make sense.
- Use the **Perform** Morph/Orb to audition variations of a patch quickly before committing.

# FAQ

**No sound when I play.** Toggle **⚡ EZ MODE**, or check that an oscillator reaches the output through
a **VCA** opened by an envelope — a closed VCA (no envelope on In 2) is silent, and a raw oscillator
with no amp shape may be there but not articulating.

**My patch only plays one note.** Each held note runs its own voice automatically; if it sounds mono,
you likely have a **Mono**-style routing or are sharing one envelope across the voice — otherwise just
play a chord and each note voices independently.

**How do I add effects?** The **FX-bus rack** on the output carries the full audio pack; send voices to
the aux buses for shared reverb/delay or process the master bus for glue.

**Can I browse on hardware?** Export factory voices as Native Kontrol Standard `.nksf` presets with
previews for Komplete Kontrol.

**Which formats and OSes?** VST3, AU, CLAP and Standalone on macOS, Linux and Windows (AU is macOS
only; Windows ships VST3 + CLAP).

# Playing

The on-screen keyboard sits at the bottom of the editor; the computer keyboard's home row
(`A W S E D F T G Y H U J K …`) plays a chromatic octave around C4. Click a key once to give the
keyboard focus, then type. Pitch-bend and mod wheels sit beside the keyboard, and the Perform tab's
arp, chord and scale controls shape what you play before it reaches the voice.

# Glossary

- **Voice** — one instance of your patch graph, one per held note across the pool.
- **Layer** — an independent voice pool running its own copy of the patch.
- **Unison (Voices/Detune)** — detuned oscillator copies summed inside a single voice.
- **Gate / Trigger** — Gate is high while a note is held; Trigger is a one-sample impulse at note-on.
- **Soft key / macro** — a host-automatable knob, also patchable as a mod source.
- **FX-bus rack** — the master + 2-aux effects rack on the summed output.
- **EZ Mode** — a one-toggle playable voice you can then customise.
