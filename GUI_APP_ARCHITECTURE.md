# GUI App Architecture

The single standard every MenkeTechnologies GUI app follows: how the repos split, where every
submodule goes, and the baseline UI each app must mount. Apps that diverge are non‑conforming and
fail the baseline gate. This exists because today the same shared library lands in a different place
in every app (see [Current divergence](#current-divergence)).

## 1. Two‑repo split

Every GUI app is two repos:

| Repo | Role | License |
| --- | --- | --- |
| `<app>` | Tauri **shell** — window, menus, Tauri commands that forward to the engine, and the frontend. Holds no domain logic. | per product |
| `<app>-core` | The **engine** — all logic, state, and the data the UI renders. Ships its own `webui/` when the UI is engine‑hosted. A git submodule of `<app>`. | per product |

The shell is thin. The engine owns everything testable. This mirrors `zreq`/`zreq-core`,
`zgo`/`zgo-core`, `zcontainer`/`zcontainer-core`, etc.

## 2. Canonical directory layout

```
<app>/                              # the Tauri shell repo
├─ app/src-tauri/                   # Tauri Rust: commands forward to the engine, no logic
├─ crates/
│  └─ <app>-core/                   # ENGINE submodule (logic; may host webui/)
├─ <frontend-root>/                 # the dir that holds index.html (see below)
│  ├─ index.html                    # loads lib/zgui-core/all.css + the component scripts
│  ├─ app.js                        # mounts ZGui.appShell(...) — the required baseline
│  └─ lib/                          # ALL shared UI submodules, served IN PLACE (never copied)
│     ├─ zgui-core/                 # component library + the appShell baseline
│     ├─ zpwr-i18n/                 # translations
│     ├─ zpwr-file-browser/         # file‑browser embed
│     ├─ zpwr-embed-terminal/       # terminal embed
│     ├─ zpwr-hooks-editor/         # hooks‑editor embed
│     └─ zpwr-clip-engine/          # clipboard‑grid embed
├─ scripts/                         # build/copy/gate scripts
└─ docs/                            # GitHub Pages (globally gitignored → force‑add)
```

`<frontend-root>` is **the directory that contains the app's `index.html`** — and there are exactly
two allowed shapes:

| Frontend shape | `<frontend-root>` | Shared libs go in |
| --- | --- | --- |
| App‑hosted UI | `<app>/frontend/` | `frontend/lib/<name>` |
| Engine‑hosted UI | `<app>-core/webui/` | `<app>-core/webui/lib/<name>` |

### The submodule‑placement rule (mandatory)

- Every **shared UI** submodule (`zgui-core`, `zpwr-i18n`, `zpwr-file-browser`,
  `zpwr-embed-terminal`, `zpwr-hooks-editor`, `zpwr-clip-engine`) lives in
  `<frontend-root>/lib/<name>`. The directory is named **`lib`** — not `vendor`, not `settings`,
  not an ad‑hoc nesting.
- The **engine** submodule lives in `crates/<app>-core` (or at the repo root as `<app>-core` only
  for the legacy single‑level apps; new apps use `crates/`).
- Nothing else is a submodule of the app.

### No copy — serve in place

Shared submodules are loaded **directly from `lib/`** by `<script src="lib/zgui-core/webui/…">` /
`<link href="lib/zgui-core/webui/all.css">`. Build/copy scripts must **never** copy a shared
submodule's files into a generated `frontend/`. Copying produces the stale‑vendored‑library bug that
broke zterm's settings and zcontainer's palette (the app shipped an old snapshot of zgui‑core). The
only thing a copy step may emit is the **app's own** webui; shared libs stay submodule‑served.

## 3. Required baseline — mount `ZGui.appShell`

Every app's `app.js` mounts the shell in one call. It bundles the entire Audio‑Haxor baseline so no
app can ship without it:

```js
ZGui.appShell(document.getElementById("app"), {
  brand: { glyph: "◆", title: "MYAPP", subtitle: "…" },
  filterPlaceholder: "Filter…",
  onFilter: (q) => myList.filter(q),
  palette: [{ label: "Reload", run: reload }, …],   // ⌘K command palette
  onColorscheme: (id) => {},                          // optional hook
  onOpenLog:    () => invoke("open_log_file"),        // host wires Tauri
  onOpenLogDir: () => invoke("open_log_dir"),
  onOpenDataDir:() => invoke("open_data_dir"),
});
```

`appShell` renders, wires, and stamps:

| Baseline element | Provided by |
| --- | --- |
| Filter / search bar | `ZGui.searchBox` in the top bar |
| Command palette (⌘K) | `ZGui.palette` (registered + hotkey bound) |
| Rebindable shortcuts (?) | `ZGui.shortcuts` |
| Color‑scheme picker | `ZGui.colorscheme.buildSwitcher` (settings ⚙) |
| Custom color‑scheme builder | `ZGui.colorscheme.buildEditor` + preset chips (settings ⚙) |
| CRT scanlines toggle | `ZGui.crt` (overlay live at load; toggle in settings) |
| Neon‑glow toggle | `ZGui.neonGlow` (settings ⚙) |
| Open log file / log dir / data dir | host callbacks, rendered in settings ⚙ |

On mount it sets `document.documentElement.dataset.zguiBaseline` — the stamp the gate asserts. Apps
that need a bespoke settings panel pass `settings: fn` (or extend the default via `settingsExtra:
fn(bodyEl)`), but the eight required items above must remain reachable.

## 4. Build / serve flow

1. `node lib/zgui-core/scripts/build-all-css.mjs` — only when developing zgui‑core itself; consumers
   load the committed `lib/zgui-core/webui/all.css`.
2. The app's own copy/build step emits **only the app's** webui (engine‑hosted: copy `<app>-core/webui`
   → served dir). Shared `lib/` submodules are referenced in place.
3. `pnpm tauri dev` / `pnpm tauri build`.

## 5. CI gate — `baseline-gate.mjs`

`zgui-core/scripts/baseline-gate.mjs` renders the app's built `index.html` in headless Chrome and
inspects the **resulting DOM** — never source text, so a stamp cannot be faked by typing it into
static HTML. It passes only when `ZGui.appShell` actually ran, producing all three runtime artifacts:
the `data-zgui-baseline` stamp with every required token, a live filter input, and the `.zg-crt-h`
CRT overlay (created at runtime by `ZGui.crt`).

```
node lib/zgui-core/scripts/baseline-gate.mjs frontend/index.html
```

Wire it into the app's CI. Exit 1 = the app is missing the baseline.

## Current divergence

What the rule above fixes. As of this writing `zgui-core` is checked out at a different path in every
app — the disorder this standard ends:

| App | `zgui-core` is at | Conforms? |
| --- | --- | --- |
| Audio‑Haxor | `frontend/lib/zgui-core` | ✅ canonical |
| zterm | `settings/zgui-core` | ❌ move to `frontend/lib/` |
| zpdf | `zpdf-core/webui/vendor/zgui-core` | ❌ `vendor` → `lib` |
| ztranslator | `frontend/vendor/zgui-core` | ❌ `vendor` → `lib` |

Migrate non‑conforming apps to `<frontend-root>/lib/zgui-core` (`git mv` the submodule, update the
`.gitmodules` path and the `<script>`/`<link>` URLs), then run the gate.
