# GUI Feature Matrix — power-user surfaces per app

Which **power-user surfaces** each desktop GUI app actually wires: GUI scripting (automation
bus), the tmux/powerline status bar, the tmux tiling WM, vim mode (editor + app-level), and the
stryke hooks editor. Companion to [`COMPONENTS.md`](COMPONENTS.md) (which shared submodule each app
*embeds*) and [`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md) (the full generated verb catalog).

Where `COMPONENTS.md` says *what an app pulls in*, this says *what an app turns on* — several of
these surfaces ship in `zgui-core` but must be `init()`'d per app, so presence is verified at the
call site, not by the submodule being vendored.

_Re-verified 2026-08-02 by grepping each app's real entry/frontend + `src-tauri` at the recorded
gitlink. For the two tmux surfaces the test is **does the app's own frontend load the script**:
`powerline.js` self-boots its bar on `DOMContentLoaded` when loaded (`boot()` →
`apply(true)`, `zgui-core/webui/powerline.js:190`; `.powerline.init(` is *optional* — it only
supplies the sig/providers to an already-built bar, `powerline.js:162-167`), while `tmux.js`
additionally needs an explicit `.tmux.init(` (each app's `tmux-config.js`). Vendoring `zgui-core`
alone wires neither. The rest: `serve("<app>")` in the app's `bus.rs` for the socket, `monaco-vim` /
`initVimMode` for editor vim, app-specific vim handlers for app-level vim, `hooks-editor-entry` for
the hooks editor. Engine-verb counts come from `GUI_SCRIPT_ACTIONS.md`._

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
| **zcite** | ✓ | 206 | · | · | ✓ | · | ✓ |
| **zftp** | ✓ | 160 | ✓ | ✓ | ✓ | · | ✓ |
| **zreq** | ✓ | 151 | ✓ | ✓ | ✓ | · | ✓ |
| **ztunnel** | ✓ | 125 | ✓ | · | ✓ | · | ✓ |
| **zoffice** | ✓ | 199 | ✓ | ✓ | ✓ | ✓ | ✓ |
| **zthrottle** | ✓ | 91 | ✓ | ✓ | ✓ | · | ✓ |
| **zlatex** | ✓ | 65 | ✓ | · | ✓ | · | ✓ |
| **zgo** | ✓ | 140 | · | · | ✓ | · | ✓ |
| **traderview** | ✓ | 1732 | · | · | ✓ | · | ✓ |
| **zphoto** | ✓ | 101 | ✓ | ✓ | ✓ | · | ✓ |
| **zstation** | ✓ | 37 | ✓ | · | ✓ | · | ✓ |
| **zcontainer** | ✓⁴ | 25 | · | · | ✓ | · | ✓ |
| **zmusic** | ✓ | —⁶ | ✓ | ✓ | ✓ | · | ✓ |
| **ztorrent** | ✓ | —⁶ | ✓ | ✓ | ✓ | · | ✓ |
| **Audio-Haxor** | ✓ | 239 | · | · | ✓ | · | ✓ |
| **ztranslator** | ✓ | 54 | · | · | ✓ | · | ✓ |
| **zmax-gui** | ✓ | 30 | ✓ | ✓ | ✓ | · | ✓ |
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

⁵ **zlatex**'s 65 was read the same way every other number here was — from the RUNNING app over
its automation-bus socket (`serve("zlatex")` in `app/src-tauri/src/bus.rs`), not counted from
source. It is the union of the engine surface (`zlatex_core::commands::COMMANDS`) and the verbs
the webview registers, so it is also proof the frontend booted: a dead webview returns the engine
verbs alone. It mounts the powerline bar but not the tmux tiling WM — a two-pane editor/preview
does not tile.

⁴ **zcontainer**'s bus has since landed in git — `zcontainer/app/src-tauri/src/bus.rs:145` now calls
`serve("zcontainer", handler)`, so the 25 verbs the live catalog lists are reproducible from source
and the row is ✓. (It was the one row that wasn't, when no `bus.rs` existed on any ref.) **19** apps
now call `serve("<app>")`: Audio-Haxor, traderview, zcite, **zcontainer**, zemail, zftp, zgo,
zlatex, zmax-gui, **zmusic**, zoffice, zpdf, zphoto, zreq, zstation, zthrottle, **ztorrent**,
ztranslator, ztunnel.

⁶ **zmusic** and **ztorrent** post-date the last `gen-gui-actions-live` run, so neither appears in
either copy of the catalog and their live verb counts are unread. Every other column in their rows
is verified from source. Re-run `bin/gen-gui-actions-live` to fill them in.

**On the two tmux surfaces** — the bar and the WM ship in `zgui-core` but are **not** mounted by the
appShell; they are per-app **script loads**. **13** apps pull `powerline.js` into their own
`index.html` (`zpdf`, `zemail`, `zftp`, `zreq`, `ztunnel`, `zoffice`, `zthrottle`, `zlatex`,
`zphoto`, `zstation`, `zmax-gui`, `zmusic`, `ztorrent`); **10** of those also pull
`webui/tmux.js` + a `tmux-config.js` that calls `.tmux.init(` — the same list minus `ztunnel`,
`zlatex` and `zstation`, which take the bar without the tiling WM. The remaining apps load neither
script outside their vendored `lib/zgui-core` copy, so `ZGui.powerline` / `ZGui.tmux` never exist in
their document. Six apps additionally call `.powerline.init(` to feed the already-booted bar an app
sig + stat providers — **ztunnel** (`frontend/main.js:25`), **zstation** (`frontend/main.js:30`),
**zoffice** (`frontend/tmux-config.js:82`), **zthrottle** (`frontend/main.js:185`), **zlatex**
(`frontend/main.js:204`) and **zmusic** (`frontend/zmusic.js:5391`); the rest run the bar's
auto-booted defaults.

---

## Track B — JUCE plugins (`zpwr-daw` engine · `zpwr-synth` · `zpwr-fx` · `zpwr-midi-fx`)

No `window.ZGui`, no Tauri `invoke`. The automation-bus, powerline bar, and tmux WM are **not
wired** for the JUCE surface — the bus substrate for Track B (C++/C-ABI surface, per-plugin-instance
socket addressing) is still unbuilt (see [`GUI_AUTOMATION_BUS_CHECKLIST.md`](GUI_AUTOMATION_BUS_CHECKLIST.md)
§0B). `zpwr-daw`'s **Tauri shell** carries monaco-vim + the hooks editor through its embedded
`ztranslator-core` webview; the JUCE `ClipEngine` half does not.

---

## Notes

- **Shared shell ≠ shared surfaces.** Mounting `ZGui.appShell` gets an app the shell chrome (⌘K
  palette, ⌘, settings, filter bar, native menu) and the shell's own lazy deps (`toast.js`,
  `modal.js`, `menu.js` — `app-shell.js:384`, `:387`, `:614`). It does **not** get it the bar or the
  tmux WM: `app-shell.js` never loads `powerline.js` / `tmux.js`, and it only *feature-detects* tmux
  (`Z().tmux && …isInited()` at `app-shell.js:166`, `:171`) to decide whether to list the status-bar
  and saved-layouts commands. The bar and the WM come from **per-app script loads** — the app's own
  `index.html` pulling `powerline.js` / `tmux.js` plus a `tmux-config.js` calling `.tmux.init(` — so
  they are wired in 10 of the `zgui-core` apps, not all of them (`zwire` has both natively, and
  they were ported *from* it; `zterminal` has both natively). The hooks editor and editor-vim are
  likewise per-app embeds (`zpwr-hooks-editor`), not shell-mounted.
- **App-level vim** (whole-UI vim navigation, not just the Monaco editor) is only in **zoffice**
  (`zoVimMode` editing mode) and **zwire** (browser-wide vim keys). Everywhere else "vim" means the
  `monaco-vim` binding inside the hooks editor.
- **GUI scripting is live, not planned.** [`GUI_SCRIPT_ACTIONS.md`](GUI_SCRIPT_ACTIONS.md) is
  regenerated by `bin/gen-gui-actions-live` — which opens every app, reads its live bus surface over a
  native Unix socket, and closes it. No app is "forward-only"; each count is exactly what that
  running app answered to `verbs()`.
- **Both catalog copies are stale and diverged — regenerate before trusting the counts.** The
  per-app numbers in the table above are the `docs/GUI_SCRIPT_ACTIONS.md` generation (**4308 verbs
  across 17 apps**, committed 2026-07-16). The root-level `GUI_SCRIPT_ACTIONS.md` is a *later*
  generation (**4375 across 16 apps**, committed 2026-07-19) whose run did not reach `zmax-gui` or
  `zlatex`, so its roster is a subset. Neither run covers `zmusic` or `ztorrent`. The two copies
  must be re-generated together by `bin/gen-gui-actions-live` with every app launchable; they are
  generator-owned and are never hand-edited.
