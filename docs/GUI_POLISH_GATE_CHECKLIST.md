# GUI Polish Gate — Close-Out Checklist

Concrete tasks to drive all **14 Desktop Apps** to **PASS** on
[`GUI_POLISH_GATE.md`](GUI_POLISH_GATE.md) (G1–G4) and
[`GUI_APP_REQUIREMENTS.md`](GUI_APP_REQUIREMENTS.md) (R1–R10).
[`COMPONENTS.md`](COMPONENTS.md) holds the authoritative embed matrix; this is the work list.

**Roster (the 14 Desktop Apps measured in the 2026-06-30 snapshot below):**
`Audio-Haxor` (reference), `traderview`, `ztranslator`, `zpwr-daw`, `zpdf`, `zemail`,
`zoffice`, `zreq`, `ztunnel`, `zgo`, `zftp`, `zcite`, `zterminal`, `zcontainer`.

> **Roster drift (2026-07-07):** `app-store/store.js` now lists **17** `category: 'Desktop Apps'`
> ids — the three additions **`zphoto`**, **`zstation`**, and **`zwire`** postdate this gate
> snapshot and are **not yet measured**. Run the Phase F audit to fold them into the matrix
> before treating this checklist as complete.

> **Embeds (Phase B + Phase C) are complete** — every app embeds the universal component set and
> any `-core` engine can be embedded in any GUI app. The remaining close-out work is the non-embed
> gate surface: shared shell convergence (Phase A), i18n proof tests (Phase D), pnpm script parity
> (Phase E), and R1–R10 conformance verification (Phase F).

---

## Status matrix (2026-06-30)

Measured from each app's `.gitmodules` (embeds) + a frontend grep (UI surfaces) +
`package.json` (scripts).

**Cell legend** — what a value means:

| Value | Meaning |
| :--: | --- |
| **✓** | present (via the canonical shared source) |
| **✗** | absent |
| **~** | present but **not** via the shared source — still a **FAIL** (e.g. a per-app fork or a substring filter) |
| **?** | not yet audited — resolve in Phase F; **not** counted as PASS |
| **N/A** | not relevant to this app |

**Column legend** — what each column is, and which gate it serves:

| Col | Dimension | Canonical source | Gate |
| --- | --- | --- | :--: |
| **pal** | Command palette — **Cmd/Ctrl+K** (app-owned; cores only offer items) | end-app shell | R1 |
| **hk** | Stryke hooks editor (Monaco) | `zpwr-hooks-editor` | R2 |
| **tm** | Embedded PTY terminal (xterm) | `zpwr-embed-terminal` | R3 |
| **sty** | Shared cyberpunk styles / design tokens | `cyberpunk.css` tokens | R4 |
| **set** | Settings panel — **Cmd/Ctrl+,** (app-owned; cores only offer items) | end-app shell | G1 |
| **clr** | Colorscheme / theme switcher | haxor theme switch + R4 tokens | R4 / G1 |
| **hdr** | Logo top-left + shared header strip | shared header | R6 |
| **fzf** | Fuzzy filters w/ matched-char highlight | shared `fzfMatch` | R7 |
| **tbl** | Sortable + resizable tables | shared table component | R8 |
| **grd** | Arrangement grid (`createGrid` + a domain) | `zpwr-clip-engine` | R9 |
| **fb** | Multi-pane file browser | `zpwr-file-browser` | R10 |
| **i18n** | Localized: 27 locales + 18 proof tests | `zpwr-i18n` | G3 |
| **scr** | Extended pnpm scripts (`test`/`doc`/`ship-check`/`deploy`/`i18n:*`) | haxor `package.json` | G4 |
| **-core** | Own `-core` engine embedded (native + C ABI) | the app's `-core` | G2 |

| App | pal | hk | tm | sty | set | clr | hdr | fzf | tbl | grd | fb | i18n | scr | -core |
| --- |:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:| --- |
| Audio-Haxor | ✓ | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | (app) |
| traderview | ✓ | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ~ | — |
| ztranslator | ✓ | ✓ | ✓ | ? | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | `ztranslator-core` |
| zpwr-daw | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ † | `zpwr-clip-engine` |
| zpdf | ✓ | ✓ | ✓ | ? | ✗ | ? | ? | ✓ | ✓ | ✗ | ✓ | ✓ | ✗ | `zpdf-core` |
| zemail | ✗ | ✓ | ✓ | ? | ✗ | ? | ? | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | `zemail-core` |
| zoffice | ✗ | ✓ | ✓ | ? | ✗ | ? | ? | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | `zoffice-core` |
| zreq | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A | ✓ | ~ | ✗ | `zreq-core` |
| ztunnel | ✗ | ✓ | ✓ | ? | ✗ | ? | ? | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | `ztunnel-core` |
| zgo | ✗ | ✓ | ✓ | ? | ✗ | ? | ? | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | `zgo-core` |
| zftp | ✗ | ✓ | ✓ | ? | ✗ | ? | ? | ✗ | ✗ | ✗ | ✓ | ✓ | ✗ | (app) |
| zcite | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | N/A | ✓ | ~ | ~ | `zcite-core` |
| zterminal | ✗ | ✓ | N/A | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ | ✓ | ~ | ✗ | (app) |
| zcontainer | ✗ | ✓ | ✓ | ~ | ✗ | ✗ | ~ | ✗ | ✗ | ✗ | ✓ | ~ | ✓ | `zcontainer-core` |

