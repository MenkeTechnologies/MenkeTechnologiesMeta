# MenkeTechnologies — GUI App Requirements

The shared baseline every MenkeTechnologies desktop GUI app must meet. The goal is a
single recognizable product family: open any app and the command palette, terminal,
hooks editor, filtering, tables, arrangement grid, file browser, and chrome behave
identically. Divergence is a bug.

This is a **conformance spec**, not a suggestion. Each requirement names the **canonical
shared source** an app must consume — never a per-app reimplementation. Per the house
rule: find the first implementation, reuse it; if a shared module does not exist yet,
create it in a submodule and route every app through it.

> The pass/fail **acceptance test** over this spec (plus haxor parity, `-core`/embed
> completeness, and full i18n) is [`GUI_POLISH_GATE.md`](GUI_POLISH_GATE.md). An app is not
> "done" until it is green there.

## App roster

| App | Host substrate | Repo |
| --- | --- | --- |
| Audio-Haxor | Tauri v2 (static `frontend/`) | `Audio-Haxor` |
| traderview | Tauri v2 (static `frontend/` → `frontend-dist/`) | `traderview` |
| ztranslator | Tauri v2 (static `frontend/`) | `ztranslator` |
| zoffice | Tauri v2 (static `frontend/`) | `zoffice` |
| zpdf | Tauri v2 (static `frontend/`) | `zpdf` |
| zphoto | Tauri v2 (static `frontend/`) | `zphoto` |
| ztunnel | Tauri v2 (static `frontend/`) | `ztunnel` |
| zftp | Tauri v2 (static `frontend/`) | `zftp` |
| zcite | Tauri v2 (static `frontend/`) | `zcite` |
| zemail | Tauri v2 (static `frontend/`) | `zemail` |
| zemacs-gui | Tauri v2 (static `frontend/`) | `zemacs-gui` |
| zgo | Tauri v2 (`app/` workspace) | `zgo` |
| zcontainer | Tauri v2 (`app/` workspace) | `zcontainer` |
| zreq | Tauri v2 (`app/` workspace) | `zreq` |
| zpwr-daw | JUCE `WebBrowserComponent` (BinaryData) | `zpwr-daw` (vendored at `zpwr-clip-engine`) |
| zpwr-synth | JUCE `WebBrowserComponent` (BinaryData) | `zpwr-synth` |
| zpwr-fx | JUCE `WebBrowserComponent` (BinaryData) | `zpwr-fx` |
| zpwr-midi-fx | JUCE `WebBrowserComponent` (BinaryData) | `zpwr-midi-fx` |

Two substrates, one frontend contract. The shared web modules must run unchanged in both:
- **Tauri**: assets served from a static dir; JS via `window.__TAURI__` (invoke/listen).
- **JUCE**: assets embedded via `juce_add_binary_data`, served by a resource provider that
  resolves a request URL to a BinaryData blob **by basename**; JS via `window.Juce`
  (`getNativeFunction`) + `window.__JUCE__.backend` events.

Shared frontend modules detect the host at runtime (a transport shim) rather than forking
per app. `zpwr-embed-terminal/webui/terminal.js` is the reference pattern.

## Canonical shared sources

| Concern | Canonical source | Mechanism |
| --- | --- | --- |
| Embedded terminal | `zpwr-embed-terminal` submodule (`webui/terminal.{js,css}` + `xterm.{js,css}` + bundled font) | Tauri: copy script → `frontend/`; JUCE: BinaryData |
| Stryke Hooks editor | `zpwr-hooks-editor` submodule (`hooks-editor.bundle.{js,css}` + worker, Monaco) | built bundle vendored per app |
| Command palette | `zpwr-patch-core/webui/command-palette.js` | imported by the shell `index.html` |
| Fuzzy filter (fzf) | `zpwr-patch-core` `fzf` matcher (`fzfMatch`) | one matcher, reused by every filter + the palette |
| Shared theme/styles | `zpwr-patch-core/webui/css/cyberpunk.css` (design tokens) | the cyberpunk shell + token variables |
| Arrangement grid | `zpwr-clip-engine/webui/grid` (`createGrid`, `grid-core.js` + `domains/*.js`) | one renderer/model/interactions, N host-supplied domains |
| File browser | `Audio-Haxor/frontend/js/file-browser.js` → promote to a shared submodule | multi-pane browser over a host-provided fs backend (shim) |

## Requirements

Each item is a **MUST** for every app in the roster.

### R1 — Command palette (Cmd+K)
A fuzzy command palette opens on **Cmd/Ctrl+K**, lists every actionable command, and runs
the selected one. Backed by `command-palette.js`; the palette's matcher is the shared fzf
matcher (R7) so its highlight matches every other filter in the app. Every feature that has
a toolbar button or keyboard shortcut must also be reachable from the palette.

