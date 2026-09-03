# zgui-core Substrate Port — Conformance Audit

**Date:** 2026-06-28
**Rule audited:** *Only `zgui-core` UI elements are allowed in any desktop app.* Every control,
dialog, table, toast, modal, panel, and chrome element must come from `zgui-core`
(`window.ZGui.*`), consumed as the shared submodule at `frontend/lib/zgui-core` — never a
hand-rolled parallel widget. If a needed element doesn't exist in `zgui-core` yet, **add it there
first**, then consume it.

This audit covers the **14 clone-of-known-software desktop apps** below. (Audio-Haxor and the JUCE
plugins are the *reference* apps zgui-core was extracted from and are out of scope here.)
zgui-core currently ships **260 components** under `webui/*.js`.

> **Roster drift (2026-08-02):** `app-store/store.js` now lists **22** `category: 'Desktop Apps'`
> ids. Six of them — **`zstation`**, **`zwire`**, **`zthrottle`**, **`zlatex`**, **`zmusic`** and
> **`ztorrent`** — postdate this 2026-06-28 audit and are **not yet ranked** below; `zmax-gui` is
> ranked here but is not in that store category (`audio-haxor` and `zpwr-daw` are, but are the
> out-of-scope reference apps). Re-run the conformance sweep to cover those six before treating
> this audit as complete.
>
> **Adoption re-check (2026-08-02):** the individual gaps re-verified below have since been
> closed in the submodules; the **percentages in the ranking table have not been re-measured**
> and are still the 2026-06-28 figures. Closed since the audit:
> `zemail` compose + signature now build on `ZGui.richText`
> (`zemail-core/frontend/zemail.js:1712`, `:4506`); `zcite` notes route onto it too
> (`zcite-core/webui/zcite.js:1417-1427`); `zmax-gui`'s two sites are now
> `ZGui.toggleGroup` / `ZGui.combobox` (`zmax-gui-core/webui/menu.js:1609`, `:1632`);
> `zftp`'s transfer queue is now `ZGui.transferList` (`zftp-core/frontend/zftp.js:2339`);
> `ztranslator`'s dialogs are `ZGui.modal` and its inline rename is `ZGui.editable`
> (`ztranslator-core/frontend/ztranslator_view.js:8`, `:1221`); `zpdf` now loads all four
> previously-missing components (`tabs` / `popover` / `tree` / `log-view` in
> `zpdf/frontend/index.html`); `zgo`'s ⌘L Large Type is built on the shared zgui-core modal
> (`zgo-core/frontend/zgo.js:179-186`); and `traderview` now loads **26** zgui-core assets, not 12.

## Conformance ranking (worst → best)

| # | App | Clones | Conformance | Bespoke sites | Headline gap |
|---|-----|--------|-------------|---------------|--------------|
| 1 | **traderview** | TradingView | **<1%** | ~1655 files, 6172 DOM calls | zgui-core is now wired in (submodule + 26 assets loaded in `index.html`) but barely consumed; uPlot/LightweightCharts charts; hand-rolled palette/context-menu/dialog/wizard; 207 KB custom CSS |
| 2 | **zgo** | Alfred | ~12% | 219 `el()` / 14 panes | Launcher window clean (`ZGui.launcher`); **prefs window** fully hand-rolled |
| 3 | **zterminal** | iTerm2 | ~15–20% | 171 across 25+ files | Settings frontend builds custom `div`+CSS instead of ZGui containers |
| 4 | **ztunnel** | ngrok | ~15–20% | 24 | toolbar/sidebar/toggles/stat-grid/log-view/import-modal/terminal-pane |
| 5 | **zoffice** | MS Office / LibreOffice | ~27% | 95 | "Legacy" inspector views + `index.html` toolbar/nav; duplicated find/replace |
| 6 | **zcontainer** | Docker Desktop | ~35–40% | 20 | nav sidebar, list/log/diff/procs/mounts tables, toolbars, drawer, status bar, dialog bodies |
| 7 | **zreq** | Postman | ~45–50% | ~60 | tree/tables/tabs/JSON on ZGui; method bar + toolbar + sidebar + form controls bespoke |
| 8 | **zpdf** | Adobe Acrobat | ~48% | 15 | tabs/forms/fields-table/info-popover/text-view/bookmarks; 4 needed components not even loaded |
| 9 | **zcite** | Zotero | ~62% | 5 critical + 8 minor | rating, tag chips, citation picker, rich notes, collection tree |
| 10 | **zmax-gui** | Emacs | ~87% | 2 | settings toggle button + `<select>` language picker |
| 11 | **ztranslator** | Google Translate | ~92% | 4 | 2 hand-rolled modals, inline rename input, trigger-grid button bar |
| 12 | **zftp** | FileZilla | ~95% | 1 (+fallbacks) | transfer-queue list hand-rolled; status dots; defensive fallbacks |
| 13 | **zemail** | Outlook/Thunderbird | ~98% | 1 | rich-text compose editor (**adoption gap** — `ZGui.richText` ships; zemail still hand-rolls it) |
| 14 | **zphoto** | Photoshop/GIMP | **100%** | 0 | — model implementation, no work needed |

