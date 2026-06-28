# Shared Components × GUI Apps

Which shared submodules each GUI app consumes, plus the planned additions to fill the
gaps. Source of truth is each app's `.gitmodules`; this table is the human-readable map.

_Last reconciled: 2026-06-25._

## Components

| Component | Role |
|---|---|
| **zpwr-clip-engine** | Arrange/sequencer engine + clip/grid webui; `engine/` = real C ABI engine (`zpc_clip_*`, no JUCE) + `bindings/` Rust FFI crate. Split out of `zpwr-daw.git` |
| **zpwr-patch-core** | Modular patch-graph DSP engine + shared WebEditor (JUCE plugins) |
| **zpwr-embed-terminal** | Embedded PTY terminal (webview) |
| **zpwr-hooks-editor** | Monaco stryke hooks editor (webview) |
| **zpwr-crate** | Sample-library scan + SQLite/FTS persistence + faceted browser (+ bpm/key/lufs/similarity/sample_analysis) |
| **ztranslator** | The standalone translation app + the shared `ztranslator_view.js` (the view embedded in other apps); engine now lives in `ztranslator-core` |
| **ztranslator-core** | Embeddable pure-Rust MIDI/OSC/DMX/Link translation engine, no GUI deps; native (Rust/Tauri) + C ABI. Engine behind the `ztranslator` app + what other apps embed |
| **zpwr-file-browser** | Filesystem file manager (webui + Rust fs backend) |
| **zpwr-i18n** | Localization runtime (JSON loader) |
| **zgui-core** | Shared cyberpunk GUI toolkit (webui) — canonical shell/settings/dialog/table/command-palette/fzf/colorscheme/notification chrome on `window.ZGui`; extracted from Audio-Haxor, zreq, `zpwr-patch-core` |
| **zdsp-core** | Shared real-time audio DSP engine (C++, header-only, JUCE-based) — the audio-stack analog of `zgui-core`: 7 canonical DSP units + playback pipeline on `zdsp::core` (OlaTimeStretch/SpeedMode, channel-strip, tone, peak-meter, spectrogram, lock-free streaming, DspStereoFileSource orchestrator); verbatim-extracted from the Audio-Haxor audio-engine, vendored by Audio-Haxor / `zpwr-patch-core` / the plugin apps. **Paid product** — proprietary (`UNLICENSED`) |
| **zpwr-algo-production** | One-click algorithmic track generation (.als / .zdp) |
| **zoffice-core** | Embeddable pure-Rust office engine — document/spreadsheet/presentation parse+edit, no GUI deps; native (Rust/Tauri) + C ABI. Engine behind `zoffice` |
| **zemail-core** | Embeddable pure-Rust mail engine, no GUI deps; native (Rust/Tauri) + C ABI. Engine behind `zemail` |
| **zpdf-core** | Embeddable pure-Rust PDF engine — parse/edit/annotate/sign/embed, no GUI deps; native + C ABI. Engine behind `zpdf` |

## Current state

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core | pdf-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| **traderview** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| **ztranslator** | ✓ | — | ✓ | ✓ | ✓ | _(source)_ | ✓ | ✓ | — | — | — | — |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | ✓ | — | — | — |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zoffice** | — | — | — | — | — | — | — | — | — | _(source)_ | — | — |
| **zemail** | — | — | — | — | — | — | — | — | — | — | _(source)_ | — |
| **zpdf** | — | — | — | — | — | — | — | — | — | — | — | _(source)_ |
| **# apps** | 7 | 4 | 4 | 4 | 4 | 3 | 3 | 3 | 1 | 0 | 0 | 0 |

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

- [ ] **register meta submodules**: add `zoffice-core`, `zemail-core`, `zoffice`, `zemail`, `ztranslator-core` to the meta `.gitmodules` (all git repos but currently untracked in meta). `zpdf` + `zpdf-core` are already registered submodules.
- [ ] **ztranslator-core extraction**: move the engine (`ztranslator/src` lib `ztranslator-engine` + `capi`) into `ztranslator-core`; repoint the `ztranslator` app + its Tauri plugin + every embedding app (Audio-Haxor, traderview, zpwr-daw) onto `ztranslator-core` (README-only so far)
- [x] **crate → traderview** — DONE (b7b6dbf7b6): submodule + 4 commands; sqlite conflict fixed via stack-wide rusqlite 0.32
- [x] **crate → ztranslator** — DONE (9c66141429): submodule + 4 commands, cargo check green
- [x] **file-browser → traderview** — DONE (4309cd1964 backend + df7d523217 UI): 33 fs_* cmds + vendored UI
- [ ] **file-browser → zpwr-daw** (add submodule + UI tab + fs backend)
- [x] **i18n → Audio-Haxor** — DONE (789857db28): shared zpwr-i18n, local i18n-ui.js dropped
- [x] **i18n → traderview** — DONE (d5fca994b9): shared zpwr-i18n runtime + ESM shim (all GUI apps standardize on it, fix translations 1x)
- [ ] **i18n → zpwr-daw** (add submodule + wire loader)
- [ ] **algo-production → Audio-Haxor** (add submodule + PRODUCE tab)
- [ ] **office-core → every GUI app** (add submodule + Rust dep / C ABI + an office view)
- [ ] **mail-core → every GUI app** (add submodule + Rust dep / C ABI + a mail view)
- [ ] **pdf-core → every GUI app** (add submodule + Rust dep / C ABI + a PDF view)
- [ ] **office-core → traderview** (add submodule + Rust dep / C ABI + an office view)
- [ ] **mail-core → traderview** (add submodule + Rust dep / C ABI + a mail view)
- [ ] **pdf-core → traderview** (add submodule + Rust dep / C ABI + a PDF view)
- [ ] **pdf-core → zpwr-daw** (PDF tab/view + path-aware `openPdf`; embed engine)
- [ ] **pdf-core → Audio-Haxor** (PDF overlay + path-aware `openPdf`; embed engine)
- [ ] **crate → embedded zpdf**: in apps with both the crate/content browser AND a PDF view (Audio-Haxor, zpwr-daw), opening a `.pdf` from the crate routes to the embedded `openPdf(path)` view instead of the external/default opener (PDF views are placeholders until `zpdf-core` is wired)
- [ ] **zoffice / zemail / zpdf** (embed the standard component set + each other's `-core`; zoffice/zemail have app shells but haven't embedded the set yet, zpdf is further along)

