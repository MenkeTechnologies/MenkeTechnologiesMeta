# GUI Polish Gate — Close-Out Checklist

Concrete tasks to drive all **22 Desktop Apps** to **PASS** on
[`GUI_POLISH_GATE.md`](GUI_POLISH_GATE.md) (G1–G4) and
[`GUI_APP_REQUIREMENTS.md`](GUI_APP_REQUIREMENTS.md) (R1–R10).
[`COMPONENTS.md`](COMPONENTS.md) holds the authoritative embed matrix; this is the work list.

**Roster — all 22 `category: 'Desktop Apps'` ids in `app-store/store.js`:**
`Audio-Haxor` (reference), `traderview`, `ztranslator`, `zpwr-daw`, `zpdf`, `zemail`, `zoffice`,
`zreq`, `ztunnel`, `zgo`, `zftp`, `zcite`, `zterminal`, `zcontainer`, `zphoto`, `zstation`, `zwire`,
`zthrottle`, `zlatex`, `zmusic`, `ztorrent`, `zmax-gui`.

---

## Status matrix (2026-08-12) — measured from code

Every cell below was **re-measured from source**, one agent per app, each required to cite
`file:line`. This replaces the 2026-06-30 snapshot, which covered 14 apps and — as the correction
log records — was **wrong**, not merely stale, on several rows.

The columns are the requirement ids themselves (R1–R10, G1–G4) rather than the previous
abbreviations, because that is the granularity the audit actually measured. Where the old matrix's
`set` / `clr` columns had no corresponding measurement they are not carried forward as guesses.

| Value | Meaning |
| :--: | --- |
| **✓** | measured PASS, via the canonical shared source |
| **✗** | measured FAIL |
| **◐** | partial — real but incomplete, or present via a per-app implementation rather than the shared source |
| **N/A** | not applicable to this app's substrate, with a stated reason |

| App | R1 pal | R2 hooks | R3 term | R4 tokens | R5 tiles/tabs | R6 logo | R7 fzf | R8 tables | R9 grid | R10 fb | G1 | G2 | G3 | G4 |
| --- |:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| Audio-Haxor | ✓ | ✓ | ✓ | ◐ | ✓ | ✓ | ◐ | ◐ | ✓ | ✓ | ✓ | ◐ | ✓ | ✓ |
| traderview | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ◐ | ◐ | ✓ | ✓ | ◐ | ◐ | ✗ | ✓ |
| ztranslator | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ✗ | ◐ |
| zpwr-daw | ✓ | ✓ | ✓ | ✓ | ◐ | ✓ | ✓ | ✓ | ✓ | ✗ | ◐ | ◐ | ✗ | ◐ |
| zpdf | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ◐ | ◐ |
| zemail | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ✓ | ✓ |
| zoffice | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ◐ | ◐ | ✓ | ✓ |
| zreq | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ◐ | ✓ |
| ztunnel | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ |
| zgo | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ✓ | ✓ | ✓ | ◐ | ◐ | ✗ | ◐ |
| zftp | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ✗ | ✓ |
| zcite | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A | ✓ | ◐ | ◐ | ◐ | ✓ |
| zterminal | ✓ | ✗ | N/A | ✓ | ✓ | ✓ | ✓ | ◐ | ✗ | ✗ | ◐ | ◐ | ✗ | ◐ |
| zcontainer | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ◐ | ◐ | ✗ | ◐ |
| zphoto | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ◐ | ◐ | ◐ | ✓ |
| zstation | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ✗ | ✓ |
| zwire | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ◐ | ◐ | ✗ | ◐ |
| zthrottle | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ◐ | ◐ | ✗ | ✓ |
| zlatex | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ✗ | ✓ |
| zmusic | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ✗ | ✗ | ◐ |
| ztorrent | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ✗ | ✓ |
| zmax-gui | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ◐ | ◐ | ✗ | ✓ |

### Substrate notes (why a cell is N/A, not a gap)

- **zterminal R3 = N/A** — it *is* the terminal. Embedding `zpwr-embed-terminal` (xterm.js over a PTY
  shim) would put a second, worse emulator inside the first.
