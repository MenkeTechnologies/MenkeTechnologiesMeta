# zgui-core Substrate Port — Conformance Audit

**Date:** 2026-06-28
**Rule audited:** *Only `zgui-core` UI elements are allowed in any desktop app.* Every control,
dialog, table, toast, modal, panel, and chrome element must come from `zgui-core`
(`window.ZGui.*`), consumed as the shared submodule at `frontend/lib/zgui-core` — never a
hand-rolled parallel widget. If a needed element doesn't exist in `zgui-core` yet, **add it there
first**, then consume it.

This audit covers the **14 clone-of-known-software desktop apps**. (Audio-Haxor and the JUCE
plugins are the *reference* apps zgui-core was extracted from and are out of scope here.)
zgui-core currently ships **244 components** under `webui/*.js`.

## Conformance ranking (worst → best)

| # | App | Clones | Conformance | Bespoke sites | Headline gap |
|---|-----|--------|-------------|---------------|--------------|
| 1 | **traderview** | TradingView | **<1%** | ~1655 files, 6172 DOM calls | Doesn't load zgui at all; uPlot/LightweightCharts charts; hand-rolled palette/context-menu/dialog/wizard; 269 KB custom CSS |
| 2 | **zgo** | Alfred | ~12% | 219 `el()` / 14 panes | Launcher window clean (`ZGui.launcher`); **prefs window** fully hand-rolled |
| 3 | **zterminal** | iTerm2 | ~15–20% | 171 across 25+ files | Settings frontend builds custom `div`+CSS instead of ZGui containers |
| 4 | **ztunnel** | ngrok | ~15–20% | 24 | toolbar/sidebar/toggles/stat-grid/log-view/import-modal/terminal-pane |
| 5 | **zoffice** | MS Office / LibreOffice | ~27% | 95 | "Legacy" inspector views + `index.html` toolbar/nav; duplicated find/replace |
| 6 | **zcontainer** | Docker Desktop | ~35–40% | 20 | nav sidebar, list/log/diff/procs/mounts tables, toolbars, drawer, status bar, dialog bodies |
| 7 | **zreq** | Postman | ~45–50% | ~60 | tree/tables/tabs/JSON on ZGui; method bar + toolbar + sidebar + form controls bespoke |
| 8 | **zpdf** | Adobe Acrobat | ~48% | 15 | tabs/forms/fields-table/info-popover/text-view/bookmarks; 4 needed components not even loaded |
| 9 | **zcite** | Zotero | ~62% | 5 critical + 8 minor | rating, tag chips, citation picker, rich notes, collection tree |
| 10 | **zemacs-gui** | Emacs | ~87% | 2 | settings toggle button + `<select>` language picker |
| 11 | **ztranslator** | Google Translate | ~92% | 4 | 2 hand-rolled modals, inline rename input, trigger-grid button bar |
| 12 | **zftp** | FileZilla | ~95% | 1 (+fallbacks) | transfer-queue list hand-rolled; status dots; defensive fallbacks |
| 13 | **zemail** | Outlook/Thunderbird | ~98% | 1 | rich-text compose editor (**genuine zgui gap**) |
| 14 | **zphoto** | Photoshop/GIMP | **100%** | 0 | — model implementation, no work needed |

## zgui-core backlog (genuinely missing — build these FIRST, then consume)

Only **one** real new component is required across all 14 apps:

1. **`rich-text` / WYSIWYG editor** — `ZGui.richText(container, {value, onChange, toolbar})`
   with bold/italic/underline/lists/link, emitting HTML. Consumers: **zemail** compose body
   (currently `contenteditable` + `execCommand`), **zcite** note editor. Until it exists, those
   two surfaces are the only legitimately-blocked ports.
2. **`large-type` fullscreen overlay** (minor) — zgo's ⌘L "Large Type". Implement as a thin
   variant of `ZGui.modal` (or `ZGui.modal` fullscreen flag) rather than a bespoke overlay.

> **Correction to the per-app reports:** several auditors labelled `tree`, `tree-table`,
> `accordion`, `drawer`, `status-bar`, `metadata` (facts grid), `batch-select` (batch toolbar),
> `collapsible`, `settings`/`prefs-shell`, `tile-grid` (dashboard grid), `popover`, `tabs`,
> `log-view`, `field`/`input-group`, `rating`, `tag-input`, `editable`, `combobox`,
> `search-select`, `node-graph`, and the trading charts (`candlestick`/`chart`/`depth-chart`/
> `volume-profile`/`liquidity-heatmap`/`footprint`) as "missing from zgui-core". **All of these
> already exist.** They are adoption gaps — the component just isn't loaded/used in that app.

## Per-app violation → ZGui component map

### traderview (full rewrite of UI layer)
- Charts: `uPlot` / `LightweightCharts` → `ZGui.candlestick` / `chart` / `depth-chart` / `volume-profile` / `liquidity-heatmap` / `footprint` (253 chart files)
- `command_palette.js` → `ZGui.palette`; `context_menu.js` → `ZGui.contextMenu`; `dialog.js` → `ZGui.modal`; `setup_wizard.js` → `ZGui.modal` + `ZGui.wizard`
- broker/business `<select>` → `ZGui.dropdownMenu`; topbar tabs/buttons → `ZGui.tabs` + `ZGui.toolbar`
- **Prereq:** add `lib/zgui-core` submodule + load `all.css` + `webui/*` (not currently wired in `index.html`); retire `css/styles.css` (269 KB) onto cyberpunk tokens

