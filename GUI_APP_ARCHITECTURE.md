# GUI App Architecture

The single standard every MenkeTechnologies GUI app follows: how the repos split, where every
submodule goes, and the baseline UI each app must mount. Apps that diverge are non‑conforming and
fail `baseline-gate.mjs`. This exists because today the same shared library lands in a different place
in every app (see [Current divergence](#current-divergence)).

## 1. Two‑repo split

Every GUI app is two repos:

| Repo | Role | License |
| --- | --- | --- |
| `<app>` | Tauri **shell** — window, menus, Tauri commands that forward to the engine, and the frontend. Holds no domain logic. | per product |
| `<app>-core` | The **engine** — all logic, state, and the data the UI renders. Ships its own `webui/` when the UI is engine‑hosted. A git submodule of `<app>`. | per product |

## 2. Every embed lives in `crates/<repo>`

**All embedded submodules — the engine core and every shared library — sit at `crates/<name>`,
relative to the repo that embeds them.** One location, no exceptions. `vendor/`, `settings/`,
`frontend/lib/`, `libs/`, `audio-engine/libs/` are all non‑conforming.

```
<app>/                              # the Tauri shell repo
├─ app/src-tauri/                   # Tauri Rust: commands forward to the engine, no logic
├─ crates/                          # EVERY submodule embed goes here
│  ├─ <app>-core/                   #   engine (logic; may host webui/)
│  ├─ zgui-core/                    #   component library + the appShell baseline
│  ├─ zpwr-i18n/                    #   translations
│  ├─ zpwr-file-browser/            #   file‑browser embed
│  ├─ zpwr-embed-terminal/          #   terminal embed
│  ├─ zpwr-hooks-editor/            #   hooks‑editor embed
│  └─ zpwr-clip-engine/             #   clipboard‑grid embed
├─ frontend/                        # the app's own UI (index.html + app.js)
│  ├─ index.html                    #   loads ../crates/zgui-core/webui/all.css + scripts
│  └─ app.js                        #   mounts ZGui.appShell(...)
├─ scripts/
└─ docs/                            # GitHub Pages (globally gitignored → force‑add)
```

**Engine‑hosted UI (3‑level apps).** When the frontend lives in the engine (`<app>-core/webui/`, e.g.
zpdf, zcontainer), the shared libs the webui consumes are embedded in **the core's** `crates/` —
`<app>-core/crates/zgui-core` — because a repo can only reference its own submodules. The rule is the
same at every level: a repo's embeds go in *its* `crates/`.

### Placement rule (gated)

- Every entry in a repo's `.gitmodules` has a path of the form `crates/<name>`. Nothing else.
- This is checked by `baseline-gate.mjs` (directory mode) against each repo's own `.gitmodules` —
  nested cores/libs are separate repos, gated by their own runs.

### No copy — serve in place

Frontends load shared libs **directly from `crates/`** (`<script src="../crates/zgui-core/webui/…">`,
`<link href="../crates/zgui-core/webui/all.css">`). Build/copy scripts must **never** copy a shared
submodule into a generated dir — that is the stale‑vendored‑library bug that broke zterm's settings
and zcontainer's palette. A copy step may emit only the **app's own** webui; shared libs stay
submodule‑served and update by bumping the pointer.

## 3. Required baseline — mount `ZGui.appShell`

Every app's entry JS mounts the shell in one call. It bundles the entire Audio‑Haxor baseline so no
app can ship without it, and it shows the boot **splash** on mount:

```js
ZGui.splash.show({ title: "MYAPP", version: "v1.2.3" });   // optional: raise early, during load
…
const shell = ZGui.appShell(document.getElementById("app"), {
  brand: { glyph: "◆", title: "MYAPP", subtitle: "…" },
  filterPlaceholder: "Filter…",
  onFilter: (q) => myList.filter(q),
  palette: [{ label: "Reload", run: reload }],            // ⌘K command palette
  onColorscheme: (id) => {},
  onOpenLog:     () => invoke("open_log_file"),
  onOpenLogDir:  () => invoke("open_log_dir"),
  onOpenDataDir: () => invoke("open_data_dir"),
});
// app content goes in shell.body
```

`appShell` renders, wires, stamps, and dismisses the splash:

| Baseline element | Provided by |
| --- | --- |
| Boot splash | `ZGui.splash` (shown on mount, adopts an earlier one; marks the `splash` baseline) |
| Filter / search bar | `ZGui.searchBox` in the top bar |
| Command palette (⌘K) | `ZGui.palette` (registered + hotkey bound) |
| Rebindable shortcuts (?) | `ZGui.shortcuts` |
| Color‑scheme picker | `ZGui.colorscheme.buildSwitcher` (settings ⚙) |
| Custom color‑scheme builder | `ZGui.colorscheme.buildEditor` + preset chips (settings ⚙) |
| CRT scanlines toggle | `ZGui.crt` (overlay live at load; toggle in settings) |
| Neon‑glow toggle | `ZGui.neonGlow` (settings ⚙) |
| Open log file / log dir / data dir | host callbacks, rendered in settings ⚙ |

On mount it stamps `document.documentElement.dataset.zguiBaseline`. Apps needing a bespoke settings
panel pass `settings: fn` (or extend the default via `settingsExtra: fn(bodyEl)`), but every required
item above must stay reachable.

## 4. CI gate — `baseline-gate.mjs`

`crates/zgui-core/scripts/baseline-gate.mjs` has two checks. Wire both into the app's CI.

**Baseline (renders the frontend):** headless Chrome renders the built `index.html` and inspects the
**resulting DOM** — never source text, so a stamp cannot be faked by typing it into static HTML. Passes
only when `ZGui.appShell` + `ZGui.splash` actually ran, producing the runtime artifacts: the
`data-zgui-baseline` stamp with every required token, a live filter input, the `.zg-crt-h` CRT overlay,
and the `.zg-splash-spent` splash sentinel.

```
node crates/zgui-core/scripts/baseline-gate.mjs frontend/index.html
```

**Placement (reads `.gitmodules`):** pass a directory to assert every embed is under `crates/`.

```
node crates/zgui-core/scripts/baseline-gate.mjs .
```

A file target runs both (baseline on the render + placement on its owning repo). Exit 1 = the app is
missing the baseline or mis‑places an embed.

## Current divergence

What this standard ends. `zgui-core` is embedded at a different path in every app, and no app yet uses
`crates/`:

| App | `zgui-core` is at | Target |
| --- | --- | --- |
| Audio‑Haxor | `frontend/lib/zgui-core` | `crates/zgui-core` |
| zterm | `settings/zgui-core` | `crates/zgui-core` |
| zpdf | `zpdf-core/webui/vendor/zgui-core` | `zpdf-core/crates/zgui-core` |
| zcontainer | `zcontainer-core/webui/vendor/zgui-core` | `zcontainer-core/crates/zgui-core` |
| zgo | `zgo-core/webui/vendor/zgui-core` | `zgo-core/crates/zgui-core` |
| zemail | `frontend/vendor/zgui-core` | `crates/zgui-core` |
| ztranslator | `frontend/vendor/zgui-core` | `crates/zgui-core` |
| zreq, ztunnel, zoffice, zftp, zemacs‑gui, zpwr‑daw, zcite | not wired | add `crates/zgui-core` + mount `appShell` |

Migrate each: `git mv <oldpath> crates/<name>` (or `git submodule` re‑add), fix the `.gitmodules` path
and the `<script>`/`<link>` URLs, run the gate, then bump pointers (`<core>` → `<app>` → meta).