- **zcite R9 = N/A** — a reference manager has no sequence-ordered timeline content to put on a grid.
- **zterminal** is a native OpenGL renderer and **zwire** a Chromium superset; where a requirement
  presumes a Tauri WebView, their rows record the requirement's *intent*, not the Tauri mechanism.
- **zpwr-daw** is a JUCE `WebBrowserComponent` host: `tauri*` and `test:rust` are N/A to its G4.

---

## Correction log — ledger claims this audit measured FALSE

Recorded so the doc's failure mode is visible, not just its numbers. Each was verified at the file.

| Claim in the previous ledger | Measured reality |
| --- | --- |
| `zterminal` is `✗` on palette, settings, shared styles, header, tiles, colorscheme | **All six PASS.** Palette at `zterminal/zterminal/src/config/bindings.rs:686` (⌘K → `Action::OpenCommandPalette`), ⌘, at `:721`, shared `all.css` at `settings/frontend/index.html:7`, `ZGui.header.build` at `zterminal-settings.js:783`, `ZGui.tileGrid` at `dashboard/dashboard.js:47` |
| `zterminal` is "N/A — not on this bus" (`GUI_AUTOMATION_BUS_CHECKLIST.md`) | **On a bus.** `zterminal/zterminal/src/zbus.rs` is 1,745 lines spawned at `main.rs:226`, publishing ~200 verbs with enforced reversibility |
| `Audio-Haxor` consumes `ZGui.dataTable` / `ZGui.table` (R8) | **Zero call sites in app code.** Sorting is `frontend/js/sort-persist.js:5`, resizing `frontend/js/columns.js:17` — hand-rolled, and the origin the shared component was extracted *from* |
| `zoffice` is `✗` on fzf filters (R7) | **PASS** — 10 `ZGui.fzf` sites across `app.js` and `zoffice-ext.js` |
| `zreq` R9 is `N/A` | **PASS** — `zreq-core/webui/run-arrangement.js` already drives `createGrid` with a `requests` domain |
| `zpwr-daw` is green on nearly everything | **R5, R10, G2, G3 are not green.** Measured against the *recorded pointers*, not the drifted worktree |
| `traderview` is `✓` on G2 and G3 | **G2 `◐`, G3 `✗`.** It has no `-core` submodule at all (9 in-repo workspace crates), and 44 keys are absent from all 26 non-English catalogs |
| `zcontainer` has a hand-rolled skin, no shared tokens | **PASS** — `index.html:19` loads `lib/zgui-core/webui/all.css` before its own sheet |
| `zpwr-daw` `i18n` is wired | **`i18n.js` is bundled by `app/CMakeLists.txt` but nothing loads it** — the only reference in the pinned frontend is a test file |

---

## Reads from the matrix

- **R1–R8 are effectively closed fleet-wide.** The remaining non-✓ cells are `zterminal` R2 (no
  `zpwr-hooks-editor` submodule) and four `◐`s where an app runs its own implementation rather than
  the shared source: Audio-Haxor R7/R8 (it is the origin of both), traderview R5/R6/R7/R8, zgo R7
  (Preferences conforms; the launcher window cannot highlight until `ZGui.launcher` grew the
  capability — since fixed in `zgui-core`), zpwr-daw R5.
- **R9 is the largest remaining R-gap: 5 of 22 fail** — zoffice, zcontainer, zphoto, zwire,
  zthrottle. Each is closable the same way every app that closed it this cycle did: add
  `zpwr-clip-engine` as a submodule and contribute **only a domain file** to the shared `createGrid`,
  never a fork of the renderer. Four agents explicitly declined to land one unverified, because a
  canvas renderer cannot be exercised headlessly.
- **R10's `zpwr-file-browser` submodule is now in 21 of 22** — only `zpwr-daw` lacks it.
  `zterminal` and `zwire` have since added it but neither drives the shared browser yet, so their
  matrix cells stay `✗`. `zwire`'s gap is quantified: the shared `file-browser.js` needs ~35
  `window.zfbHost` methods and `zwire-host` implements 9.
