# Shared Components × GUI Apps

Which shared submodules each GUI app consumes, plus the planned additions to fill the
gaps. Source of truth is each app's `.gitmodules`; this table is the human-readable map.

_Last reconciled: 2026-06-24._

## Components

| Component | Role |
|---|---|
| **zpwr-clip-engine** | Arrange/sequencer engine + clip/grid webui; `engine/` = real C ABI engine (`zpc_clip_*`, no JUCE) + `bindings/` Rust FFI crate. Split out of `zpwr-daw.git` |
| **zpwr-patch-core** | Modular patch-graph DSP engine + shared WebEditor (JUCE plugins) |
| **zpwr-embed-terminal** | Embedded PTY terminal (webview) |
| **zpwr-hooks-editor** | Monaco stryke hooks editor (webview) |
| **zpwr-crate** | Sample-library scan + SQLite/FTS persistence + faceted browser (+ bpm/key/lufs/similarity/sample_analysis) |
| **ztranslator** | Real-time MIDI/OSC/DMX/Link translation engine + view |
| **zpwr-file-browser** | Filesystem file manager (webui + Rust fs backend) |
| **zpwr-i18n** | Localization runtime (JSON loader) |
| **zpwr-algo-production** | One-click algorithmic track generation (.als / .zdp) |
| **zoffice-core** | Embeddable pure-Rust office engine — document/spreadsheet/presentation parse+edit, no GUI deps; native (Rust/Tauri) + C ABI. Engine behind `zoffice` |
| **zemail-core** | Embeddable pure-Rust mail engine, no GUI deps; native (Rust/Tauri) + C ABI. Engine behind `zemail` |
| **zpdf-core** | Embeddable pure-Rust PDF engine — parse/edit/annotate/sign/embed, no GUI deps; native + C ABI. Engine behind `zpdf` |

## Current state

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core | pdf-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — | — |
| **traderview** | ✓ | — | ✓ | ✓ | — | ✓ | — | — | — | — | — | — |
| **ztranslator** | ✓ | — | ✓ | ✓ | — | _(source)_ | ✓ | ✓ | — | — | — | — |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | ✓ | — | — | — |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zoffice** | — | — | — | — | — | — | — | — | — | _(source)_ | — | — |
| **zemail** | — | — | — | — | — | — | — | — | — | — | _(source)_ | — |
| **zpdf** | — | — | — | — | — | — | — | — | — | — | — | _(source)_ |
| **# apps** | 7 | 4 | 4 | 4 | 2 | 3 | 2 | 1 | 1 | 0 | 0 | 0 |

## Planned additions (the plan)

| Add component | to apps |
|---|---|
| **crate** | traderview, ztranslator |
| **file-browser** | traderview, zpwr-daw |
| **i18n** | Audio-Haxor, zpwr-daw |
| **algo-production** | Audio-Haxor |
| **office-core** | every GUI app (zoffice = source) |
| **mail-core** | every GUI app (zemail = source) |
| **pdf-core** | every GUI app (zpdf = source) |
| **embed-terminal / file-browser / hooks-editor / i18n / clip-engine** | zoffice, zemail, zpdf (the standard GUI-app component set, per GUI_APP_REQUIREMENTS.md) |

## Target state (➕ = planned)

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core | pdf-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ➕ | ➕ | ➕ | ➕ | ➕ |
| **traderview** | ✓ | — | ✓ | ✓ | ➕ | ✓ | ➕ | — | — | ➕ | ➕ | ➕ |
| **ztranslator** | ✓ | — | ✓ | ✓ | ➕ | _(source)_ | ✓ | ✓ | — | ➕ | ➕ | ➕ |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ➕ | ➕ | ✓ | ➕ | ➕ | ➕ |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zoffice** | ➕ | — | ➕ | ➕ | — | ➕ | ➕ | ➕ | — | _(source)_ | ➕ | ➕ |
| **zemail** | ➕ | — | ➕ | ➕ | — | ➕ | ➕ | ➕ | — | ➕ | _(source)_ | ➕ |
| **zpdf** | ➕ | — | ➕ | ➕ | — | ➕ | ➕ | ➕ | — | ➕ | ➕ | _(source)_ |

