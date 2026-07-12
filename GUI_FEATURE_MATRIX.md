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
"Bus verbs" = engine verbs in the generated catalog (every app also inherits **15 shared appShell
verbs**).

| App | GUI scripting (bus) | Bus verbs | tmux bar | tmux WM | vim (editor) | vim (app) | hooks editor |
| --- |:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **zpdf** | ✓ | 309 | ✓ | ✓ | ✓ | · | ✓ |
| **zemail** | ✓ | 174 | ✓ | ✓ | ✓ | · | ✓ |
| **zcite** | ✓ | 178 | ✓ | ✓ | ✓ | · | ✓ |
| **zftp** | ✓ | 123 | ✓ | ✓ | ✓ | · | ✓ |
| **zreq** | ✓ | 121 | ✓ | ✓ | ✓ | · | ✓ |
| **ztunnel** | ✓ | 97 | ✓ | ✓ | ✓ | · | ✓ |
| **zoffice** | ✓ | 96 | ✓ | ✓ | ✓ | ✓ | ✓ |
| **zthrottle** | ✓ | 54 | ✓ | ✓ | ✓ | · | ✓ |
| **zgo** | ✓ | 19 | ✓ | ✓ | ✓ | · | ✓ |
| **traderview** | ✓ | 1726 | ✓ | ✓ | ✓ | · | ✓ |
| **zphoto** | ✓ | forward¹ | ✓ | ✓ | ✓ | · | ✓ |
| **zstation** | ✓ | forward¹ | ✓ | ✓ | ✓ | · | ✓ |
| **zcontainer** | ✓ | forward¹ | ✓ | ✓ | ✓ | · | ✓ |
| **Audio-Haxor** | ✓ | forward¹ | ✓ | ✓ | ✓ | · | ✓ |
| **ztranslator** | ✓ | forward¹ | ✓ | ✓ | ✓ | · | ✓ |
| **zwire** | native² | 161 | ✓ | ✓ | ✓ | ✓ | ✓ |
| **zterminal** | · | — | native³ | native³ | · | · | · |

¹ **`forward`** — the socket is wired (`serve("<app>")` + `bus::start`) but the app has no
enumerated engine-verb source yet. Its `bus.rs` is a **webview-forward** handler: every verb is
forwarded to the webview, which tries a registered `ZGui.automation` verb then falls back to
`invoke(verb,args)`, so the app's own Tauri commands are already bus-callable by name and
`surface()` advertises them for discovery. Typed verbs get promoted into the catalog later.

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
  regenerated from each app's verb source (`bin/gen-gui-actions.sh`) and currently lists **3073
  engine verbs across 11 apps** + 15 shared appShell verbs. The remaining socket-wired apps expose
  their Tauri commands via webview-forward until their typed verbs are promoted into the catalog.