**Reads from the matrix:**
- **Embeds (G2 + the universal set) are done:** `zpwr-embed-terminal`, `zpwr-hooks-editor`,
  `zpwr-file-browser`, and the `zpwr-i18n` runtime are embedded across all 14 (terminal is N/A for
  `zterminal`, which is itself the terminal), and every app embeds its own `-core` plus the cross-cutting
  `zoffice-core` / `zemail-core` / `zpdf-core` engines.
- **Command palette (R1)** present in **5/14** (haxor, traderview, ztranslator, zpwr-daw, zpdf) — non-embed shell work.
- **Settings panel** in **4/14**; **fzf filters (R7)** in **5/14**; **sortable/resizable tables (R8)** in **5/14** — non-embed shell work.
- **Extended scripts (G4)** — **haxor + ztranslator + zpwr-daw** have the relevant set;
  traderview partial; the rest pending. (The `dev`/`build`/`nuke`/`clean`/`bust`/`rebuild`
  basics ARE ported across all 14; `scr` tracks the `test`/`doc`/`ship-check`/`deploy`/`i18n:*`
  families.) **†** zpwr-daw is JUCE, so its `scr` is the JUCE-relevant subset — `test` (ctest +
  JS), `test:js`, `ship-check`, `deploy`; `tauri:build:ci`, `cargo doc`, and `i18n:*` are **N/A**
  (no Tauri/Cargo/catalogs). ztranslator's `i18n:*` is likewise deferred until it has catalogs.
- **`zcite` and `zreq` are R1–R10 green** (R9 = N/A, no timeline content): every view surface runs
  on `zgui-core` widgets, and they embed terminal/hooks/file-browser/i18n plus the
  `zoffice`/`zemail`/`zpdf` `-core` views. Remaining for PASS: the 18 i18n proof tests
  (`i18n` = `~`) and the extended pnpm script surface (`scr`).
- **`zterminal` / `zcontainer`** now embed the universal component set + their `-core`; remaining is the
  non-embed shell surface (palette/settings/tables/header via the shared tokens) and full i18n.
  zcontainer has a cyberpunk look + logo but hand-rolled (not the shared tokens/header), and substring
  search (not fzf).
- **`?` columns** (R4 shared-token sourcing, R6 shared header, colorschemes on the newer apps) need a
  per-app audit — see Phase F. They are not counted as PASS until ticked.

---

## Phase A — Promote / converge shared sources (do ONCE, unblocks all)

These are the `GUI_APP_REQUIREMENTS.md` "known conformance gaps". Each must be a single
shared module before it can be embedded everywhere.

- [ ] **A1 Single command palette** — converge `zpwr-patch-core/webui/command-palette.js`,
  `Audio-Haxor/frontend/js/command-palette.js`, and ztranslator's inline palette into ONE
  shared module; route all apps through it (R1).
- [ ] **A2 Shared fzf matcher** — promote `zpwr-patch-core`'s `fzfMatch` to a shared module
  with one highlight style; every filter + the palette imports it (R7).
- [ ] **A3 Shared table component** — one sortable + resizable + width-persisting table; no
  hand-rolled tables (R8).
- [ ] **A4 Shared cyberpunk tokens** — extract `cyberpunk.css` design tokens so Tauri apps
  read the same theme source as the JUCE apps (R4).
- [x] **A5 File browser is shared** — `zpwr-file-browser` is the promoted multi-pane browser behind
  an fs shim (C ABI + JUCE shim), embedded across all 14 (R10).
- [ ] **A6 Tile/tab/header components** — shared tile, tab bar, and header-strip components
  (R5/R6).

---

## Phase B — Embed the universal component set in every app — DONE

Every Desktop App embeds all of these (submodule + wired + transport shim) as a real, working
embed (not just a `.gitmodules` line).

### B1 — `zpwr-embed-terminal` (R3) — DONE
- [x] all 14 (N/A for `zterminal` — it is itself the terminal).

### B2 — `zpwr-hooks-editor` (R2) — DONE
- [x] zpdf  - [x] zemail  - [x] zoffice  - [x] zreq  - [x] ztunnel  - [x] zgo
- [x] zftp  - [x] zcite  - [x] zterminal  - [x] zcontainer

### B3 — `zpwr-file-browser` (R10) — DONE
- [x] zpwr-daw  - [x] zpdf  - [x] zemail  - [x] zoffice  - [x] zreq  - [x] ztunnel
- [x] zgo  - [x] zftp  - [x] zcite  - [x] zterminal  - [x] zcontainer

### B4 — `zpwr-i18n` (G3 runtime) — DONE (localization completeness tracked in Phase D)
- [x] zcite  - [x] zterminal  - [x] zcontainer

