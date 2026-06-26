# GUI App Architecture — Design Doc

Status: authoritative. Supersedes the earlier placement-only guide. Defines the shell/view boundary,
where `zgui-core` lives, and how the **app-level GUI surface is blocked inside cores**.

## 1. Problem

`zgui-core` bundles two different things under one `window.ZGui`:

1. **Widgets** — `button`, `table`, `modal`, `pdfViewer`, charts, meters … self-contained controls.
2. **App chrome** — `appShell` (settings, splash, colorscheme picker, command palette, CRT, neon,
   log access). These mutate **global/document state**: full-screen overlays, the active theme on
   `:root`, global `⌘K`/shortcut keymaps, the `data-zgui-baseline` stamp.

A GUI app is increasingly **a host that embeds other cores' UIs** — Audio-Haxor embeds ztranslator,
zpdf could embed in traderview, etc. A core having its own settings or palette is fine — *if* they're
opened by buttons. The bug is when an embedded core seizes a **document‑global** singleton: a host with
5 embeds gets **5 competing `⌘K` bindings, 5 global keymaps fighting over the same keys, 5 full‑screen
splashes, 5 cores re‑theming `:root`**. There is one keyboard and one document; only the host may bind
them. That is what this design prevents.

## 2. Model — three layers

| Layer | What it is | Owned by | Count per running app |
| --- | --- | --- | --- |
| **Widgets** | `ZGui.*` controls | every UI | runtime **singleton** (`window.ZGui`, loaded once per page) |
| **Domain view** | a core's actual pane (PDF viewer, translator) | the **core** | one per embed |
| **App shell** | `ZGui.appShell` — settings/splash/colorscheme/palette/CRT/log | the **top-level launcher only** | exactly **one** |

The governing rule:

> **A core may have its own settings, command palette, and app features — but they are opened by
> BUTTONS in the core's pane, never by a global keyboard shortcut.** There is one keyboard and the
> host owns the global keymap (`⌘K` and friends); a core that *binds* a global key fights the host for
> it. Buttons don't collide. So the one hard prohibition on a core is **installing a global key
> binding** (or any other document‑global singleton — `:root` theme, full‑screen overlay). Everything
> a core's UI does is **button‑invoked and pane‑scoped.**

A core run **standalone** is the host — its own `index.html` mounts the full shell with `⌘K` and global
keys. That global wiring is simply not active when the core is embedded; the same settings/palette are
then reached by the core's buttons instead.

## 3. The one rule: buttons, not global keys

**Forbidden in a core (installs a document‑global singleton):**

```
ZGui.appShell                               // auto-binds ⌘K + global keymap — host-only
ZGui.palette.bindHotkey                     // seizes the global ⌘K
ZGui.shortcuts.init                         // installs the global keymap
ZGui.colorscheme.apply | applyVars | setLight | load    // writes the :root theme (re-themes the whole host)
ZGui.splash.* · ZGui.crt(…) · ZGui.neonGlow.*           // position:fixed full-document overlays
ZGui.baseline.*                             // the top-level baseline stamp
```

**Allowed in a core — its own features, opened by a button (pane‑scoped):**

```
const bar = ZGui.buttonBar(coreEl);
bar.add("⚙", "Settings", () => mySettingsPanel.open());      // the core's OWN settings, button-opened
bar.add("⌘", "Commands", () => myPalette.open());            // the core's OWN palette, button-opened, NO hotkey
ZGui.palette.create({ items, scope: coreEl })                // a palette instance scoped to the pane (not the singleton ⌘K)
ZGui.colorscheme.scope(coreEl, vars)                         // theme tokens scoped to the core's container, not :root
// + every widget (modal, table, viewer, charts, …) — always allowed
```

So the distinction is **how it's invoked**, not whether it exists: a core gets a full palette and full
settings, reached through **its own buttons**, scoped to its pane. The host keeps the single global
`⌘K`/keymap/`:root` theme/overlay layer — no conflict, because the core never binds a global key or
writes global state.

**Why the forbidden calls collide:**

- **`palette.bindHotkey` / `shortcuts.init`** — one keyboard, one `document`. Two global keymaps means
  the core's keys fight the host's. → give the core a **button** that opens its palette instead.
- **`colorscheme.apply` / `setLight`** — writes the theme onto `:root`, re‑theming the **whole host**.
  → scope tokens to the core's container.
- **`splash` / `crt` / `neonGlow`** — `position:fixed` full‑document overlays that blank the whole host.

## 4. Placement & serving

### Same layout for JUCE and Tauri (by design)

**The directory layout is identical for a JUCE app and a Tauri app — only the shell host differs.**
Both serve the same `frontend/`, embed zgui at the same `frontend/lib/zgui-core`, and put Rust embeds
in the same `crates/`. One layout → one gate, one set of scripts, one muscle memory.

| | Tauri | JUCE |
| --- | --- | --- |
| Loads `frontend/index.html` | `frontendDist: "…/frontend"` (Rust WebView) | `WebBrowserComponent` pointed at `…/frontend` |
| zgui-core | `frontend/lib/zgui-core` | `frontend/lib/zgui-core` |
| Rust embeds / cores | `crates/<name>` | `crates/<name>` |
| Served UI root | `frontend/` | `frontend/` |

The shell technology is the *only* variable; every path above is the same in both.

### Where zgui-core lives

`zgui-core` (the widget library) is embedded **once in each repo that owns a served frontend**, always
at the **same path**:

```
<ui-repo>/frontend/lib/zgui-core         # the SAME path in every repo, no exceptions
<ui-repo>/frontend/index.html            # standalone entry — mounts appShell
<ui-repo>/frontend/<name>-view.js        # embeddable view — widgets only, NO app-shell
```

