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

### Prior-art analysis (why each near-miss isn't a dup)

- **NI Maschine** — a hybrid **groovebox** tied to NI's hardware/ecosystem workflow. By NI's own words it *"has never been a full DAW"* (no complex automation/mixing, by design). The Maschine 3 software does run without a controller, but it's a groove workstation, **not a general-purpose DAW** — so it isn't a dup of a *full GP DAW* as a plugin.
- **Komplete Kontrol** — a plugin **host** + preset browser + smart-play (scales / arp). **No step sequencing or arrangement at all** — definitively not a DAW.
- **Tracktion Engine** — a **compile-time developer library** for building DAW apps, not a loadable plugin you embed at runtime.
- **Sequencer plugins** (SEQUND, Stepic, B-Step, Playbeat) — **step sequencers**, not full DAWs.

Net: no clean prior art for a **general-purpose full DAW arranger as a runtime plugin / embeddable component**, and none for one driving **non-audio** hosts off its timeline. Claimed as "none found", owned by MenkeTechnologies, not stamped as a proven absolute.

Other stack "first" claims (zshrs, stryke, etc.) live in their own repos; add them
here only with the same claim / basis / caveat rigor — and check for prior art
(Maschine/KK/Tracktion class) before stamping "first".
