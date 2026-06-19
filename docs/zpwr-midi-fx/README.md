# zpwr-midi-fx

A **MIDI-effects** plugin built on [JUCE](https://juce.com) — the MIDI-domain
companion to [`zpwr-fx`](../zpwr-fx/), built on the same shared
[`zpwr-patch-core`](../zpwr-patch-core/) engine. Created by MenkeTechnologies.

Where `zpwr-fx` processes the audio stream, `zpwr-midi-fx` transforms the MIDI
note stream before it reaches an instrument.

## Formats

- **VST3** — cross-platform
- **AU** — macOS (Logic AU MIDI FX)
- **CLAP** — via [`clap-juce-extensions`](https://github.com/free-audio/clap-juce-extensions) (note ports)
- **Standalone** — local dev/test app

Targets macOS (arm64/x86_64) + Linux (x86_64/aarch64).

## Architecture

Not a fixed-slot rack — the same free-routed **patch graph** as `zpwr-fx`,
instantiated on `zmidi::NoteStream` instead of `float`
(`zpc::LayeredEngineT<zpc::PatchEngineT<zmidi::NoteStream>>`). Modules are wired by
source id with fan-out and feedback; every node param carries a `(source, depth)`
mod-matrix entry; the `zpc::WebEditor` WebView UI and ⚡ EZ-wire auto-routing are
shared with the audio host.

```
MIDI in  →  [ Arp ]  →  [ Chord ]  →  [ Scale ]  →  MIDI out
            ↑ mod matrix    (any node → any node; free cabling)
```

## Modules

**56** note-stream module types (`registerMidiModules`, `dsp/MidiModules.cpp`):
arpeggiation, chord generation, scale quantization, Euclidean and generative
sequencing, ratchet/strum/humanize timing, velocity shaping, and note remapping.
(Plus 950+ audio/synth modules in the shared registry — 1000+ DSP blocks stack-wide.)

Private — part of the paid MenkeTechnologies audio stack.
