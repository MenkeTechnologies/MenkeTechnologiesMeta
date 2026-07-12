# Shared Components × GUI Apps

Which shared submodules each GUI app consumes. Source of truth is each app's `.gitmodules`;
this table is the human-readable map. Any `-core` engine can be embedded in any GUI app, and
every GUI app embeds the full shared component set it needs.

> For *which power-user surfaces each app actually turns on* (GUI scripting / tmux bar / tmux WM /
> vim / hooks editor) — as opposed to which submodules it embeds — see
> [`GUI_FEATURE_MATRIX.md`](GUI_FEATURE_MATRIX.md).

_Last reconciled: 2026-07-12._

## Components

| Component | Role |
|---|---|
| **zpwr-clip-engine** | Arrange/sequencer engine + clip/grid webui; `engine/` = real C ABI engine (`zpc_clip_*`, no JUCE) + `bindings/` Rust FFI crate. Split out of `zpwr-daw.git` |
| **zpwr-patch-core** | Modular patch-graph DSP engine + shared WebEditor (JUCE plugins) |
| **zpwr-embed-terminal** | Embedded PTY terminal (webview) |
| **zpwr-hooks-editor** | Monaco stryke hooks editor (webview) |
| **zpwr-crate** | Sample-library scan + SQLite/FTS persistence + faceted browser (+ bpm/key/lufs/similarity/sample_analysis) |
| **ztranslator** | The standalone translation app + the shared `ztranslator_view.js` (the view embedded in other apps); engine now lives in `ztranslator-core` |
| **ztranslator-core** | Embeddable pure-Rust event-translation/routing engine (MIDI / OSC / DMX / Link / file-watcher triggers → a large outgoing protocol matrix), not a MIDI-only engine; no GUI deps; native (Rust/Tauri) + C ABI. Engine behind the `ztranslator` app + what other apps embed |
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
| **zgui-bridge** | GUI Automation Bus host — one Unix socket per app exposing its verbs/state/events (what `stryke-app` drives). Mounted by 16 apps |
| **zwire-host** | Native-messaging / system-stats / PTY host binary shared with `zwire`. Mounted by 9 apps (`zreq`, `zoffice`, `zpdf`, `zftp`, `zphoto`, `zemail`, `zthrottle`, `zemacs-gui`, `zwire`) |
| **zpwr-modal-editor** | Shared Vim/Emacs modal-editing surface. Mounted by `zoffice` + `zemail` |

## Consumption matrix

