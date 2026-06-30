# Shared Components × GUI Apps

Which shared submodules each GUI app consumes. Source of truth is each app's `.gitmodules`;
this table is the human-readable map. Any `-core` engine can be embedded in any GUI app, and
every GUI app embeds the full shared component set it needs.

_Last reconciled: 2026-06-30._

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
| **zphoto-core** | Embeddable pure-Rust raster-imaging engine — layers/selections/filters/export, no GUI deps; native + C ABI. Engine behind `zphoto` |
| **ztmux-core** | Embeddable pure-Rust terminal/tmux engine (PTY + tmux wire-protocol control), no GUI deps. Engine behind `zterminal` |

## Consumption matrix

`✓` = consumed. `—` = not applicable to that app (the JUCE plugins consume only the clip/patch
engines; `zterminal` is itself the terminal, so it doesn't embed `embed-terminal`). `(source)` =
the app that owns that engine. The office/mail/pdf cores embed across every full GUI app.

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core | pdf-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **traderview** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **ztranslator** | ✓ | — | ✓ | ✓ | ✓ | _(source)_ | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zoffice** | ✓ | — | ✓ | ✓ | — | ✓ | ✓ | ✓ | — | _(source)_ | ✓ | ✓ |
| **zemail** | ✓ | — | ✓ | ✓ | — | ✓ | ✓ | ✓ | — | ✓ | _(source)_ | ✓ |
| **zpdf** | ✓ | — | ✓ | ✓ | — | ✓ | ✓ | ✓ | — | ✓ | ✓ | _(source)_ |
| **zcite** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **zreq** | ✓ | — | ✓ | ✓ | — | — | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **zphoto** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **zterminal** | — | — | — | ✓ | — | — | ✓ | ✓ | — | ✓ | ✓ | ✓ |

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
  hosts and over a C ABI elsewhere, so one engine each embeds across the whole GUI stack. Any `-core`
  can be embedded in any GUI app.
- **ztranslator-core (extracted):** the MIDI/OSC/DMX/Link engine is split out of the `ztranslator` app
  into `ztranslator-core.git`. The `ztranslator` repo keeps the standalone app + the shared
  `ztranslator_view.js`; the engine + C ABI live in the core, so haxor/traderview/daw embed
  `ztranslator-core` rather than the app repo. The "ztranslator" matrix column tracks apps embedding
  that engine (haxor/traderview/daw; ztranslator = view source).
- **zpdf:** from-scratch PDF editor (Tauri v2) porting the Adobe Acrobat Pro + macOS Preview feature
  set; `zpdf` + `zpdf-core` are meta submodules, `zpdf` embeds `zpdf-core` (nested) plus the standard
  component set, and the other GUI apps embed `zpdf-core`.
- **zoffice / zemail:** GUI apps (Tauri v2, cyberpunk HUD) — `zoffice` replaces MS Office
  (documents/spreadsheets/presentations), `zemail` is a desktop mail client. Both ship a Tauri app
  shell (`frontend/` + `src-tauri`) and a `pnpm t` suite driving their engines `zoffice-core` /
  `zemail-core`, and both embed the full shared component set + each other's `-core`.
  zoffice/zemail/zpdf are paid products.
- **zphoto / zterminal:** GUI apps (Tauri v2, cyberpunk HUD, `zgui-core`). `zphoto` is a from-scratch
  raster editor replacing GIMP/Photoshop — it vendors `gimp`, embeds its own `zphoto-core` engine,
  consumes `zpwr-i18n`, and embeds the rest of the standard set. `zterminal` is a GPU-accelerated
  terminal emulator embedding `ztmux-core` (PTY + tmux wire-protocol control); the standard
  `embed-terminal` component is n/a since it is itself the terminal. Both are **paid products** in the
  app-store. `zphoto-core` / `ztmux-core` follow the same `-core` embed model as `zpdf-core`; they have
  no matrix column of their own since they are app-specific engines.
- **Not consumed by any GUI app:** `zpwr-theme`, `zpwr-jobs`, `zpwr-license` (tooling/editor).
- **patch-core** is JUCE-plugin-only (daw + synth/fx/midi-fx); the Tauri apps don't use it.
- **zgui-core (extracted):** the shared `window.ZGui` chrome toolkit (shell/settings/dialog/table/
  command-palette/fzf/colorscheme/notification) pulled out of Audio-Haxor / zreq / `zpwr-patch-core` so
  the GUI apps stop re-implementing divergent copies. Consumed like `zpwr-i18n` (copy `webui/*` into each
  app's `frontend/` at build time), so it sits outside the per-component matrix above.
- **zdsp-core (extracted):** the audio-stack analog of `zgui-core` — a shared real-time audio DSP
  engine (C++, header-only, JUCE-based) so the audio apps stop re-deriving the same DSP units. The full
  DSP stack + playback pipeline is extracted from the Audio-Haxor audio-engine: `OlaTimeStretch`
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