## zgui-core backlog (genuinely missing — build these FIRST, then consume)

Both original backlog items are now resolved:

1. **`rich-text` / WYSIWYG editor** — **exists** (`zgui-core/webui/rich-text.js`) and the adoption
   gap is **closed**: `zemail` compose + signature (`zemail-core/frontend/zemail.js:1712`, `:4506`)
   and the `zcite` note editor (`zcite-core/webui/zcite.js:1417-1427`) both route onto
   `ZGui.richText`.
2. **`large-type` fullscreen overlay** (minor) — zgo's ⌘L "Large Type". There is still no
   dedicated `zgui-core/webui/large-type.js`, and none is needed: zgo built it on the shared
   `ZGui.modal` overlay chrome (`zgo-core/frontend/zgo.js:179-186`), which is exactly what this
   item asked for. Promote it to a named component only if a second app needs it.

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
- **Wired (done):** `crates/zgui-core` is a submodule (`.gitmodules:23`) and `frontend/index.html` now loads **26** zgui-core assets (`lib/zgui-core/webui/*`, `:12`–`:278`). Remaining: route the UI through those components and retire `css/styles.css` (207 KB) onto cyberpunk tokens

### zgo (Alfred) — `crates/zgo-core/frontend/prefs.js`
- 14 render panes (default/webSearch/clipboard/snippets/files/bookmarks/music/system/runningApps/history/triggers/scriptFilter/feedback/debugger) → `ZGui.dataTable` / `tree` / `accordion` / `field` / `jsonView` / `logView`
- `zgo.js` Large-Type overlay → **done**: built on the shared `ZGui.modal` overlay (`zgo.js:179-186`)

### zterminal (iTerm) — `settings/frontend/`
- 8 list tabs (commands/envvars/profiles/layouts/snippets/triggers/processes/recentdirs) → `ZGui.dataTable`
- tmux session→window→pane → `ZGui.tree`; collapsible config/buffer/keys → `ZGui.accordion` + `ZGui.field`
- dashboard panels → `ZGui.tileGrid` + `ZGui.card`; toolbars → `ZGui.buttonBar`; settings schema → `ZGui.settings`/`prefs-shell`; inline CSS (`index.html:9-123`) → cyberpunk tokens

### ztunnel (ngrok) — `crates/ztunnel-core/webui/ztunnel.js`, `crates/zpwr-embed-terminal/webui/terminal.js`
- toolbar → `ZGui.buttonBar`; sidebar config list → `ZGui.menu`/`tree`; status dots → `ZGui.statusPill`; stat grid → `ZGui.statStrip`/`statistic`; toggles (×6) → `ZGui.toggleGroup`; log box → `ZGui.logView`; import modal → `ZGui.modal`+`field`; settings → `ZGui.prefsShell`; terminal pane → `ZGui.floatingDock`; error box → `ZGui.alert`

### zoffice (Office) — `crates/zoffice-core/webui/app.js`, `frontend/index.html`
- 48 `nav-item` buttons → `ZGui.buttonBar`/`menu`; legacy inspector find/replace (×4 apps) → consolidate on `ZGui.searchBox`; `details/summary` → `ZGui.collapsible`; index.html toolbar → `ZGui.toolbar`; `.lang` select → `ZGui.segmented`; error div → `ZGui.alert`

