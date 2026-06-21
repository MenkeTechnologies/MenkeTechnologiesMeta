# Overview

zpwr-fx is a **modular patch-graph effects plugin** — not a fixed slot rack. Instead of a preset
chain of effects, you wire primitive DSP blocks (oscillators, filters, delays, reverbs, dynamics,
distortion, modulation, utilities) freely into your own algorithm, in the spirit of the Eventide
H3000 Factory, inside a cyberpunk WebView interface. It runs as VST3, AU, CLAP and Standalone on
macOS, Linux and Windows.

What makes it modular rather than a multi-effect:

- **Any-to-any routing.** Any block's output can feed any other block's input. There is no fixed
  order — you decide the topology.
- **Fan-out.** A single source can drive unlimited destinations; split a signal to parallel chains
  and recombine them with a Mixer.
- **Feedback.** Wire an output back to an earlier input and the graph resolves the loop with a
  one-sample delay — the basis of combs, flangers, Karplus strings and runaway resonators.
- **Modulation everywhere.** Every parameter has a modulation source and depth; LFOs, envelopes,
  macro knobs and other blocks' outputs all modulate freely.
- **Layers.** Stack unlimited independent copies of the whole engine and mix them with the Mixer.

# Core concepts

**Blocks (nodes).** The unit of the patch. Each block has a type (Filter, Delay, LFO, …), **three
inputs** — In 1, In 2 and **Mod** — up to **six parameters**, and **one output**. A block reads its
inputs every sample, computes, and writes its output.

**Sources.** Anything an input can read: silence, the left/right audio input, internal Noise, the
macro **Soft Keys**, live **MIDI/MPE** (mod wheel, aftertouch, pitch bend, velocity, expression,
breath, sustain, note, and the MPE press / slide / bend dimensions), or **any block's output**.

**Signal vs control.** The same cables carry audio and control (CV). An LFO's output is just a slow
signal; patch it into a Filter's Mod input to sweep the cutoff, or into a VCA to make a tremolo.
There is no hard wall between "audio" and "modulation" — only how fast the signal moves.

**The graph.** On every structural edit the patch is sorted into dependency order so each block runs
after the blocks it reads. Cycles (feedback) are detected and broken with a one-sample delay, so the
sort always succeeds. Editing is lock-free: live knob tweaks are atomic writes; structural edits
swap the whole graph atomically so audio never glitches.

**Layers.** A layer is a full copy of the engine. Stack them for thickness (detune two layers),
parallel processing (clean layer + crushed layer), or wet/dry control, and balance them in the
Mixer with sends to the aux FX buses.

# Getting started

1. Open the plugin on an audio track. The **Patch** tab shows a grid of blocks with input and
   output jacks.
2. Press **⚡ EZ WIRE** — it auto-routes the input through your blocks to the output, so you hear
   sound immediately without touching a cable. It is the fastest way to get signal flowing before
   you start rewiring.
3. Press **+ ADD BLOCK** and choose a Filter, Delay or Reverb. Drag from one block's **output** jack
   onto another block's **input** jack to wire them.
4. **Double-click** any block to open its detail panel — its parameters, its modulation routes, and
   (for the Expr block) its code.
5. Tweak knobs; the cable feeding each block **glows** with that block's live level, so you can see
   the gain structure as you work.

Two buttons reset without starting over: **INIT** unplugs every cable and modulation route but keeps
your blocks in place (handy for re-patching from scratch), and **🗑** blanks the whole patch.

# Patching cables

- **Wire:** drag an output jack onto an input jack.
- **Disconnect:** drag an input jack away and drop it on empty space.
- **Rewire:** drop an existing connection on a different output.
- **Fan out:** drag from the same output again to a second input — outputs feed any number of inputs.
- **Cable level & colour:** **right-click** a cable for its **level** (a per-cable gain) and a
  **colour** swatch. The cable's brightness tracks its level, so a dim cable is carrying a quiet
  signal — a visual gain meter built into the patch.

Because the **Mod** input is just another input, you can patch a control signal into it and use it
as a per-block modulation bus in addition to the parameter mod slots.

# The interface

The editor is organised into tabs along the top:

- **Patch** — the main workspace: the node grid, drag-to-wire cables, the macro soft-key strip, and
  a detail panel for the selected block. Carries **⚡ EZ WIRE** (auto-route), **INIT** (unplug, keep
  blocks), **🗑** (blank), and the **Stereo** / **🔒 Lock** toggles. Cables glow with each block's
  live signal level.
- **Synth** — a fixed-layout panel showing every block's knobs in a grid, with no cables
  (Serum/Spire style). Use it for fast sound design once the routing is set.