- **Every repo serves `frontend/`.** Engine cores that historically served `webui/` are renamed
  `webui → frontend`, and the wrapper's Tauri `frontendDist` points at `…/frontend`.
- **Engine‑hosted apps** (the wrapper's `frontendDist → <core>/frontend`): zgui lives in the **core**;
  the wrapper embeds **no** zgui and has no `frontend/` of its own.
- **App‑hosted apps** (`frontendDist → the app's own frontend/`): zgui lives in the **app**.
- **Rust engine cores / Rust‑only embeds** go in `crates/<name>` (compiled in, never served).

### Why duplicate copies are fine

N embeds → N `frontend/lib/zgui-core` submodule pointers to the same repo. That is intended:

- `window.ZGui` is a **runtime singleton** — the host loads exactly one; the embeds' copies are
  dormant (used only when that core runs standalone). No double‑load, no conflict.
- The files are kilobytes of static JS/CSS; git dedupes the objects.
- Each embed pins its own zgui SHA — a feature for the long‑term compat floor: bumping zgui in one
  embed cannot break the other four.

The alternative (one shared copy, embeds assume a global) **breaks standalone builds** of every core,
which contradicts the requirement that an embedded core carry all its widgets.

## 5. Enforcement — no global key binding / global state in cores

The thing being blocked is narrow: a core seizing a **document‑global singleton** (the keymap, `⌘K`,
`:root` theme, a full‑screen overlay). A core's own button‑opened, pane‑scoped settings/palette are
fine. Two layers, defense in depth.

### 5a. Runtime guards (in `zgui-core`)

- **`appShell` is single‑instance.** It records a flag on `document.documentElement`; a **second**
  `ZGui.appShell(...)` throws `appShell already mounted — only the top-level app mounts the shell`.
  This kills the "5 settings panels / 5 ⌘K bindings" failure: the host mounts the shell; an embedded
  core that tries to mount another throws (surfaced by the gate's headless render).
- **`ZGui.embed.view(fn)`** — the host mounts an embedded view through this wrapper. For the duration
  of `fn`, the **global‑install surface (§3)** is swapped to throwing stubs, so a view that calls
  `palette.bindHotkey` / `shortcuts.init` / `colorscheme.apply` / `splash` / `crt` throws at init. The
  pane‑scoped / button APIs (`buttonBar`, `palette.create({scope})`, `colorscheme.scope`) are **not**
  stubbed — a core keeps its own button‑opened settings and palette.

### 5b. Static gate check (in `baseline-gate.mjs`)

- A core declares its embeddable view entry/entries in `package.json`:
  `"zguiView": ["frontend/translator-view.js", …]`.
- The gate parses each declared view module **and its relative imports** and **fails** only on a
  **global‑install** call from §3 (`appShell`, `palette.bindHotkey`, `shortcuts.init`,
  `colorscheme.apply|applyVars|setLight|load`, `splash.*`, `crt`, `neonGlow`, `baseline.*`). Calls to
  the scoped/button APIs pass. Output names the file + the offending call.
- The gate continues to assert, on the **top‑level/standalone** `index.html`: `appShell` + `splash`
  actually ran (stamp + filter + `.zg-crt-h` + `.zg-splash-spent`), exactly as today.

### 5c. Gate summary (three checks)

| Check | Target | Asserts |
| --- | --- | --- |
| Baseline | standalone `index.html` (rendered) | `appShell` + `splash` ran; the live chrome exists |
| No global grab | declared `zguiView` modules | no **global‑install** call (keymap/`⌘K`/`:root`/overlay); button + scoped APIs OK |
| Placement | the repo's `.gitmodules` | `zgui-core` at `frontend/lib/zgui-core`; Rust cores at `crates/` |

## 6. Standard layout

```
<app|core>/
├─ app/src-tauri/                 # Tauri shell (or JUCE host) — wrapper only, no logic
├─ crates/                        # Rust engine cores / Rust embeds
│  └─ <name>-core/  ztmux-core/ …
├─ frontend/                      # the served UI (frontendDist → here)
│  ├─ index.html                  #   standalone entry — mounts ZGui.appShell
│  ├─ app.js
│  ├─ <name>-view.js              #   embeddable view — widgets only (in package.json "zguiView")
│  └─ lib/
│     └─ zgui-core/               #   the widget library, served in place (no copy)
├─ scripts/
└─ docs/                          # GitHub Pages (gitignored → force-add)
```

## 7. Per-app migration plan

| Repo | Hosting | Action |
| --- | --- | --- |
| Audio‑Haxor | app‑hosted | zgui at `frontend/lib/zgui-core` (already ✓); it is the top‑level shell |
| zterm | app‑hosted (include_dir) | zgui at `frontend/lib/zgui-core` (done ✓) |
| ztranslator, zemail | TBD by `frontendDist` | if engine‑hosted, move zgui to the core + drop from wrapper; else keep in app |
| zpdf, zgo, zcontainer | engine‑hosted | rename core `webui → frontend`; zgui at `<core>/frontend/lib`; wrapper embeds none; `frontendDist → <core>/frontend` |
| zreq, ztunnel, zoffice, zftp, zemacs‑gui, zpwr‑daw, zcite | not wired | add `frontend/lib/zgui-core`; standalone `index.html` mounts `appShell`; domain UI becomes a `*-view.js` |

Each migration: place zgui → (rename webui→frontend if a core) → wire shell in `index.html` only →
declare `zguiView` → run the gate → bump pointers (`<core>` → `<app>` → meta).

## 8. Build order in `zgui-core`

The runtime guards (§5a) ship as a small `webui/role.js` + `webui/embed.js` and an `appShell`
single‑instance check; the gate (§5b) gains the view‑purity scan. These land in `zgui-core` first
(they are the substrate every app depends on), then the per‑app sweep follows.