- **G2 is the structural blocker.** Four apps now submodule all three cross-cutting engines
  (`zoffice`, `zemail`, `zreq`, `zftp`) but none yet mounts all three as real views. `zoffice-core`
  shipped its first mountable view this cycle (`webui/zoffice-view.js`, `window.mountZoffice`) plus a
  feature-gated Tauri plugin, which unblocks the office leg fleet-wide; `zpdf-core` already had one.
  `zemail-core` still has no embeddable view. `traderview` cannot satisfy G2 as written — it has no
  second repo to embed — and should be scored `◐` on a topology mismatch, not `✗`.
- **G3 is one shared repo, not 22 app problems.** Measured missing keys against `zpwr-i18n`:
  zcite 793, zcontainer 681, zmax-gui 911, zstation 561, zreq 281, zftp 249, ztorrent 231,
  zphoto ~310, traderview 44 (× 26 locales). The `t(key, fallback)` runtime bug that made these
  render as raw slugs — `appFmt` treated a string second argument as `vars` and ignored it — is
  **fixed** in `zpwr-i18n`, so an incomplete catalog now degrades to English rather than to
  `zph.airbrush`. The translations themselves remain outstanding and are not fakeable.
- **G4 is nearly closed** — 13 of 22 now PASS, up from 7. The remainder are `◐` where a script family
  is genuinely N/A (`i18n:*` for an app owning no catalog, `db:*` for a non-SQLite store, `tauri*`
  under JUCE) rather than missing.

---


## Phase A — Promote / converge shared sources (do ONCE, unblocks all)

These are the `GUI_APP_REQUIREMENTS.md` "known conformance gaps". Each must be a single
shared module before it can be embedded everywhere.

- [ ] **A1 Single command palette** — converge `Audio-Haxor/frontend/js/command-palette.js` and
  ztranslator's inline palette onto the canonical `zgui-core/webui/command-palette.js`; route all
  apps through it (R1). (`zpwr-patch-core` no longer ships a `command-palette.js` of its own.)
- [ ] **A2 Shared fzf matcher** — promote `zpwr-patch-core`'s `fzfMatch` to a shared module
  with one highlight style; every filter + the palette imports it (R7).
- [ ] **A3 Shared table component** — one sortable + resizable + width-persisting table; no
  hand-rolled tables (R8).
- [ ] **A4 Shared cyberpunk tokens** — extract `cyberpunk.css` design tokens so Tauri apps
  read the same theme source as the JUCE apps (R4).
- [ ] **A5 File browser is shared** — `zpwr-file-browser` is the promoted multi-pane browser behind
  an fs shim (C ABI + JUCE shim), embedded in **21/22** (R10). Still missing from **`zpwr-daw`** —
  the only Desktop App that does not list it in `.gitmodules`.
- [ ] **A6 Tile/tab/header components** — shared tile, tab bar, and header-strip components
  (R5/R6).

---

## Phase B — Embed the universal component set in every app — NOT DONE

Every Desktop App must embed all of these (submodule + wired + transport shim) as a real, working
embed (not just a `.gitmodules` line). Verified against each app's `.gitmodules`.

### B1 — `zpwr-embed-terminal` (R3) — 20/22 (missing: zterminal — N/A, it IS the terminal; zwire)
- [x] 20 apps (N/A for `zterminal` — it is itself the terminal).
- [ ] **zcontainer** — the submodule has landed (`crates/zpwr-embed-terminal`); its exec terminal
  still has to be routed onto it.

### B2 — `zpwr-hooks-editor` (R2) — 20/22 (missing: zterminal, zwire)
- [x] zpdf  - [x] zemail  - [x] zoffice  - [x] zreq  - [x] ztunnel  - [x] zgo
- [x] zftp  - [x] zcite  - [x] zcontainer
- [ ] **zterminal** — absent; its `.gitmodules` lists only `zgui-core`, `ztmux-core` and
  `zpwr-file-browser`.
- [ ] **zwire** — vendored at `extensions/hud-internal/vendor/zpwr-hooks-editor`, not a submodule.