## Checklist

- [ ] **register meta submodules**: add `zoffice-core`, `zemail-core`, `zoffice`, `zemail` to the meta `.gitmodules` (all four are git repos but currently untracked in meta). `zpdf` + `zpdf-core` are already registered submodules.
- [ ] **crate → traderview** (add submodule, wire browse backend)
- [ ] **crate → ztranslator** (add submodule, wire browse backend)
- [ ] **file-browser → traderview** (add submodule + UI tab + fs backend)
- [ ] **file-browser → zpwr-daw** (add submodule + UI tab + fs backend)
- [ ] **i18n → Audio-Haxor** (add submodule + wire loader)
- [ ] **i18n → zpwr-daw** (add submodule + wire loader)
- [ ] **algo-production → Audio-Haxor** (add submodule + PRODUCE tab)
- [ ] **office-core → every GUI app** (add submodule + Rust dep / C ABI + an office view)
- [ ] **mail-core → every GUI app** (add submodule + Rust dep / C ABI + a mail view)
- [ ] **pdf-core → every GUI app** (add submodule + Rust dep / C ABI + a PDF view)
- [ ] **office-core → traderview** (add submodule + Rust dep / C ABI + an office view)
- [ ] **mail-core → traderview** (add submodule + Rust dep / C ABI + a mail view)
- [ ] **pdf-core → traderview** (add submodule + Rust dep / C ABI + a PDF view)
- [ ] **zoffice / zemail / zpdf** (embed the standard component set + each other's `-core`; zoffice/zemail still scaffolds, zpdf is further along)

## Notes

- **clip-engine split (done):** the arranger is its own repo `zpwr-clip-engine.git`; every app's
  `zpwr-clip-engine` submodule was repointed off `zpwr-daw.git` onto it. The real engine was
  extracted into `engine/` (C ABI, no JUCE) with a Rust FFI crate in `bindings/`; the daw consumes
  it (inline copies deleted) and all three Tauri apps drive it via FFI (`clip_seq_*` Tauri commands),
  with the non-audio JS backend kept only as the browser-dev fallback.
- **zpwr-daw rename (done):** the daw repo is `zpwr-daw.git`; the meta tracks separate `zpwr-daw`
  (the app) and `zpwr-clip-engine` (the shared arranger) submodules.
- **The `-core` embed pattern:** `zoffice-core` / `zemail-core` / `zpdf-core` follow the same model as
  `zpwr-clip-engine`'s engine — a pure-Rust core that links natively into Rust/Tauri hosts and over a
  C ABI elsewhere, so one office engine, one mail engine, and one PDF engine embed across the whole
  GUI stack ("the PDF engine that drops into any window").
- **zpdf (further along):** from-scratch PDF editor (Tauri v2) porting the Adobe Acrobat Pro + macOS
  Preview feature set; `zpdf` + `zpdf-core` are already meta submodules and `zpdf` embeds `zpdf-core`
  (nested). Its embedding into the OTHER GUI apps + the standard component set inside it are still TODO.
- **zoffice / zemail (new, scaffolds):** GUI apps (Tauri v2, cyberpunk HUD) — `zoffice` replaces MS
  Office (documents/spreadsheets/presentations), `zemail` is a desktop mail client. Both are
  README-only so far; engines `zoffice-core` (has `include`/`src`/`tests`) / `zemail-core` (minimal)
  exist. zoffice/zemail/zpdf are paid products.
- **Not consumed by any GUI app:** `zpwr-theme`, `zpwr-jobs`, `zpwr-license` (tooling/editor).
- **patch-core** is JUCE-plugin-only (daw + synth/fx/midi-fx); the Tauri apps don't use it.
