# MenkeTechnologies — Invention Ledger

Candidate "world's first" capabilities across the stack. The bar: a genuinely
**novel capability** (not a faster dup) **and** best-in-class implementation.
Every entry states the **claim**, its **basis**, and an honest **caveat** — a web
search is never exhaustive, so "no prior art found" is recorded as that, not as a
proven absolute. Claims are owned by MenkeTechnologies; this ledger just keeps them
honest and falsifiable.

| # | Claim | Basis | Caveat |
| --- | --- | --- | --- |
| 1 | **zpwr-daw — a general-purpose DAW arranger that runs as a plugin AND embeds in any GUI app**: a *complete* two-view arranger (Arrangement + Session, clips, breakpoint automation, tempo/meter maps) shipping standalone, as a VST3 inside another DAW, and embedded in arbitrary hosts — including **non-audio** ones (traderview → trades, ztranslator → translations, Audio-Haxor → stryke on clips) off the same clip/automation timeline. | Closest prior art, none a clean dup (see analysis). | "None found", not proven — a web search is not exhaustive. Audio render path written but **unverified** (pending a JUCE build); the editor/arranger/automation are verified. |
| 3 | **zpwr-daw — the world's first DAW with an embedded shell terminal**: a real interactive shell running *inside* the DAW (the MenkeTechnologies stack — zshrs/stryke), not a constrained scripting console (Reaper ReaScript, Bitwig controller scripts) but a full terminal for driving the shell/CLI from within the project. | In implementation now; part of the zshrs/stryke ↔ daw integration. | "None found", not proven (search not exhaustive). **In progress** — entry recorded ahead of completion; demote/adjust if a dup surfaces or scope changes. Scripting consoles exist (ReaScript, Max), but a full embedded interactive **shell terminal** in a DAW has no clean prior art found. |
| 2 | **zpwr-daw — the world's first fully modular DAW**: not a fixed channel-strip mixer with a modular *device* bolted on, but a DAW whose entire signal path is a user-patchable graph — **every track auto-owns a layer**, each layer is a **stereo patch graph** (one cable carries L/R) hosting oscillators/FX/VST3-AU plugins, the **synth panel and mod matrix are generated from that same patch**, and master/aux/global-mod buses are themselves patch graphs (the patch panel's tabs). The ~3.5k mono FX become stereo for free via a dual-mono wrapper (run once per channel, independent state) — no hand-written stereo block set. | `zpc::StereoGraph` (`PatchEngineT<StereoSample>`) + `wrapMonoAsStereo` + native stereo Plugin host, shared across all four products; per-track stereo graphs wired into the daw. | "None found", not proven (search not exhaustive); see near-miss analysis. The modular **audio render** (per-track stereo graphs → master mix) is **in progress / partially unverified** — the graph, wrapper, and stereo plugin block are compile-verified; full per-track audio + the cue bus are still being wired. |

### Prior-art analysis (why each near-miss isn't a dup)

- **NI Maschine** — a hybrid **groovebox** tied to NI's hardware/ecosystem workflow. By NI's own words it *"has never been a full DAW"* (no complex automation/mixing, by design). The Maschine 3 software does run without a controller, but it's a groove workstation, **not a general-purpose DAW** — so it isn't a dup of a *full GP DAW* as a plugin.
- **Komplete Kontrol** — a plugin **host** + preset browser + smart-play (scales / arp). **No step sequencing or arrangement at all** — definitively not a DAW.
- **Tracktion Engine** — a **compile-time developer library** for building DAW apps, not a loadable plugin you embed at runtime.
- **Sequencer plugins** (SEQUND, Stepic, B-Step, Playbeat) — **step sequencers**, not full DAWs.

Net: no clean prior art for a **general-purpose full DAW arranger as a runtime plugin / embeddable component**, and none for one driving **non-audio** hosts off its timeline. Claimed as "none found", owned by MenkeTechnologies, not stamped as a proven absolute.

### Prior-art analysis (fully modular DAW — claim #2)

- **Bitwig Studio (The Grid)** — a modular **sound-design device** *inside* a conventional DAW; the DAW's tracks/mixer/routing are a **fixed** architecture, not a patch graph. Modular is a device, not the DAW.
- **Reaktor / Max / Max for Live / VCV Rack** — fully modular **instruments/environments**, but **not DAWs** (no general-purpose arranger + mixer + project model).
- **Usine Hollyhock** — a modular audio environment with sequencing, the closest near-miss; it is patch-based but presents as a modular host/performance tool rather than a general-purpose track-and-arrangement DAW. Recorded as a near-miss, not a confirmed dup.
- **Reason (Reason Studios)** — the strongest near-miss: a full DAW with a **modular rack** (flip to the back, patch CV/audio cables between fixed devices). But it is **not fully modular** — devices are fixed-architecture units, the signal path/mixer isn't a free graph, and **many parameters have no CV input, so they can't be modulated/patched at all**. zpwr-daw's claim is the stronger one: **every** track/layer/bus is a patch graph and **every** block param is a graph node param, modulatable from the mod matrix — no fixed devices, no un-modulatable params. Reason is rack-modular; zpwr-daw is graph-modular end to end.

Net: no clean prior art found for a **general-purpose DAW whose every track/layer, mixer bus, synth, and mod matrix is one user-patchable graph (with no un-modulatable params)**. "None found", owned by MenkeTechnologies, not stamped absolute; and the modular audio engine is still being wired (caveat above).

Other stack "first" claims (zshrs, stryke, etc.) live in their own repos; add them
here only with the same claim / basis / caveat rigor — and check for prior art
(Maschine/KK/Tracktion class) before stamping "first".