### zcontainer (Docker Desktop) — `crates/zcontainer-core/frontend`
- `renderTable()` (containers/images/volumes/networks/compose/k8s) + logs/diff/procs/mounts → `ZGui.dataTable`; nav sidebar → `ZGui.menu`; toolbars/dialog bodies → `ZGui.field`+`toolbar`; drawer → `ZGui.drawer`; status footer → `ZGui.statusBar`; file list → `ZGui.tree`; facts grid → `ZGui.metadata`; batch bar → `ZGui.batchSelect` (all exist — just load + use)

### zreq (Postman) — `crates/zreq-core/webui/zreq.js`
- ~15 `.zr-btn` → `ZGui.buttonBar`/`buttonGroup`/`splitButton`; ~8 `<select>` → `ZGui.combobox`; ~12 `<input>` → `ZGui.field`/`inputGroup`; 5 empty divs → `ZGui.emptyState`; response status → `ZGui.statusPill`; method badges → `ZGui.formatBadge`; script/markdown textareas → `ZGui.codeEditor`; body-mode toggles → `ZGui.segmented`

### zpdf (Acrobat) — `crates/zpdf-core/frontend`
- `prefRow()`/`fieldControl()` selects+inputs → `ZGui.field`/`select`; layout buttons → `ZGui.buttonGroup`; fields `<table>` → `ZGui.dataTable`; tab bar → `ZGui.tabs`; info panel → `ZGui.popover`; text `<pre>` → `ZGui.logView`; bookmarks `<ul>` → `ZGui.tree` (`tabs`/`popover`/`tree`/`log-view` are **now loaded** in `frontend/index.html` — route the markup onto them)

### zcite (Zotero) — `crates/zcite-core/webui/zcite.js`
- stars → `ZGui.rating`; tag chips → `ZGui.tagInput`; citation picker → `ZGui.segmented`; collection tree → `ZGui.tree`; library `<select>` → `ZGui.combobox`; attachments → `ZGui.transferList`; metadata/creator/field/annotation forms → `ZGui.field`; ~~rich notes → `ZGui.richText`~~ **done** (`zcite.js:1417-1427`)

### zmax-gui (Emacs) — `crates/zmax-gui-core/webui/menu.js` — ✅ both sites ported
- ~~`toggleControl()`~~ → `ZGui.toggleGroup` (`:1609`); ~~`languageControl()`~~ → `ZGui.combobox` (`:1632`)

### ztranslator (Google Translate) — `crates/ztranslator-core/frontend/ztranslator_view.js`, `crates/ztranslator-core/frontend/trigger-grid.js`
- ~~settings overlay + code overlay~~ → `ZGui.modal` **done** (`:8`); ~~inline rename (`renameSelection()`)~~ → `ZGui.editable` **done** (`:1221`); trigger-grid panel → `ZGui.toolbar`/`buttonBar`

### zftp (FileZilla) — `crates/zftp-core/frontend/zftp.js`
- ~~`renderTransfers()`~~ → `ZGui.transferList` **done** (`:2339`); status dots → `ZGui.statusPill` (still open — no `statusPill` call in `zftp.js`); remove `Z.x ? … : el()` defensive fallbacks (technically bespoke paths)

### zemail (Outlook) — `zemail-core/frontend/zemail.js`
- ~~rich-text compose → `ZGui.richText`~~ **done** (`:1712` compose, `:4506` signature); recipient `<datalist>` → `ZGui.searchSelect` (optional)

### zphoto — none. ✅

## Recommended porting order

1. ~~**Route zemail + zcite onto `ZGui.richText`**~~ — **done** in both apps.
2. **Quick wins to 100%** (≤4 sites each): zphoto ✅, zmax-gui ✅, zemail ✅, ztranslator (trigger-grid
   panel left), zftp (status dots + defensive fallbacks left).
3. **Medium adoption ports** (route the now-loaded components): zcite, zpdf, zreq, zcontainer, zoffice.
4. **Heavy ports**: ztunnel, zterminal, zgo prefs.
5. **traderview last** — it's a near-total UI-layer rewrite (wire zgui in, replace charts, retire custom CSS); treat as its own multi-step project.
6. **Rank the six unranked apps** — `zstation`, `zwire`, `zthrottle`, `zlatex`, `zmusic`, `ztorrent`.