- **Perform** — macros and XY pads only, no patching; built for live play and host automation.
- **Clip** — draw a MIDI pattern and play the patch from it, with key/scale and key-trigger, to
  audition a patch melodically.
- **Mod Matrix** — every modulation connection in the patch in one editable list.
- **Mixer** — per-layer channel strips (gain, pan, mute, solo) with sends to the aux FX buses, the
  aux returns and the master strip, with peak and LUFS metering.
- **Browse** — search, save, tag and load patches; filter by bank, type, style and character.
- **Settings** — master in/out and bypass, **Auto Gain Stage** and target, the brickwall limiter,
  scale/key quantize, UI scale and interface toggles.
- **About** — version and engine info.

# Modulation in depth

Modulation is the patching itself. Two ways to modulate:

1. **Parameter mod slot.** In a block's detail panel, each parameter has a **source** and a
   **depth**. The parameter value becomes `base + source × depth`, in the parameter's own units —
   so an LFO at depth `+2400` on a pitch param sweeps two octaves, while the same LFO at depth
   `0.2` on a mix param nudges it gently.
2. **Mod input.** Patch a control signal straight into a block's **Mod** input for a per-block
   modulation bus.

Any source works: an **LFO** block, an **Envelope** follower, a **macro Soft Key**, **Noise**, a
performance controller, or **another block's output** (because mod sources are part of the
dependency graph, modulating with a block's output is ordered like any other connection — you can
even modulate with a delayed or filtered version of a signal).

The **Mod Matrix** tab gathers every modulation route in the patch into one list so you can audit
and rebalance the whole modulation scheme at a glance.

# Macro soft keys

The **Soft Keys** are an expandable pool of host-automatable knobs (16 active by default). The
`+` / `−` controls above the knob row change how many are active, and the active count is saved with
the patch. They are special because:

- They are **host-automatable** — DAW automation lanes and the Perform surfaces drive them.
- They are **patchable** as modulation sources anywhere in the graph.

So a soft key is the bridge between an outside gesture (automation, a hardware knob, an XY pad) and
the inside of your patch — assign one to a filter cutoff and a delay mix at once for an expressive
macro.

# Gain staging

Stacked cable gains and summing buses make it easy to drive the signal *between* blocks past
0 dBFS, which would clip. Two per-block settings (both **on by default**) handle it:

- **Auto Gain Stage** rides levels: each block's output runs through a fast-attack / slow-release
  peak follower whose smoothed gain (≤ 1) pulls the block down toward the **Auto-Gain Target**
  ceiling, so stages stay sanely staged as you build.
- **Soft Clip** is the guarantee: an instant, sample-accurate tanh bound at the same ceiling on every
  block output. The follower's ~2 ms attack can let a fast transient slip through before it ducks,
  and cable gains apply downstream of the staging — Soft Clip catches all of it, saturating gently
  rather than clipping harshly.

Both are per block, so each stage is independent, and the live cable glow tracks each block's level.
Turn either off in Settings for raw gain. They are distinct from the master **Brickwall Limiter**, a
single hard ceiling on the final summed output. MIDI-effect blocks carry no audio level, so neither
applies to them.

# The Expr block

The **Expr** block runs a short per-sample expression you write in its detail panel, doing things
the fixed blocks can't:

- **Variables:** `in` (In 1), `t` (time), `sr` (sample rate), `p0`–`p7` (p0–p5 are the knobs, p6 is
  In 2, p7 is Mod), `s0`–`s3` (persistent state across samples), and the constants `pi`, `tau`, `e`.
- **Functions:** `sin cos tan tanh`, `floor frac wrap saw sqr tri`, `min max pow fmod clamp lerp`,
  `if step noise rand`, and **`tap(d)`** — the block's own output `d` samples ago (fractional), for
  combs, Karplus strings and feedback.
- **Safe by construction:** no loops, allocation or memory access in the audio path; the output is
  sanitised (any NaN/Inf becomes 0); a program that exceeds the limits simply fails to compile.

Examples:

- Wavefolder: `out = sin(in * (1 + p0 * 8) * pi)`
- Bit-reduce: `out = floor(in * (1 + p0 * 32)) / (1 + p0 * 32)`
- Karplus string (with feedback into its own input): `out = (in + tap(p0 * sr)) * 0.5 * p1`
- Sample-and-hold on a clock in p6: `s0 = if(p6 > 0.5, noise(), s0); out = s0`

# Worked examples

