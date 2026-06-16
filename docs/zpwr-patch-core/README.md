# zpwr-patch-core

The signal-agnostic **modular patch graph** behind the MenkeTechnologies plugin
stack — the cable-routing system shared by [`zpwr-fx`](../zpwr-fx/),
[`zpwr-synth`](../zpwr-synth/), and [`zpwr-midi-fx`](../zpwr-midi-fx/). Created by
MenkeTechnologies.

It owns the parts that are the same in every modular plugin and nothing else:
routing (nodes wired by source ids, fan-out, feedback), topological evaluation
(cycles resolve with a one-sample delay), a per-param mod matrix, per-cable gain +
colour, lock-free live edits with atomic graph swap on structural edits, JSON patch
serialisation with versioning + source-id migration, and an RT-safe expression VM
(`ScriptEngine`, exposed as the `Expr` module).

It knows **nothing about audio or MIDI**. The graph is templated on the signal type
carried between nodes (`SignalTraits<S>`): `float` for audio (`zpwr-fx`,
`zpwr-synth`) and a note-event stream for MIDI (`zpwr-midi-fx`). Each host supplies
a `ModuleRegistry` of node types and the external source values per sample; the core
resolves block outputs and leaves the rest to the host.

`zpc::WebEditor<Engine>` is the shared WebView backend (catalog / patch JSON, preset
I/O, ~30 native functions) with an expandable soft-knob pool and an **⚡ EZ WIRE**
auto-routing mode.

Depends only on `juce::juce_core`; consumers add it via `add_subdirectory` and link
`zpwr::patch_core`. C++20.

Private — part of the paid MenkeTechnologies audio stack.
