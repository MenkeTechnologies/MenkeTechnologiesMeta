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
zpdf could embed in traderview, etc. If every embedded core mounts its own chrome, a host with 5
embeds gets **5 settings panels, 5 splashes, 5 colorscheme pickers, 5 competing ⌘K bindings**. That is
the bug this design prevents.

## 2. Model — three layers

| Layer | What it is | Owned by | Count per running app |
| --- | --- | --- | --- |
| **Widgets** | `ZGui.*` controls | every UI | runtime **singleton** (`window.ZGui`, loaded once per page) |
| **Domain view** | a core's actual pane (PDF viewer, translator) | the **core** | one per embed |
| **App shell** | `ZGui.appShell` — settings/splash/colorscheme/palette/CRT/log | the **top-level launcher only** | exactly **one** |

The governing rule:

> **A core renders a *view*, not a *shell*.** A core's embeddable form uses ZGui **widgets** and must
> never touch the **app‑shell surface**. The chrome is mounted exactly once, by the top‑level app.

A core may still be a full app **when run standalone** — its standalone `index.html` mounts `appShell`
around its view. That standalone shell is simply **not pulled in** when the core is embedded.

## 3. The app-shell surface (forbidden in core views)

These APIs are **app‑level**. They are legal only in a top‑level/standalone entry, never in an
embeddable view module:

```
ZGui.appShell
ZGui.baseline.*            (markAll / mark / require)
ZGui.splash.*             (show / hide / setVersion)
ZGui.crt(…)  ZGui.neonGlow.*               // full-document overlays
ZGui.palette.bindHotkey                     // global ⌘K
ZGui.shortcuts.init                         // global keymap
ZGui.colorscheme.buildSwitcher | buildEditor | buildPresetChips | setLight | load | apply | applyVars
```

Everything else in `ZGui` — every widget — is allowed anywhere. A view **inherits** the host's theme
tokens; it never sets them.

**Why these specifically interfere with the host** (not stylistic — they actively collide):

- **Command palette** (`palette.bindHotkey`) binds a *global* `⌘K` on `document`. A core that binds it
  fights the host for the same key — two palettes open, or the core's shadows the host's.
- **Settings / colorscheme picker** (`appShell` settings, `colorscheme.buildSwitcher`, `setLight`,
  `apply`) writes the active theme onto `:root` and opens a full‑window panel. A core doing this
  re‑themes or covers the **whole host**, not just its pane.
- **Splash / CRT / neon** are `position:fixed` full‑document overlays — a core mounting them blanks or
  streaks the entire host window.
- **Shortcuts** (`shortcuts.init`) installs a global keymap that overrides the host's.

In every case the core reaches **outside its pane** into document‑global state the host owns. That is
the definition of the app‑shell surface, and why a core may not touch it.

## 4. Placement & serving

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

## 5. Enforcement — blocking app-level GUI in cores

Two layers, defense in depth.

### 5a. Runtime guards (in `zgui-core`)

- **`appShell` is single‑instance.** It records a flag on `document.documentElement`; a **second**
  `ZGui.appShell(...)` throws `appShell already mounted — only the top-level app mounts the shell`.
  This alone kills the "5 settings panels" failure: the host mounts the shell; any embedded core that
  tries to mount another one throws immediately (surfaced by the gate's headless render).
- **`ZGui.embed.view(fn)`** — the host mounts an embedded view through this wrapper. For the duration
  of `fn`, the entire app‑shell surface (§3) is swapped to **throwing stubs**, so a view that reaches
  for `appShell`/`splash`/`colorscheme.buildSwitcher`/… throws at init. Embeds are thus *provably*
  chrome‑free at runtime.

### 5b. Static gate check (in `baseline-gate.mjs`)

- A core declares its embeddable view entry/entries in `package.json`:
  `"zguiView": ["frontend/translator-view.js", …]`.
- The gate parses each declared view module **and its relative imports** and **fails** if any
  references an app‑shell API from §3. Output names the file + the offending call.
- The gate continues to assert, on the **top‑level/standalone** `index.html`: `appShell` + `splash`
  actually ran (stamp + filter + `.zg-crt-h` + `.zg-splash-spent`), exactly as today.

### 5c. Gate summary (three checks)

| Check | Target | Asserts |
| --- | --- | --- |
| Baseline | standalone `index.html` (rendered) | `appShell` + `splash` ran; the live chrome exists |
| View purity | declared `zguiView` modules | **no** app‑shell surface referenced |
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