### B5 — Command palette + fzf filters + shared table (R1/R7/R8) — after Phase A
- [ ] All 14 route filters through the shared fzf matcher (no `includes()` substring filter).
- [ ] All 14 tables use the shared sortable/resizable component.
- [ ] All 14 bind **Cmd/Ctrl+K** to open the **app-owned** command palette listing every
  command (incl. any items contributed by embeds/cores — the app decides which to surface).
  The palette is NEVER in a core/embed (see the gate's "END-APP surfaces" rule).

### B6 — Tile dashboard + tab bar + top-left logo header (R5/R6)
- [ ] All 14 land on a tile dashboard with a tab bar and the shared header (logo top-left).

### B7 — Settings panel (**Cmd/Ctrl+,**) — present in only 4
A searchable, **app-owned** settings panel bound to **Cmd/Ctrl+,** (NEVER in a core/embed;
cores only offer settings items — see the gate's "END-APP surfaces" rule). Missing in 10:
- [ ] zpdf  - [ ] zemail  - [ ] zoffice  - [ ] zreq  - [ ] ztunnel  - [ ] zgo
- [ ] zftp  - [ ] zcite  - [ ] zterminal  - [ ] zcontainer

### B8 — Colorschemes / theme switching (haxor `settings.js` theme switcher)
The family colorscheme picker (cyberpunk variants), wired through the shared tokens (A4) so a
theme change restyles every shared surface at once. Missing/unaudited in 10:
- [ ] zpdf  - [ ] zemail  - [ ] zoffice  - [ ] zreq  - [ ] ztunnel  - [ ] zgo
- [ ] zftp  - [ ] zcite  - [ ] zterminal  - [ ] zcontainer

---

## Phase C — `-core` engine embeds (G2) — DONE

Per `COMPONENTS.md` "every GUI app" plan. Each = submodule + Rust dep / C ABI + a real view.

- [x] **C1 own `-core`** wired natively **and** over the C ABI in every app that has one
  (`zcontainer-core`, `zpdf-core`, `zemail-core`, `zoffice-core`, `zreq-core`, `ztunnel-core`,
  `zgo-core`, `zcite-core`, `ztranslator-core`).
- [x] **C2 `zpdf-core`** + a PDF view in all 13 non-source apps.
- [x] **C3 `zoffice-core`** + an office view in all 13 non-source apps.
- [x] **C4 `zemail-core`** + a mail view in all 13 non-source apps.
- [x] **C5 `ztranslator-core`** in the show-control-relevant apps (haxor/traderview/daw), extracted
  from the `ztranslator` app.
- [ ] **C6 `zpwr-clip-engine` grid (R9)** + an app-specific domain in every app with
  time/sequence content (e.g. `zcontainer` → container/pod event + log timelines;
  `traderview` → trades; `zreq`/`zgo` → request/run history). Mark **N/A + reason** otherwise.
  (The clip-engine itself is embedded per `COMPONENTS.md`; this tracks the per-app grid **domain** UI.)
- [x] **C7 `zpwr-crate`** in asset apps; **N/A + reason** for non-asset apps
  (`zcontainer`, `zterminal`, `zreq`, `ztunnel`, `zgo`, `zcite`, …).

---

## Phase D — Full i18n (G3) for all 14

- [ ] **D1** The apps that embed `zpwr-i18n` actually **pass** the 18 i18n proof-contract
  tests across all 27 locales (embedding ≠ passing — verify, don't assume).
- [ ] **D2 zcite / zterminal / zcontainer**: extract every UI string to `app_i18n_en.json`, seed all 27
  locales (`cs da de el en es es_419 fi fr hi hu id it ja ko nb nl pl pt pt_br ro ru sv tr uk vi zh`),
  port the 18 `test/i18n-*.test.js`, make green.
- [ ] **D3** Every app's `i18n-no-raw-showtoast` + `i18n-ui-source` are green (no raw UI
  string can reach the screen) and wired into its CI.

---

## Phase E — Build / dev tooling parity (G4) for all 14

`dev`/`build`/`nuke`/`clean`/`bust`/`rebuild` are already ported across the 14 (the
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

Run the GUI_APP_REQUIREMENTS conformance checklist on each of the 14 and tick all ten:

- [ ] R1 palette  - [ ] R2 hooks  - [ ] R3 terminal  - [ ] R4 styles  - [ ] R5 dashboard/tabs
- [ ] R6 logo/header  - [ ] R7 fzf filters  - [ ] R8 tables  - [ ] R9 grid  - [ ] R10 file browser

A row in `COMPONENTS.md`'s consumption matrix and `GUI_POLISH_GATE.md`'s ledger flips to PASS only
when its F-checklist is fully ticked and G1–G4 are green.

---

## Suggested execution order

1. **Phase A** (shared shell sources) — unblocks the remaining R1/R7/R8/R5/R6 surfaces; one-time.
2. **Phase E** (scripts) — cheap, mechanical, parallelizable across all 14.
3. **B5–B8** (palette/fzf/table/dashboard/settings/colorschemes) — the non-embed shell surfaces.
4. **C6** (clip-engine grid domains) where time/sequence content exists.
5. **Phase D1 + Phase F** — verify and flip ledger rows to PASS.
