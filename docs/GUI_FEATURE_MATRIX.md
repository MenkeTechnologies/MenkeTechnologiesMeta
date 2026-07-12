# GUI Feature Matrix — power-user surfaces per app

Which **power-user surfaces** each desktop GUI app actually wires: GUI scripting (automation
bus), the tmux/powerline status bar, the tmux tiling WM, vim mode (editor + app-level), and the
stryke hooks editor. Companion to [`COMPONENTS.md`](COMPONENTS.md) (which shared submodule each app
*embeds*) and [`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md) (the full generated verb catalog).

Where `COMPONENTS.md` says *what an app pulls in*, this says *what an app turns on* — several of
these surfaces ship in `zgui-core` but must be `init()`'d per app, so presence is verified at the
call site, not by the submodule being vendored.

_Verified 2026-07-11 by grepping each app's real entry/frontend + `src-tauri` at the recorded
gitlink: `.powerline.init(` / `.tmux.init(` for the bars, `serve("<app>")` + `bus::start` for the
socket, `monaco-vim` / `initVimMode` for editor vim, app-specific vim handlers for app-level vim,
`hooks-editor-entry` for the hooks editor. Engine-verb counts come from `GUI_SCRIPT_ACTIONS.md`._

---

## What each surface is

| Surface | Where it lives | What it is |
| --- | --- | --- |
| **GUI scripting (bus)** | `zgui-bridge` (Rust socket) + `zgui-core/webui/automation*.js` | Per-app Unix socket so a stryke script drives the app by name — `App::open("<app>")->call(...)`, and `App::here()` from a hook running inside it. Verbs cataloged in [`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md). |
| **tmux status bar** | `zgui-core/webui/powerline.js` (`ZGui.powerline`) | Powerline bar pinned to the bottom: `C-b` prefix light · scheme · tmux windows · VIM segment · CPU/MEM/SWAP/DISK/IO/NET/LOAD/UP/TEMP/BATT/LAN/WAN/host/clock. Ported from zwire's `zstatus.js`. |
| **tmux tiling WM** | `zgui-core/webui/tmux.js` (`ZGui.tmux`) | Real in-app tiling overlay: SESSION → WINDOWS (tabs) → PANES, split both ways, nested, copy-mode, synchronize-panes, command-prompt. Ported from zwire's `ztmux.js`. |
| **vim (editor)** | `zpwr-hooks-editor` → `monaco-vim` | Vim keybindings + `:cmd` line inside the Monaco hooks editor — present wherever the hooks editor is. |
| **vim (app-level)** | app-owned | Vim navigation over the whole app UI (`hjkl` / marks / `/` search / `:cmd`), not just inside an editor. |
| **hooks editor** | `zpwr-hooks-editor` | Monaco stryke-hooks editor embed. |

---

## Track A — Tauri / webview apps

Legend: **✓** wired · **·** not wired · **native** app implements its own, not the zgui-core one.
"Bus verbs" = the app's **live** automation-bus surface — what `App::open("<app>")->verbs()` returns
over the socket (shared appShell verbs + engine/`opts.commands` + dynamically-registered verbs),
read from the running app by [`bin/gen-gui-actions-live`](../bin/gen-gui-actions-live) and cataloged
in [`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md).

| App | GUI scripting (bus) | Bus verbs | tmux bar | tmux WM | vim (editor) | vim (app) | hooks editor |
| --- |:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **zpdf** | ✓ | 649 | ✓ | ✓ | ✓ | · | ✓ |
| **zemail** | ✓ | 208 | ✓ | ✓ | ✓ | · | ✓ |
| **zcite** | ✓ | 206 | ✓ | ✓ | ✓ | · | ✓ |
| **zftp** | ✓ | 160 | ✓ | ✓ | ✓ | · | ✓ |
| **zreq** | ✓ | 151 | ✓ | ✓ | ✓ | · | ✓ |
| **ztunnel** | ✓ | 125 | ✓ | ✓ | ✓ | · | ✓ |
| **zoffice** | ✓ | 199 | ✓ | ✓ | ✓ | ✓ | ✓ |
| **zthrottle** | ✓ | 91 | ✓ | ✓ | ✓ | · | ✓ |
| **zgo** | ✓ | 140 | ✓ | ✓ | ✓ | · | ✓ |
| **traderview** | ✓ | 1732 | ✓ | ✓ | ✓ | · | ✓ |
| **zphoto** | ✓ | 101 | ✓ | ✓ | ✓ | · | ✓ |
| **zstation** | ✓ | 37 | ✓ | ✓ | ✓ | · | ✓ |
| **zcontainer** | ✓ | 25 | ✓ | ✓ | ✓ | · | ✓ |
| **Audio-Haxor** | ✓ | 239 | ✓ | ✓ | ✓ | · | ✓ |
| **ztranslator** | ✓ | 54 | ✓ | ✓ | ✓ | · | ✓ |
| **zwire** | native² | 161 | ✓ | ✓ | ✓ | ✓ | ✓ |
| **zterminal** | · | — | native³ | native³ | · | · | · |

**On the counts** — every Bus-verbs number is the app's **live** surface, read from the running app
over its automation-bus socket by `bin/gen-gui-actions-live` (a stryke script that opens each app,
queries `verbs()` via a native Unix-domain socket, and closes it). This captures the *whole* runtime
surface — appShell verbs, engine/`opts.commands`, and verbs registered dynamically at load — which a
static source grep cannot see. A static verb source (a `-core/commands.rs` list or a `"ns.verb" =>`
dispatch) is often *larger* than the live bus surface (an engine may expose 218 internal ops but wire
only 25 onto the bus), so these are the authoritative *callable* counts, not source-line counts.

² **zwire** scripts through its **own** native bus (`zwire-host/src/zbus.rs`, 161 verbs — the
Chromium-superset browser control surface: tabs/windows/tab-groups/downloads/reading-list/power),
not the `zgui-bridge` socket. The powerline bar, tmux WM, and app-level vim (`hjkl` / `H M L` /
`gg G` / marks / `:cmd`, `/`-search) all originate here — `zgui-core`'s `powerline.js` / `tmux.js`
are the generalized ports of zwire's `zstatus.js` / `ztmux.js`.

³ **zterminal** is the GPU terminal itself: it ships a **native** status bar and **native** tmux
(the `ztmux-core` tmux wire-protocol client), not the `zgui-core` webview components. It doesn't
mount the appShell, so it has no automation-bus socket, no hooks editor, and no editor vim (vim
runs *inside* it). Embedded-terminal component is n/a for the same reason.

---

## Track B — JUCE plugins (`zpwr-daw` engine · `zpwr-synth` · `zpwr-fx` · `zpwr-midi-fx`)

No `window.ZGui`, no Tauri `invoke`. The automation-bus, powerline bar, and tmux WM are **not
wired** for the JUCE surface — the bus substrate for Track B (C++/C-ABI surface, per-plugin-instance
socket addressing) is still unbuilt (see [`GUI_AUTOMATION_BUS_CHECKLIST.md`](GUI_AUTOMATION_BUS_CHECKLIST.md)
§0B). `zpwr-daw`'s **Tauri shell** carries monaco-vim + the hooks editor through its embedded
`ztranslator-core` webview; the JUCE `ClipEngine` half does not.

---

## Notes

- **The webview surfaces are shared, so the answer is "nearly all of them."** The differentiation is
  at the outliers: `zterminal` (native everything, no webview shell) and the JUCE plugins (no
  webview at all). Every full Tauri app mounts the same `zgui-core` shell and therefore gets the
  same bar / tmux WM / hooks / editor-vim by construction — this uniformity is intentional (identical
  cyberpunk HUD across apps).
- **App-level vim** (whole-UI vim navigation, not just the Monaco editor) is only in **zoffice**
  (`zoVimMode` editing mode) and **zwire** (browser-wide vim keys). Everywhere else "vim" means the
  `monaco-vim` binding inside the hooks editor.
- **GUI scripting is live, not planned.** [`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md) is
  regenerated by `bin/gen-gui-actions-live` — which opens every app, reads its live bus surface over a
  native Unix socket, and closes it — and currently lists **4308 verbs across 17 apps** (the full live
  surface of each: appShell + engine + dynamically-registered). No app is "forward-only" anymore; the
  count is exactly what each running app answers to `verbs()`.
