# Overview

zpwr-fx is a **modular patch-graph effects plugin** — not a fixed slot rack. Instead of a
preset chain of effects, you wire primitive DSP blocks (oscillators, filters, delays, reverbs,
dynamics, distortion, modulation) freely into your own algorithm, in the spirit of the Eventide
H3000 Factory, inside a cyberpunk WebView interface. It runs as VST3, AU, CLAP and Standalone on
macOS, Linux and Windows.

Any block's output can feed any other block's input, signals can fan out to unlimited
destinations, and feedback is allowed — wire an output back to an earlier input and the graph
resolves it with a one-sample delay. A per-parameter modulation matrix, an expandable bank of
macro knobs, and unlimited stacked layers complete the instrument.

# Getting started

1. Open the plugin on an audio track. The **Patch** tab shows a grid of blocks with input and
   output jacks.
2. Press **⚡ EZ WIRE**. This auto-routes the input through your blocks to the output, so you hear
   sound immediately without touching a cable.
3. Press **+ ADD BLOCK** to drop in a filter, delay or reverb, then drag from one block's output
   jack onto another's input jack to wire it by hand.
4. Double-click any block to open its detail panel — its parameters, its modulation routes, and
   (for the Expr block) its code.

Two buttons reset without starting over: **INIT** unplugs every cable and modulation route but
keeps your blocks in place, and **🗑** blanks the whole patch.

# The patch model

- **Sources** an input can read: silence, the left/right audio input, internal noise, the macro
  soft keys, live MIDI/MPE (mod wheel, aftertouch, pitch bend, velocity, expression, breath,
  sustain, note, and the MPE press/slide/bend dimensions), or any block's output.
- Each block has **three inputs** (In 1, In 2, Mod), up to **six parameters**, and **one output**.
- The graph is **topologically sorted** on every edit; cycles (feedback) resolve automatically
  with a one-sample delay, so you can build feedback patches freely.
- Any source can **fan out** to unlimited destinations.

**Patching cables:** drag an output jack onto an input jack to wire it; drag an input away to
disconnect; drop on a different output to rewire. **Right-click** a cable for its **level**
(per-cable gain) and **colour** — the cable's brightness tracks its level, so the gain structure
between blocks is visible while you patch.

# The interface

The editor is organised into tabs:

- **Patch** — the node grid with drag-to-wire cables, the macro soft-key strip, and a detail
  panel for the selected block. Includes **⚡ EZ WIRE** (auto-route), **INIT** (unplug, keep
  blocks), **🗑** (blank), and the **Stereo** / **🔒 Lock** toggles. Cables glow with each
  block's live signal level.
- **Synth** — a fixed-layout panel showing every block's knobs in a grid, with no cables
  (Serum/Spire style) for fast sound design.
- **Perform** — macros and XY pads only, no patching; built for live play and automation.
- **Clip** — draw a MIDI pattern and play the patch from it, with key/scale and key-trigger.
- **Mod Matrix** — every modulation connection in the patch, in one list.
- **Mixer** — per-layer channel strips (gain, pan, mute, solo) with sends to the aux FX buses,
  the aux returns and the master strip, with peak and LUFS metering.
- **Browse** — search, save, tag and load patches; filter by bank, type, style and character.
- **Settings** — master in/out and bypass, **Auto Gain Stage** and target, the brickwall limiter,
  scale/key quantize, UI scale and interface toggles.
- **About** — version and engine info.

# Modulation

Modulation is the patching itself. Every block parameter has a **mod source + depth** in its
detail panel: any source — an LFO, an envelope, a macro soft key, noise, or another block's output
— modulates the parameter by `source × depth` in parameter units. Because mod sources are part of
the dependency graph, modulating a parameter with a block's output is ordered like any other
connection. The **Mod Matrix** tab lists every modulation route in the patch at once.

**Macro soft keys** are an expandable pool of host-automatable knobs (16 active by default; the
`+` / `−` controls above the knob row change how many are active). They are patchable as
modulation sources, and they are what the **Perform** surfaces drive — the host-automatable bridge
between a live performance and the patch.

