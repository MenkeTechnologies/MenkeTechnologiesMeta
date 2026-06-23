# MenkeTechnologies — Invention Ledger

Candidate "world's first" capabilities across the stack. The bar: a genuinely
**novel capability** (not a faster dup) **and** best-in-class implementation.
Every entry states the **claim**, its **basis**, and an honest **caveat** — a web
search is never exhaustive, so "no prior art found" is recorded as that, not as a
proven absolute. Claims are owned by MenkeTechnologies; this ledger just keeps them
honest and falsifiable.

| # | Claim | Basis | Caveat |
| --- | --- | --- | --- |
| 1 | **zpwr-daw — "a DAW within a DAW"**: a *complete* two-view DAW arranger (Arrangement **+** Session, clips, breakpoint automation, tempo/meter maps) that ships **standalone**, as a **VST3 plugin nested inside another DAW**, **and** embedded in any GUI app — audio or not (traderview → trades, ztranslator → translations, Audio-Haxor → stryke on clips). | Prior-art checked: Tracktion **Engine** is a *compile-time developer library*, not a loadable plugin; sequencer plugins (SEQUND, Stepic, B-Step, Playbeat) are *step sequencers*, not full DAWs. No prior art found for a **full DAW arranger as a nested plugin**, nor for one driving **non-audio** hosts off the same timeline. | Web search, not exhaustive. Audio playback path is written but **unverified** (pending a JUCE build); the editor/arranger/automation are verified. |

Other stack "first" claims (zshrs as a compiled shell, stryke's syntactic
synthesis, etc.) are documented in their own repos; add them here only with the
same claim / basis / caveat rigor.
