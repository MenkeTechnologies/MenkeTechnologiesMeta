# GUI App Architecture

The single standard every MenkeTechnologies GUI app follows: how the repos split, where every
submodule goes, and the baseline UI each app must mount. Apps that diverge are non‑conforming and
fail `baseline-gate.mjs`. This exists because today the same shared library lands in a different place
in every app (see [Current divergence](#current-divergence)).

## 1. Two‑repo split

Every GUI app is two repos:

| Repo | Role | License |
| --- | --- | --- |
| `<app>` | Tauri (or JUCE) **shell** — window, menus, commands that forward to the engine, and the frontend. Holds no domain logic. | per product |
| `<app>-core` | The **engine** — all logic, state, and the data the UI renders. Ships its own `webui/` when the UI is engine‑hosted. A git submodule of `<app>`. | per product |

## 2. Where every submodule goes — two tiers

Placement is decided by what consumes the submodule:

### Tier 1 — direct‑served JS UI libs → `<frontend-root>/lib/<name>`

`zgui-core` and the other directly‑served webui libraries live in a **`lib/` directory inside the
served frontend root**, so the browser loads them in place by relative URL — no copy, no stale
snapshot. The shell serves `frontendDist` (Tauri) or embeds the frontend (JUCE/`include_dir!`); the
lib must be reachable from there. **`zgui-core` is `<frontend-root>/lib/zgui-core` in every app,
including JUCE apps.** `vendor/`, `settings/zgui-core`, `crates/zgui-core` are all non‑conforming.

The `<frontend-root>` is wherever the app's `index.html` lives — and it varies:

| Frontend shape | `<frontend-root>` | zgui lands at |
| --- | --- | --- |
| Tauri, app‑hosted UI | `frontend/` | `frontend/lib/zgui-core` |
| Engine‑hosted UI | `<app>-core/webui/` | `<app>-core/webui/lib/zgui-core` |
| zterm (in‑process settings) | `settings/frontend/` | `settings/frontend/lib/zgui-core` |

### Tier 2 — Rust engine cores & Rust‑only embeds → `crates/<name>`

The engine core and any Rust‑consumed submodule live at `crates/<name>` (e.g. `crates/<app>-core`,
`crates/ztmux-core`, `crates/zdsp-core`). These are compiled in, never served to the browser.

```
<app>/
├─ app/src-tauri/                   # Tauri Rust shell (or JUCE host)
├─ crates/                          # TIER 2: Rust cores / embeds
│  ├─ <app>-core/
│  └─ ztmux-core/  zdsp-core/  …
├─ frontend/                        # the served UI
│  ├─ index.html                    #   loads lib/zgui-core/webui/all.css + scripts
│  ├─ app.js                        #   mounts ZGui.appShell(...)
│  └─ lib/                          # TIER 1: direct-served JS UI libs (served in place)
│     ├─ zgui-core/
│     └─ zpwr-i18n/  zpwr-clip-engine/  …
├─ scripts/
└─ docs/                            # GitHub Pages (gitignored → force-add)
```

### No copy — serve in place

Tier‑1 libs are loaded **directly from `lib/`** (`<script src="lib/zgui-core/webui/…">`). A build/copy
step must **never** copy a shared submodule into a generated dir — that is the stale‑vendored‑library
bug that broke zterm's settings and zcontainer's palette. Update by bumping the submodule pointer.

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
panel pass `settings: fn` (or `settingsExtra: fn(bodyEl)`), but every required item must stay reachable.

## 4. CI gate — `baseline-gate.mjs`

`frontend/lib/zgui-core/scripts/baseline-gate.mjs` has two checks. Wire both into the app's CI.

**Baseline (renders the frontend):** headless Chrome renders the built `index.html` and inspects the
**resulting DOM** — never source text, so a stamp cannot be faked by typing it into static HTML. Passes
only when `ZGui.appShell` + `ZGui.splash` actually ran, producing the runtime artifacts: the
`data-zgui-baseline` stamp with every required token, a live filter input, the `.zg-crt-h` CRT overlay,
and the `.zg-splash-spent` splash sentinel.

```
node frontend/lib/zgui-core/scripts/baseline-gate.mjs frontend/index.html
```

**Placement (reads `.gitmodules`):** pass a directory to assert tier‑1 (`zgui-core` at
`<frontend-root>/lib/zgui-core`) and tier‑2 (`*-core` at `crates/`).

```
node frontend/lib/zgui-core/scripts/baseline-gate.mjs .
```

## Current divergence

What this standard ends. `zgui-core` target is `<frontend-root>/lib/zgui-core`:

| App | `zgui-core` is at | Conforms? |
| --- | --- | --- |
| Audio‑Haxor | `frontend/lib/zgui-core` | ✅ |
| zgo | `frontend/lib/zgui-core` | ✅ |
| zterm | `crates/zgui-core` | ❌ → `settings/frontend/lib/zgui-core` |
| zpdf | `zpdf-core/webui/vendor/zgui-core` | ❌ → `zpdf-core/webui/lib/zgui-core` |
| zcontainer | `zcontainer-core/webui/vendor/zgui-core` | ❌ → `zcontainer-core/webui/lib/zgui-core` |
| zemail | `frontend/vendor/zgui-core` | ❌ → `frontend/lib/zgui-core` |
| ztranslator | `frontend/vendor/zgui-core` | ❌ → `frontend/lib/zgui-core` |
| zreq, ztunnel, zoffice, zftp, zemacs‑gui, zpwr‑daw, zcite | not wired | add `frontend/lib/zgui-core` + mount `appShell` |

Migrate each: `git mv <oldpath> <frontend-root>/lib/zgui-core`, fix the `<script>`/`<link>` URLs (or the
`include_dir!` path), run the gate, then bump pointers (`<core>` → `<app>` → meta).