`✓` = consumed. `—` = not consumed by that app. `(source)` = the app that owns that engine (it is
also the app's own submodule, so `(source)` implies consumption). Derived from each app's
`.gitmodules` at the SHA this meta repo pins — a component counts only where the app actually
mounts it, not where it could. The office/mail/pdf cores are *not* universal: only `zemail` and
`zftp` embed all three.

One row reads as empty and that is correct: `zterminal` mounts only `zgui-core` + `ztmux-core`
(neither is a column here) — it *is* the terminal, so it embeds no `embed-terminal` and no hooks
editor. `zwire` carries a single `✓¹` (the vendored hooks editor). The JUCE plugins mount only the
clip/patch engines. `zgui-bridge`, `zwire-host` and `zpwr-modal-editor` are mounted broadly but have
no column here; see the component table above for their consumers.

| App | clip-engine | patch-core | embed-terminal | hooks-editor | crate | ztranslator | file-browser | i18n | algo | office-core | mail-core | pdf-core |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Audio-Haxor** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | ✓ |
| **traderview** | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| **ztranslator** | ✓ | — | ✓ | ✓ | ✓ | _(source)_ | ✓ | ✓ | — | — | — | — |
| **zpwr-daw** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ | — | — | — |
| **zpwr-synth** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zpwr-midi-fx** | ✓ | ✓ | — | — | — | — | — | — | — | — | — | — |
| **zoffice** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | _(source)_ | — | — |
| **zemail** | ✓ | — | ✓ | ✓ | — | — | ✓ | ✓ | — | ✓ | _(source)_ | ✓ |
| **zpdf** | — | — | ✓ | ✓ | — | — | ✓ | — | — | — | — | _(source)_ |
| **zcite** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **zreq** | ✓ | — | ✓ | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **zgo** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **zftp** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | ✓ | ✓ | ✓ |
| **zcontainer** | — | — | — | ✓ | — | — | ✓ | — | — | — | — | — |
| **zstation** | ✓ | — | ✓ | ✓ | — | ✓ | ✓ | ✓ | — | — | — | — |
| **zphoto** | — | — | — | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **ztunnel** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **zthrottle** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **zemacs-gui** | — | — | ✓ | ✓ | — | — | ✓ | ✓ | — | — | — | — |
| **zwire** | — | — | — | ✓¹ | — | — | — | — | — | — | — | — |
| **zterminal** | — | — | — | — | — | — | — | — | — | — | — | — |

<sub>¹ `zwire` vendors the hooks editor at `extensions/hud-internal/vendor/zpwr-hooks-editor` rather
than as a top-level submodule; its own submodules are `zgui-core`, `zpwrchrome`, `zwire-host`.</sub>

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
- **ztranslator-core (extracted):** the event-translation engine (MIDI / OSC / DMX / Link / file-watcher triggers) is split out of the `ztranslator` app
  into `ztranslator-core.git`. The `ztranslator` repo keeps the standalone app + the shared
  `ztranslator_view.js`; the engine + C ABI live in the core. Current wiring is mixed and literal:
  `zpwr-daw` and `zstation` mount `ztranslator-core` only, `traderview` still mounts the **app** repo
  (`crates/ztranslator`) for the view, and `Audio-Haxor` mounts **both** (app repo + core). The
  "ztranslator" matrix column marks apps embedding either, since both carry the view.
- **zpdf:** from-scratch PDF editor (Tauri v2) porting the Adobe Acrobat Pro + macOS Preview feature
  set; `zpdf` + `zpdf-core` are meta submodules, `zpdf` embeds `zpdf-core` (nested) plus the standard
  component set. `zpdf-core` is *not* universal — outside `zpdf` itself, only `Audio-Haxor`, `zemail`
  and `zftp` mount it.
- **zoffice / zemail:** GUI apps (Tauri v2, cyberpunk HUD) — `zoffice` replaces MS Office
  (documents/spreadsheets/presentations), `zemail` is a desktop mail client. Both ship a Tauri app
  shell (`frontend/` + `app/src-tauri`) and a `pnpm t` suite driving their engines `zoffice-core` /
  `zemail-core`, and both add `zpwr-modal-editor` on top of the standard set. The cross-embed is
  one-way: `zemail` mounts `zoffice-core` (plus `zpdf-core`), `zoffice` mounts neither `zemail-core`
  nor `zpdf-core`. zoffice/zemail/zpdf are paid products.
- **zphoto / zterminal:** GUI apps (Tauri v2, cyberpunk HUD, `zgui-core`). `zphoto` is a from-scratch
  raster editor replacing GIMP/Photoshop — it embeds its own `zphoto-core` engine, consumes
  `zpwr-i18n`, and embeds the rest of the standard set (it does not vendor `gimp`). `zterminal` is a GPU-accelerated
  terminal emulator embedding `ztmux-core` (PTY + tmux wire-protocol control); the standard
  `embed-terminal` component is n/a since it is itself the terminal. Both are **paid products** in the
  app-store. `zphoto-core` / `ztmux-core` follow the same `-core` embed model as `zpdf-core`; they have
  no matrix column of their own since they are app-specific engines.
- **Ported Tauri apps (zgo / zftp / zcontainer / zstation):** the four newest ported GUI apps —
  `zgo` (Alfred), `zftp` (Cyberduck), `zcontainer` (Docker Desktop + Lens), `zstation` (Station) —
  follow the same full-GUI-app convention as the rows above: the standard set (embed-terminal /
  hooks / file-browser / i18n / office-core / mail-core / pdf-core) shows the intended embed, not
  necessarily what each app's `.gitmodules` has wired yet. Current variable-column wiring is
  literal: `zstation` embeds `zpwr-clip-engine` + `ztranslator-core` (both ✓); `zftp` already wires
  `office-core` / `mail-core` / `pdf-core` in `.gitmodules`; `zcontainer` wires `zcontainer-core`,
  `zpwr-file-browser`, `zpwr-hooks-editor`, `zgui-core` and `zgui-bridge` — so both of its matrix ✓s
  are real wiring, and it mounts no `embed-terminal` / `i18n` yet.
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
  `zdsp::core` (JUCE must already be present — the lib does not fetch it). Mounted directly by only
  Audio-Haxor and `zpwr-patch-core`; the plugin apps (`zpwr-daw` / `zpwr-synth` / `zpwr-fx` /
  `zpwr-midi-fx`) get it transitively through their `zpwr-patch-core` mount. What
  stays in each app: file-format wiring, IPC/transport plumbing, plugin scanning, and the `InsertChain`
  implementation. **Paid product** — proprietary (`UNLICENSED`). Not a GUI-app webui component, so it's
  outside the consumption matrix above.