# Gain staging

Stacked cable gains and summing buses make it easy to drive the signal *between* blocks past
0 dBFS. Two per-block settings (both **on by default**) handle it:

- **Auto Gain Stage** rides levels: each block's output runs through a fast-attack / slow-release
  peak follower whose smoothed gain pulls the block down toward the **Auto-Gain Target** ceiling.
- **Soft Clip** is the guarantee: an instant, sample-accurate tanh bound at the same ceiling on
  every block output, catching the fast transients the follower's attack would miss. It saturates
  gently rather than clipping harshly.

Turn either off in Settings for raw gain. Both are distinct from the master **Brickwall Limiter**,
a single hard ceiling on the final summed output.

# The Expr block

The **Expr** block runs a short per-sample expression you write in its detail panel, doing things
the fixed blocks can't:

- **Variables:** `in` (In 1), `t`, `sr`, `p0`–`p7` (p0–p5 are knobs, p6 is In 2, p7 is Mod),
  `s0`–`s3` (persistent state), and the constants `pi`, `tau`, `e`.
- **Functions:** `sin cos tan tanh`, `floor frac wrap saw sqr tri`, `min max pow fmod clamp lerp`,
  `if step noise rand`, and **`tap(d)`** — the block's own output `d` samples ago (fractional),
  for combs, Karplus strings and feedback.
- It is safe by construction: no loops or memory access in the audio path, and the output is
  sanitised so a bad program can never blow up the signal.

Example wavefolder: `out = sin(in * (1 + p0 * 8) * pi)`

# Perform & macros

The **Perform** tab is a play-the-patch surface that drives only host-automatable parameters, so
it works with the editor closed and records as automation:

- **Preset Morph** — a 4-corner XY pad (A/B/C/D) that bilinearly interpolates between four captured
  patches; **🎲** assigns a random preset to all four corners.
- **Orb** — a radial pad where the puck's *angle* selects a scene and its *distance* sets
  intensity; **🎲** rolls a new random scene set, **⏺** records the puck's motion, and **▶** loops
  it back through the host-automatable parameters, turning a hands-free gesture into automation.
- **XY macro pads** — each with a **HOLD** / **SPRING** toggle (spring snaps back to centre on
  release).
- **Macro knobs** — the soft keys as plain knobs.
- **Scenes** — snapshot slots: click to recall, right-click to clear.
- **Controls band** — global randomise, an arpeggiator (mode / rate / latch), and **scale + key
  quantize** plus a **Chord** that stacks extra intervals on each key played on the on-screen
  keyboard.

# Stereo & stereo lock

- **Stereo** (off by default) mirrors the patch graph to the right channel, so blocks process the
  left and right channels independently — dial in a per-knob L/R offset for width.
- **🔒 Lock** keeps the mirrored blocks tracking the left channel. It is **bidirectional and
  offset-preserving**: moving a left knob moves its clone, and moving a clone moves the left, each
  by the same amount — so the width you dialled in is preserved rather than reset. Set Lock on for
  a perfect `L = R`. Both states are saved with the patch.

# MIDI

The plugin accepts MIDI and MPE input (MPE is aggregated to the most recent note), available
everywhere as modulation sources. Two response toggles, both **on by default**:

- **Program Change** — an incoming Program Change selects the matching preset. Turn it off to
  ignore Program Change.
- **Bank Select** — CC0 (MSB) and CC32 (LSB) are captured and combined with the next Program
  Change (`bank × 128 + program`) for banked preset addressing. Turn it off and Program Changes
  address presets 0–127 directly.

# Presets

Factory patches ship in code (Stereo Slap, Filter Sweep, Comb Resonator, Wavefolder). Your own
patches save from the **Browse** tab with facet tags (bank / type / style / character) for
searching, and the full plugin state — the patch plus every parameter — is restored with your host
session.