**Filter sweep.** Add a Filter and an LFO. Wire In L → Filter → Out. Open the Filter, set its Cutoff
mod **source = LFO** and a depth of a few octaves. Set the LFO Rate slow. The cutoff now sweeps —
the classic auto-wah/sweep.

**Stereo slap.** Turn on **Stereo**. Add a Delay on each side; set slightly different Times on the
left and right clones (turn **Lock** off so they stay independent) for a widening slapback.

**Comb resonator.** Add an Expr block and wire its output back to its own In 1. Use
`out = (in + tap(sr / (60 + p0 * 1000))) * p1` — In 1 is the live input plus a tuned, fed-back tap,
so noise or transients ring at a pitch set by p0, with p1 as the decay/resonance.

**Parallel crush.** Add two layers in the Mixer. Leave layer 1 clean; on layer 2 add a Crusher and a
Drive. Blend the dirty layer under the clean one with the layer faders for parallel distortion.

# Perform & macros

The **Perform** tab is a play-the-patch surface that drives only host-automatable parameters, so it
works with the editor closed and records as automation:

- **Preset Morph** — a 4-corner XY pad (A/B/C/D) that bilinearly interpolates between four captured
  patches; **🎲** assigns a random preset to all four corners. The X/Y axes are reserved host
  parameters, so the morph itself automates.
- **Orb** — a radial pad where the puck's *angle* selects a scene and its *distance* sets intensity;
  **🎲** rolls a new random scene set, **⏺** records the puck's motion, and **▶** loops it back
  through the host-automatable parameters — a hands-free gesture becomes recorded automation.
- **XY macro pads** — each with a **HOLD** / **SPRING** toggle (spring snaps back to centre on
  release for momentary moves).
- **Macro knobs** — the soft keys as plain knobs.
- **Scenes** — snapshot slots: click to recall, right-click to clear.
- **Controls band** — global randomise, an arpeggiator (mode / rate / latch), and **scale + key**
  quantize plus a **Chord** that stacks extra intervals on each key played on the on-screen keyboard.

# Stereo & stereo lock

- **Stereo** (off by default) mirrors the patch graph to the right channel, so blocks process the
  left and right channels independently. Dial a per-knob L/R offset for width.
- **🔒 Lock** keeps the mirrored blocks tracking the left channel. It is **bidirectional and
  offset-preserving**: moving a left knob moves its clone, and moving a clone moves the left, each by
  the same amount — so the width you dialled in is preserved rather than reset. Set Lock on for a
  perfect `L = R`. Both states are saved with the patch, and locked clone blocks render dimmed.

# MIDI & MPE

The plugin accepts MIDI and MPE input; MPE is aggregated to the most recent note. Every MIDI
dimension (mod wheel, aftertouch, pitch bend, velocity, expression, breath, sustain, note, and the
MPE press / slide / bend) is available as a modulation source — so you can play the effect
expressively from a controller. Two response toggles, both **on by default**:

- **Program Change** — an incoming Program Change selects the matching preset. Turn it off to ignore
  Program Change.
- **Bank Select** — CC0 (MSB) and CC32 (LSB) are captured and combined with the next Program Change
  (`bank × 128 + program`) for banked preset addressing. Turn it off and Program Changes address
  presets 0–127 directly.

# Presets & browsing

Factory patches ship in code — **Stereo Slap, Filter Sweep, Comb Resonator, Wavefolder** — as
starting points. Save your own from the **Browse** tab with facet tags (bank / type / style /
character) so the browser's filters stay populated, and recall by searching or filtering. The full
plugin state — the patch plus every parameter and soft-key value — round-trips through your host
session, and an incoming Program Change can switch presets live.

# Mouse & keyboard reference

- **Drag output → input** — wire a cable.
- **Drag input → empty** — disconnect.
- **Right-click cable** — level + colour editor.
- **Double-click block** — open its detail panel.
- **+ ADD BLOCK** — add a block; **delete** on a selected block removes it.
- **⚡ EZ WIRE** — auto-route input → blocks → output.
- **INIT** — unplug all cables/mods, keep blocks. **🗑** — blank the patch.

# Glossary

- **Block / node** — one DSP unit in the patch (three inputs, six params, one output).
- **Source** — anything an input can read (audio in, noise, a soft key, MIDI, another block).
- **Mod (CV)** — a control signal modulating a parameter, `base + source × depth`.
- **Soft key / macro** — a host-automatable knob, also patchable as a mod source.
- **Layer** — a full copy of the engine, mixed with the others.
- **Feedback** — a cable from a later block back to an earlier input, resolved with a one-sample
  delay.
- **EZ Wire** — one-click auto-routing of input → blocks → output.
