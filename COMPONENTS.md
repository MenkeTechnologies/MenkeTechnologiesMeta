# Shared Components × GUI Apps

Which shared submodules each GUI app consumes, plus the planned additions to fill the
gaps. Source of truth is each app's `.gitmodules`; this table is the human-readable map.

_Last reconciled: 2026-06-24._

## Components

| Component | Role |
|---|---|
| **zpwr-clip-engine** | Arrange/sequencer engine + clip/grid webui (being split out of `zpwr-daw.git`) |
| **zpwr-patch-core** | Modular patch-graph DSP engine + shared WebEditor (JUCE plugins) |
| **zpwr-embed-terminal** | Embedded PTY terminal (webview) |
| **zpwr-hooks-editor** | Monaco stryke hooks editor (webview) |
| **zpwr-crate** | Sample-library scan + SQLite/FTS persistence + faceted browser (+ bpm/key/lufs/similarity/sample_analysis) |
| **ztranslator** | Real-time MIDI/OSC/DMX/Link translation engine + view |
| **zpwr-file-browser** | Filesystem file manager (webui + Rust fs backend) |
| **zpwr-i18n** | Localization runtime (JSON loader) |
| **zpwr-algo-production** | One-click algorithmic track generation (.als / .zdp) |

## Current state

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | — | — |
| **traderview** | ✓ | — | ✓ | ✓ | — | ✓ | — | — | — |
| **ztranslator** | ✓ | — | ✓ | ✓ | — | _(source)_ | ✓ | ✓ | — |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | ✓ |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — |
| **# apps** | 7 | 4 | 4 | 4 | 2 | 3 | 2 | 1 | 1 |

## Planned additions (the plan)

| Add component | to apps |
|---|---|
| **crate** | traderview, ztranslator |
| **file-browser** | traderview, zpwr-daw |
| **i18n** | Audio-Haxor, zpwr-daw |
| **algo-production** | Audio-Haxor |

## Target state (➕ = planned)

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ➕ | ➕ |
| **traderview** | ✓ | — | ✓ | ✓ | ➕ | ✓ | ➕ | — | — |
| **ztranslator** | ✓ | — | ✓ | ✓ | ➕ | _(source)_ | ✓ | ✓ | — |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ➕ | ➕ | ✓ |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — |

## Checklist

- [ ] **crate → traderview** (add submodule, wire browse backend)
- [ ] **crate → ztranslator** (add submodule, wire browse backend)
- [ ] **file-browser → traderview** (add submodule + UI tab + fs backend)
- [ ] **file-browser → zpwr-daw** (add submodule + UI tab + fs backend)
- [ ] **i18n → Audio-Haxor** (add submodule + wire loader)
- [ ] **i18n → zpwr-daw** (add submodule + wire loader)
- [ ] **algo-production → Audio-Haxor** (add submodule + PRODUCE tab)

## Notes

- **clip-engine split (in progress):** every app's `zpwr-clip-engine` submodule still points
  at `zpwr-daw.git` (the pre-split shared repo). The split repoints them to
  `zpwr-clip-engine.git` once the arranger is extracted out of `zpwr-daw`.
- **zpwr-daw rename:** the daw repo is now `zpwr-daw.git` (was `zpwr-clip-engine`); the app
  lives in `zpwr-daw`, the shared arranger becomes the new `zpwr-clip-engine`.
- **Not consumed by any GUI app:** `zpwr-theme`, `zpwr-jobs`, `zpwr-license` (tooling/editor).
- **patch-core** is JUCE-plugin-only (daw + synth/fx/midi-fx); the Tauri apps don't use it.