### R2 — Stryke Hooks editor
Every app embeds the shared `zpwr-hooks-editor` (Monaco) for editing stryke lifecycle hooks.
Same editor, same keybindings, same theme across apps. It is built once (esbuild bundle) and
vendored; apps never fork the editor.

### R3 — Embedded terminal
A real PTY-backed terminal (`zpwr-embed-terminal`, xterm.js) is available in every app:
- Toggle with **Ctrl+`** (built into the shared module) **and** a host **Cmd+T** shortcut,
  and a **command-palette entry** (R1).
- Dock-to-corner drag, geometry + visibility persisted via the host prefs (`window.prefs`),
  falling back to `localStorage`.
- The **✕ "Kill & close"** button kills the PTY **and** hides the pane; **⎯** hides only.
- Renders Nerd Font glyphs from a **bundled** `HackNerdFontMono-Regular.woff2` (`@font-face`),
  never a system-installed font (see Pitfalls).

### R4 — Shared styles
All apps share one visual language: the cyberpunk design tokens (color palette, borders,
glass surfaces, `Orbitron` + `Share Tech Mono` type) from `cyberpunk.css`. New surfaces use
the token variables, not hardcoded values. An element moved between two apps must look the
same.

### R5 — Tile dashboard + tab bar
- A **tab bar** switches top-level views; the active tab is visually unambiguous.
- A **tile dashboard** is the landing/overview surface: a grid of tiles, each a live entry
  point into a feature. Tiles use the shared tile component, not bespoke markup per app.

### R6 — Logo, top-left
The MenkeTechnologies app logo sits in the **top-left** of the header, as the family anchor.
The header strip is a shared component (logo + title at left, status/chips at right).

### R7 — Filters: fzf with highlighted matched characters
Every filter/search input in every app is a **fuzzy** filter using the shared fzf matcher,
and **highlights the matched characters** in each result. No app ships a plain
`includes()`/substring filter and no app ships a second fuzzy matcher. One matcher, one
highlight style, everywhere — list filters, the command palette (R1), table filters (R8).

### R8 — Tables: sortable + resizable columns
Every data table in every app:
- **Sortable columns** — click a header to sort; click again to reverse; the active
  sort column + direction are indicated.
- **Resizable columns** — drag the column edge to resize; widths persist per table via prefs.

Both behaviors come from one shared table component; tables are never hand-rolled per view.

### R9 — DAW arrangement grid (one engine, per-app purpose)
Every app embeds the shared **`zpwr-clip-engine` arrangement grid** — the same canvas
renderer, model, and interaction layer the DAW uses — repurposed for the app's own content.
This is the family's timeline substrate: a bar/time axis, lanes, draggable/resizable regions,
breakpoint automation, playhead, and loop region, usable for *any* time- or sequence-ordered
data, not only audio.

The grid is content-agnostic by design: `createGrid({ canvas, domain, store, storageKey,
onChange, popover })` wires one model + one renderer + one interaction model onto a canvas and
is driven entirely by a **domain** (`webui/grid/domains/*.js`). A domain supplies
`lanes()`, `timeAxis()`, `value`, `capabilities`, and labels — everything content-specific.
"One renderer, one interaction model, **N domains**, host-injected transport."

- An app **MUST** reuse `createGrid` + the shared renderer/model/interactions — never fork the
  grid. Repurposing = writing (or reusing) a **domain**, plus a `store` and an `onChange` that
  persists/pushes to the app's own backend.
- Shipping domains: `notes` (piano roll), `arranger` (clip arrangement), `launcher` (session
  clips), `autolanes` / `automation` (breakpoint lanes), `triggers`. New purposes add a new
  domain file, not a new grid.
- Intended per-app purposes (INVENTIONS #1 — a general-purpose arranger embedded in any host,
  including non-audio): **zpwr-daw** → notes/clips/arrangement; **traderview** → trades on the
  timeline; **ztranslator** → translations; **Audio-Haxor** → stryke on clips; synth/fx/midi-fx
  → the clip/automation lane for the plugin.

### R10 — File browser (ported from Audio-Haxor)
Every app embeds the Audio-Haxor **multi-pane file browser** — the same resizable panes,
hidden-file toggle, rename/copy/move, keyboard navigation, and per-pane path persistence.
It is the family's file surface (open/import/export, project/sample/asset browsing).

- The browser is **promoted to a shared module** (mirror `zpwr-embed-terminal`): one source,
  vendored into every app — never re-forked. Today it lives only in
  `Audio-Haxor/frontend/js/file-browser.js`; it must move to a shared submodule.
- Filesystem access goes through a **host-provided backend behind a transport shim**, the
  same way the terminal abstracts its PTY. The host supplies the fs ops
  (`listDirectory`, `renameFile`, copy/move/delete, …); Tauri routes them to `invoke`,
  JUCE to a native function. The shared module never calls a host-specific API directly.
- State persists via `window.prefs` (the R3 contract): pane count, paths, active pane,
  per-pane flex widths.
- Panes and columns are **resizable** and filtering is **fuzzy** — reuse R7 (fzf) and R8
  (resizable/sortable) rather than the browser's own one-off implementations.

## Host substrate notes

### Tauri apps
- Frontend is static. A `beforeBuildCommand`/`beforeDevCommand` copy step syncs shared
  modules from the submodules into the served `frontend/` (e.g. `copy-embed-terminal.mjs`),
  including the bundled font into `frontend/fonts/`.
- `window.prefs` must be exposed by the host (backed by the app's config store) so shared
  modules persist state through the same backend as everything else; absent it, they fall
  back to `localStorage`.

### JUCE WebView apps
- Shared web assets are embedded with `juce_add_binary_data`; the resource provider resolves
  a request URL to a blob **by basename**, and sets the MIME type from the file extension
  (`text/css`, `text/javascript`, `font/woff2`, …). Adding an asset = add it to the
  `SOURCES` list; reference it by a path whose basename matches.
- The transport shim selects `window.Juce` native functions + `window.__JUCE__.backend`
  events; the same commands/events contract as the Tauri path.

## Pitfalls (learned, load-bearing)

- **No system-font dependency.** Bundle every non-web-safe font as `@font-face` from a
  vendored `woff2` (`font-display: block`). A `font-family` that resolves only against a
  user-installed font renders tofu (□) on a clean machine — it merely *looks* fine on a dev
  box that happens to have the font.
- **Shared (non-module) scripts must not declare colliding top-level bindings.** A bare
  `var x` at top level in a shared classic script collides with a host's global `let/const x`
  as a **parse-time** `SyntaxError`, which silently aborts the whole file — every later
  `window.fn = …` export never runs and every caller no-ops. Name shared globals distinctly
  (e.g. `termPrefs`, not `prefs`).
- **Vendor shared modules before snapshotting the dist.** If a build stages a clean
  `frontend-dist/` *before* the vendor/copy step writes the shared modules into `frontend/`,
  those modules miss the bundle and 404 at runtime (`'text/html' is not a valid JavaScript
  MIME type` — the import hit the SPA fallback). Vendor first, snapshot second.
- **A single NUL byte makes an asset parse as binary.** A stray control byte in an HTML/JS
  asset makes the WebView treat it as `data` and abort parsing at the byte — the inline
  module never runs and the UI silently loses whole sections. Keep assets clean text;
  `file <asset>` must report text, not `data`.

## Conformance checklist

Per app, all ten must be true:

- [ ] R1 Command palette (Cmd+K), palette matcher = shared fzf
- [ ] R2 Stryke Hooks editor (shared `zpwr-hooks-editor`)
- [ ] R3 Embedded terminal (Ctrl+` + Cmd+T + palette entry; ✕ closes; bundled font)
- [ ] R4 Shared cyberpunk styles / tokens
- [ ] R5 Tile dashboard + tab bar (shared components)
- [ ] R6 Logo top-left (shared header)
- [ ] R7 All filters fuzzy (fzf) with matched-char highlight
- [ ] R8 All tables sortable + resizable columns (shared table component)
- [ ] R9 Arrangement grid embedded (shared `zpwr-clip-engine` `createGrid` + app domain)
- [ ] R10 File browser embedded (shared module ported from Audio-Haxor, fs backend via shim)

### Known conformance gaps (close these)

- **Command palette is not yet single-source.** `command-palette.js` exists in
  `zpwr-patch-core/webui` (JUCE shell) and a separate `Audio-Haxor/frontend/js/command-palette.js`;
  ztranslator implements its palette inline in `ztranslator_view.js`. Converge all three on
  one shared module.
- **Styles are split by substrate.** JUCE apps share `cyberpunk.css`; the Tauri apps
  (Audio-Haxor, traderview, ztranslator) carry their own stylesheets. Extract the shared
  design tokens so both substrates read the same theme source.
- **Tables and fuzzy filters are reused ad hoc**, not yet through one shared component each.
  Promote the fzf matcher and a table component to shared modules and route every instance
  through them.
- **File browser exists only in Audio-Haxor** (`frontend/js/file-browser.js`) and calls
  Tauri `vstUpdater` fs commands directly. Promote it to a shared submodule behind a
  backend shim (Tauri `invoke` / JUCE native fn), then embed it in the other six apps.
- **Arrangement grid is embedded only in zpwr-daw.** The other six apps need a domain +
  `createGrid` embed (R9).