### zgo (Alfred) — `crates/zgo-core/frontend/prefs.js`
- 14 render panes (default/webSearch/clipboard/snippets/files/bookmarks/music/system/runningApps/history/triggers/scriptFilter/feedback/debugger) → `ZGui.dataTable` / `tree` / `accordion` / `field` / `jsonView` / `logView`
- `zgo.js` Large-Type overlay → new `ZGui.modal` fullscreen variant (backlog #2)

### zterminal (iTerm) — `settings/frontend/`
- 8 list tabs (commands/envvars/profiles/layouts/snippets/triggers/processes/recentdirs) → `ZGui.dataTable`
- tmux session→window→pane → `ZGui.tree`; collapsible config/buffer/keys → `ZGui.accordion` + `ZGui.field`
- dashboard panels → `ZGui.tileGrid` + `ZGui.card`; toolbars → `ZGui.buttonBar`; settings schema → `ZGui.settings`/`prefs-shell`; inline CSS (`index.html:9-123`) → cyberpunk tokens

### ztunnel (ngrok) — `frontend/ztunnel.js`, `terminal.js`
- toolbar → `ZGui.buttonBar`; sidebar config list → `ZGui.menu`/`tree`; status dots → `ZGui.statusPill`; stat grid → `ZGui.statStrip`/`statistic`; toggles (×6) → `ZGui.toggleGroup`; log box → `ZGui.logView`; import modal → `ZGui.modal`+`field`; settings → `ZGui.prefsShell`; terminal pane → `ZGui.floatingDock`; error box → `ZGui.alert`

### zoffice (Office) — `frontend/app.js`, `index.html`
- 48 `nav-item` buttons → `ZGui.buttonBar`/`menu`; legacy inspector find/replace (×4 apps) → consolidate on `ZGui.searchBox`; `details/summary` → `ZGui.collapsible`; index.html toolbar → `ZGui.toolbar`; `.lang` select → `ZGui.segmented`; error div → `ZGui.alert`

### zcontainer (Docker Desktop) — `crates/zcontainer-core/frontend`
- `renderTable()` (containers/images/volumes/networks/compose/k8s) + logs/diff/procs/mounts → `ZGui.dataTable`; nav sidebar → `ZGui.menu`; toolbars/dialog bodies → `ZGui.field`+`toolbar`; drawer → `ZGui.drawer`; status footer → `ZGui.statusBar`; file list → `ZGui.tree`; facts grid → `ZGui.metadata`; batch bar → `ZGui.batchSelect` (all exist — just load + use)

### zreq (Postman) — `frontend/zreq.js`
- ~15 `.zr-btn` → `ZGui.buttonBar`/`buttonGroup`/`splitButton`; ~8 `<select>` → `ZGui.combobox`; ~12 `<input>` → `ZGui.field`/`inputGroup`; 5 empty divs → `ZGui.emptyState`; response status → `ZGui.statusPill`; method badges → `ZGui.formatBadge`; script/markdown textareas → `ZGui.codeEditor`; body-mode toggles → `ZGui.segmented`

### zpdf (Acrobat) — `crates/zpdf-core/frontend`
- `prefRow()`/`fieldControl()` selects+inputs → `ZGui.field`/`select`; layout buttons → `ZGui.buttonGroup`; fields `<table>` → `ZGui.dataTable`; tab bar → `ZGui.tabs`; info panel → `ZGui.popover`; text `<pre>` → `ZGui.logView`; bookmarks `<ul>` → `ZGui.tree` (load `tabs`/`popover`/`tree`/`log-view` — not currently loaded)

### zcite (Zotero) — `frontend/zcite.js`
- stars → `ZGui.rating`; tag chips → `ZGui.tagInput`; citation picker → `ZGui.segmented`; collection tree → `ZGui.tree`; library `<select>` → `ZGui.combobox`; attachments → `ZGui.transferList`; metadata/creator/field/annotation forms → `ZGui.field`; **rich notes → backlog #1** (`ZGui.richText`)

### zemacs-gui (Emacs) — `frontend/menu.js`
- `toggleControl()` (`:267`) → `ZGui.toggleGroup`; `languageControl()` (`:285`) → `ZGui.combobox`

### ztranslator (Google Translate) — `frontend/ztranslator_view.js`, `trigger-grid.js`
- settings overlay (`:1600`) + code overlay (`:1672`) → `ZGui.modal`; inline rename (`:1047`) → `ZGui.editable`; trigger-grid panel (`:115`) → `ZGui.toolbar`/`buttonBar`

### zftp (FileZilla) — `frontend/zftp.js`
- `renderTransfers()` (`:430`) → `ZGui.transferList`/`dataTable`; status dots → `ZGui.statusPill`; remove `Z.x ? … : el()` defensive fallbacks (technically bespoke paths)

### zemail (Outlook) — `frontend/zemail.js`
- rich-text compose (`:931`) → **backlog #1** (`ZGui.richText`); recipient `<datalist>` → `ZGui.searchSelect` (optional)

### zphoto — none. ✅

## Recommended porting order

1. **Build backlog #1 (`ZGui.richText`)** in zgui-core — unblocks zemail + zcite.
2. **Quick wins to 100%** (≤4 sites each): zphoto ✅, zftp, zemail, ztranslator, zemacs-gui.
3. **Medium adoption ports** (load + route existing components): zcite, zpdf, zreq, zcontainer, zoffice.
4. **Heavy ports**: ztunnel, zterminal, zgo prefs.
5. **traderview last** — it's a near-total UI-layer rewrite (wire zgui in, replace charts, retire custom CSS); treat as its own multi-step project.
