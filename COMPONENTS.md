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
| **zoffice-core** | Embeddable pure-Rust office engine — document/spreadsheet/presentation parse+edit, no GUI deps; links native (Rust/Tauri) + C ABI. Engine behind `zoffice` |
| **zemail-core** | Embeddable pure-Rust mail engine, no GUI deps; links native (Rust/Tauri) + C ABI. Engine behind `zemail` |

## Current state

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| **traderview** | ✓ | — | ✓ | ✓ | — | ✓ | — | — | — | — | — |
| **ztranslator** | ✓ | — | ✓ | ✓ | — | _(source)_ | ✓ | ✓ | — | — | — |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | ✓ | — | — |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — |
| **zoffice** | — | — | — | — | — | — | — | — | — | _(source)_ | — |
| **zemail** | — | — | — | — | — | — | — | — | — | — | _(source)_ |
| **# apps** | 7 | 4 | 4 | 4 | 2 | 3 | 2 | 1 | 1 | 0 | 0 |

## Planned additions (the plan)

| Add component | to apps |
|---|---|
| **crate** | traderview, ztranslator |
| **file-browser** | traderview, zpwr-daw |
| **i18n** | Audio-Haxor, zpwr-daw |
| **algo-production** | Audio-Haxor |
| **office-core** | every GUI app (Audio-Haxor, traderview, ztranslator, zpwr-daw, zoffice = source) |
| **mail-core** | every GUI app (Audio-Haxor, traderview, ztranslator, zpwr-daw, zemail = source) |
| **embed-terminal / file-browser / hooks-editor / i18n / clip-engine** | zoffice, zemail (the standard GUI-app component set, per GUI_APP_REQUIREMENTS.md) |

## Target state (➕ = planned)

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ➕ | ➕ | ➕ | ➕ |
| **traderview** | ✓ | — | ✓ | ✓ | ➕ | ✓ | ➕ | — | — | ➕ | ➕ |
| **ztranslator** | ✓ | — | ✓ | ✓ | ➕ | _(source)_ | ✓ | ✓ | — | ➕ | ➕ |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ➕ | ➕ | ✓ | ➕ | ➕ |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — |
| **zoffice** | ➕ | — | ➕ | ➕ | — | ➕ | ➕ | ➕ | — | _(source)_ | ➕ |
| **zemail** | ➕ | — | ➕ | ➕ | — | ➕ | ➕ | ➕ | — | ➕ | _(source)_ |

## Checklist

- [ ] **register meta submodules**: add `zoffice-core`, `zemail-core`, `zoffice`, `zemail` to the meta `.gitmodules` (all four are git repos but currently untracked in meta)
- [ ] **crate → traderview** (add submodule, wire browse backend)
- [ ] **crate → ztranslator** (add submodule, wire browse backend)
- [ ] **file-browser → traderview** (add submodule + UI tab + fs backend)
- [ ] **file-browser → zpwr-daw** (add submodule + UI tab + fs backend)
- [ ] **i18n → Audio-Haxor** (add submodule + wire loader)
- [ ] **i18n → zpwr-daw** (add submodule + wire loader)
- [ ] **algo-production → Audio-Haxor** (add submodule + PRODUCE tab)
- [ ] **office-core → every GUI app** (add submodule + Rust dep / C ABI + an office view)
- [ ] **mail-core → every GUI app** (add submodule + Rust dep / C ABI + a mail view)
- [ ] **zoffice / zemail** (build the GUI apps from their scaffolds; embed the standard component set + each other's `-core`)

## Notes

- **clip-engine split (done):** the arranger is its own repo `zpwr-clip-engine.git`; every app's
  `zpwr-clip-engine` submodule was repointed off `zpwr-daw.git` onto it. The real engine was
  extracted into `engine/` (C ABI, no JUCE) with a Rust FFI crate in `bindings/`; the daw consumes
  it (inline copies deleted) and all three Tauri apps drive it via FFI (`clip_seq_*` Tauri commands),
  with the non-audio JS backend kept only as the browser-dev fallback.
- **zpwr-daw rename (done):** the daw repo is `zpwr-daw.git`; the meta tracks separate `zpwr-daw`
  (the app) and `zpwr-clip-engine` (the shared arranger) submodules.
- **zoffice / zemail (new, scaffolds):** GUI apps (Tauri v2, cyberpunk HUD) — `zoffice` replaces MS
  Office (documents/spreadsheets/presentations), `zemail` is a desktop mail client. Both are
  README-only so far; their engines are `zoffice-core` / `zemail-core` (which exist with code —
  zoffice-core has `include`/`src`/`tests`, zemail-core is minimal). Both apps are paid products.
- **office-core / mail-core (new cores):** same embed pattern as `zpwr-clip-engine`'s engine — a
  pure-Rust core that links natively into Rust/Tauri hosts and over a C ABI elsewhere, so one office
  engine and one mail engine embed across the whole GUI stack.
- **Not consumed by any GUI app:** `zpwr-theme`, `zpwr-jobs`, `zpwr-license` (tooling/editor).
- **patch-core** is JUCE-plugin-only (daw + synth/fx/midi-fx); the Tauri apps don't use it.