### B3 — `zpwr-file-browser` (R10) — 21/22 (missing: zpwr-daw)
- [x] zpdf  - [x] zemail  - [x] zoffice  - [x] zreq  - [x] ztunnel
- [x] zgo  - [x] zftp  - [x] zcite  - [x] zcontainer
- [x] zterminal (`crates/zpwr-file-browser`)  - [x] zwire (`extensions/hud-internal/lib/file-browser`)
- [ ] **zpwr-daw** — absent from `.gitmodules`.

### B4 — `zpwr-i18n` (G3 runtime) — 18/22 direct (missing: zpdf, zterminal, zcontainer, zwire — zpdf and zcontainer receive it transitively, vendored inside their -core; localization completeness tracked in Phase D)
- [x] zcite  - [x] zcontainer (transitively — vendored inside `zcontainer-core`)
- [ ] **zterminal** — absent; no `zpwr-i18n` submodule, direct or transitive.

### B5 — Command palette + fzf filters + shared table (R1/R7/R8) — after Phase A
- [ ] All 14 route filters through the shared fzf matcher (no `includes()` substring filter).
- [ ] All 14 tables use the shared sortable/resizable component.
- [ ] All 14 bind **Cmd/Ctrl+K** to open the **app-owned** command palette listing every
  command (incl. any items contributed by embeds/cores — the app decides which to surface).
  The palette is NEVER in a core/embed (see the gate's "END-APP surfaces" rule).

### B6 — Tile dashboard + tab bar + top-left logo header (R5/R6)
- [ ] All 14 land on a tile dashboard with a tab bar and the shared header (logo top-left).

### B7 — Settings panel (**Cmd/Ctrl+,**) — 13/14 (2026-06-30 figure, NOT re-measured across the 22)
A searchable, **app-owned** settings panel bound to **Cmd/Ctrl+,** (NEVER in a core/embed;
cores only offer settings items — see the gate's "END-APP surfaces" rule). Nine of the ten apps
once listed here mount `ZGui.appShell`, which binds ⌘, and opens the panel itself
(`zgui-core/webui/app-shell.js:463`, `:472`):
- [x] zpdf  - [x] zemail  - [x] zoffice  - [x] zreq  - [x] ztunnel  - [x] zgo (Preferences window)
- [x] zftp  - [x] zcite  - [x] zcontainer
- [ ] **zterminal** — the only app with no settings panel: it does not mount the appShell.

### B8 — Colorschemes / theme switching (haxor `settings.js` theme switcher)
The family colorscheme picker (cyberpunk variants), wired through the shared tokens (A4) so a
theme change restyles every shared surface at once. Missing/unaudited in 10:
- [ ] zpdf  - [ ] zemail  - [ ] zoffice  - [ ] zreq  - [ ] ztunnel  - [ ] zgo
- [ ] zftp  - [ ] zcite  - [ ] zterminal  - [ ] zcontainer

---

## Phase C — `-core` engine embeds (G2) — NOT DONE

Per `COMPONENTS.md` "every GUI app" plan. Each = submodule + Rust dep / C ABI + a real view.
C2–C4 are the cross-cutting engines; verified against every app's `.gitmodules`.

- [x] **C1 own `-core`** wired natively **and** over the C ABI in every app that has one
  (`zcontainer-core`, `zpdf-core`, `zemail-core`, `zoffice-core`, `zreq-core`, `ztunnel-core`,
  `zgo-core`, `zcite-core`, `ztranslator-core`).
- [ ] **C2 `zpdf-core`** + a PDF view in all 13 non-source apps — embedded in **7**: `Audio-Haxor`,
  `zemail`, `zoffice`, `zreq`, `zftp`, `zlatex`, `zmax-gui`. Missing from zcite, zgo, ztunnel,
  zcontainer, zphoto, zstation, zthrottle, zmusic, ztorrent, traderview, ztranslator, zpwr-daw.
- [ ] **C3 `zoffice-core`** + an office view in all 13 non-source apps — embedded in **8**:
  `Audio-Haxor`, `zpdf`, `zemail`, `zreq`, `zftp`, `zcite`, `zlatex`, `zmax-gui`. Missing from every
  other non-source app.
- [ ] **C4 `zemail-core`** + a mail view in all 13 non-source apps — embedded in **4**: `zoffice`,
  `zreq`, `zftp`, `zcite`. Missing from every other non-source app.
- [x] **C5 `ztranslator-core`** in the show-control-relevant apps (haxor/traderview/daw), extracted
  from the `ztranslator` app.
- [ ] **C6 `zpwr-clip-engine` grid (R9)** + an app-specific domain in every app with
  time/sequence content (e.g. `zcontainer` → container/pod event + log timelines;
  `traderview` → trades; `zreq`/`zgo` → request/run history). Mark **N/A + reason** otherwise.
  (The clip-engine itself is embedded per `COMPONENTS.md`; this tracks the per-app grid **domain** UI.)
- [x] **C7 `zpwr-crate`** in asset apps; **N/A + reason** for non-asset apps
  (`zcontainer`, `zterminal`, `zreq`, `ztunnel`, `zgo`, `zcite`, …).

---

## Phase D — Full i18n (G3) for all 22

- [ ] **D1** The apps that embed `zpwr-i18n` actually **pass** the 18 i18n proof-contract
  tests across all 27 locales (embedding ≠ passing — verify, don't assume).
- [ ] **D2 zcite / zterminal / zcontainer**: extract every UI string to `app_i18n_en.json`, seed all 27
  locales (`cs da de el en es es_419 fi fr hi hu id it ja ko nb nl pl pt pt_br ro ru sv tr uk vi zh`),
  port the 18 `test/i18n-*.test.js`, make green.
- [ ] **D3** Every app's `i18n-no-raw-showtoast` + `i18n-ui-source` are green (no raw UI
  string can reach the screen) and wired into its CI.

---

## Phase E — Build / dev tooling parity (G4) for all 22

`dev`/`build`/`nuke`/`clean`/`bust`/`rebuild` are already ported across the 22 (the
"desktop-app gitlinks — haxor pnpm parity" pass). Remaining script families:

- [ ] **E1** `tauri:build:ci`, `ship-check`, `deploy` (+ `scripts/ship-check.sh`,
  `scripts/deploy.sh`) in every app.
- [ ] **E2** `test`, `test:js`, `test:rust` (+ `test:<engine>` per embedded `-core`) +
  `scripts/test.sh` in every app.
- [ ] **E3** `doc`, `doc:open`, `doc:sync` (cargo doc → `docs/api`) in every app.
- [ ] **E4** `i18n:sort`, `i18n:sort:check`, `i18n:audit` — reimplemented in **node**, not
  haxor's `python3` (house rule).
- [ ] **E5** `db:vacuum` / `db:stats` only where the app has a SQLite store; `build:<bundle>`
  per vendored shared bundle (e.g. `build:hooks-editor`).

---

## Phase F — R1–R10 conformance verification (per app, last)

Run the GUI_APP_REQUIREMENTS conformance checklist on each of the 22 and tick all ten:

- [ ] R1 palette  - [ ] R2 hooks  - [ ] R3 terminal  - [ ] R4 styles  - [ ] R5 dashboard/tabs
- [ ] R6 logo/header  - [ ] R7 fzf filters  - [ ] R8 tables  - [ ] R9 grid  - [ ] R10 file browser

A row in `COMPONENTS.md`'s consumption matrix and `GUI_POLISH_GATE.md`'s ledger flips to PASS only
when its F-checklist is fully ticked and G1–G4 are green.

---

## Suggested execution order

1. **Phase A** (shared shell sources) — unblocks the remaining R1/R7/R8/R5/R6 surfaces; one-time.
2. **Phase E** (scripts) — cheap, mechanical, parallelizable across all 22.
3. **B5–B8** (palette/fzf/table/dashboard/settings/colorschemes) — the non-embed shell surfaces.
4. **C6** (clip-engine grid domains) where time/sequence content exists.
5. **Phase D1 + Phase F** — verify and flip ledger rows to PASS.