## Notes

- **clip-engine split (done):** the arranger is its own repo `zpwr-clip-engine.git`; every app's
  `zpwr-clip-engine` submodule was repointed off `zpwr-daw.git` onto it. The real engine was
  extracted into `engine/` (C ABI, no JUCE) with a Rust FFI crate in `bindings/`; the daw consumes
  it (inline copies deleted) and all three Tauri apps drive it via FFI (`clip_seq_*` Tauri commands),
  with the non-audio JS backend kept only as the browser-dev fallback.
- **zpwr-daw rename (done):** the daw repo is `zpwr-daw.git`; the meta tracks separate `zpwr-daw`
  (the app) and `zpwr-clip-engine` (the shared arranger) submodules.
- **The `-core` embed pattern:** `ztranslator-core` / `zoffice-core` / `zemail-core` / `zpdf-core` follow
  the same model as `zpwr-clip-engine`'s engine — a pure-Rust core that links natively into Rust/Tauri
  hosts and over a C ABI elsewhere, so one engine each embeds across the whole GUI stack.
- **ztranslator-core (new, extracted):** the MIDI/OSC/DMX/Link engine is being split out of the
  `ztranslator` app into `ztranslator-core.git` (README-only so far). The `ztranslator` repo keeps the
  standalone app + the shared `ztranslator_view.js`; the engine + C ABI move to the core, so haxor/
  traderview/daw embed `ztranslator-core` rather than the app repo. The "ztranslator" matrix column
  already tracks apps embedding that engine (haxor/traderview/daw; ztranslator = view source).
- **zpdf (further along):** from-scratch PDF editor (Tauri v2) porting the Adobe Acrobat Pro + macOS
  Preview feature set; `zpdf` + `zpdf-core` are already meta submodules and `zpdf` embeds `zpdf-core`
  (nested). Its embedding into the OTHER GUI apps + the standard component set inside it are still TODO.
- **zoffice / zemail (early apps):** GUI apps (Tauri v2, cyberpunk HUD) — `zoffice` replaces MS
  Office (documents/spreadsheets/presentations), `zemail` is a desktop mail client. Both now ship a
  Tauri app shell (`frontend/` + `src-tauri`) and a `pnpm t` suite driving their engines
  `zoffice-core` (has `include`/`src`/`tests`) / `zemail-core`; still adopting the full shared
  component set. zoffice/zemail/zpdf are paid products.
- **Not consumed by any GUI app:** `zpwr-theme`, `zpwr-jobs`, `zpwr-license` (tooling/editor).
- **patch-core** is JUCE-plugin-only (daw + synth/fx/midi-fx); the Tauri apps don't use it.
- **zgui-core (new, extracted):** the shared `window.ZGui` chrome toolkit (shell/settings/dialog/table/
  command-palette/fzf/colorscheme/notification) pulled out of Audio-Haxor / zreq / `zpwr-patch-core` so
  the GUI apps stop re-implementing divergent copies. Consumed like `zpwr-i18n` (copy `webui/*` into each
  app's `frontend/` at build time). Per-app consumption not yet added to the matrix above — needs a
  reconciliation pass against each app's `.gitmodules`.
- **zdsp-core (new, extracted):** the audio-stack analog of `zgui-core` — a shared real-time audio DSP
  engine (C++, header-only, JUCE-based) so the audio apps stop re-deriving the same DSP units. The full
  DSP stack + playback pipeline is already extracted from the Audio-Haxor audio-engine: `OlaTimeStretch`
  (+ `SpeedMode`), `channel_strip` (lock-free 3-band IIR EQ + gain/pan via RT-safe `DspAtomics`),
  `ToneAudioSource`, `InputPeakCallback`, `computeSpectrogramGrid` (offline STFT → dBFS grid, the DSP
  half of `ZGui.viz`), `LockFreeStreamSource` (RT-safe streaming + glitch-free stream→RAM hot-swap),
  and `DspStereoFileSource` (the transport-ready orchestrator composing all of the above; the app
  implements the `InsertChain` plugin-rack interface). Consumers `add_subdirectory(zdsp-core)` and link
  `zdsp::core` (JUCE must already be present — the lib does not fetch it). Vendored by Audio-Haxor,
  `zpwr-patch-core`, and the plugin apps (`zpwr-daw` / `zpwr-synth` / `zpwr-fx` / `zpwr-midi-fx`). What
  stays in each app: file-format wiring, IPC/transport plumbing, plugin scanning, and the `InsertChain`
  implementation. **Paid product** — proprietary (`UNLICENSED`). Not a GUI-app webui component, so it's
  outside the consumption matrix above.
