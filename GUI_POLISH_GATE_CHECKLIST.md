# GUI Polish Gate — Close-Out Checklist

Concrete tasks to drive all **14 Desktop Apps** to **PASS** on
[`GUI_POLISH_GATE.md`](GUI_POLISH_GATE.md) (G1–G4) and
[`GUI_APP_REQUIREMENTS.md`](GUI_APP_REQUIREMENTS.md) (R1–R10).
[`COMPONENTS.md`](COMPONENTS.md) holds the authoritative embed matrix; this is the work list.

**Roster (14, `category: 'Desktop Apps'` in `app-store/store.js`):**
`Audio-Haxor` (reference), `traderview`, `ztranslator`, `zpwr-daw`, `zpdf`, `zemail`,
`zoffice`, `zreq`, `ztunnel`, `zgo`, `zftp`, `zcite`, `zterm`, `zcontainer`.

> Order matters: **Phase A promotes the shared sources** the requirements name but that don't
> fully exist yet — until those land, embedding them everywhere (Phase B/C) is impossible.
> Do A first, then fan B–E across apps, verify F last.

---

## Status snapshot (from each app's `.gitmodules`, 2026-06-25)

| App | term | hooks | file-br | i18n | clip | own `-core` |
| --- | :--: | :--: | :--: | :--: | :--: | --- |
| Audio-Haxor | ✓ | ✓ | ✓ | ✓ | ✓ | — (app set) |
| traderview | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| ztranslator | ✓ | ✓ | ✓ | ✓ | ✓ | `ztranslator-core` (extracting) |
| zpwr-daw | ✓ | ✓ | ✗ | ✓ | ✓ | `zpwr-clip-engine` |
| zpdf | ✓ | ✗ | ✗ | ✓ | ✗ | `zpdf-core` |
| zemail | ✓ | ✗ | ✗ | ✓ | ✗ | `zemail-core` |
| zoffice | ✓ | ✗ | ✗ | ✓ | ✗ | `zoffice-core` |
| zreq | ✓ | ✗ | ✗ | ✓ | ✗ | `zreq-core` |
| ztunnel | ✓ | ✗ | ✗ | ✓ | ✗ | `ztunnel-core` |
| zgo | ✓ | ✗ | ✗ | ✓ | ✗ | `zgo-core` |
| zftp | ✓ | ✗ | ✗ | ✓ | ✗ | (app) |
| zcite | ✗ | ✗ | ✗ | ✗ | ✗ | `zcite-core` |
| zterm | ✗ | ✗ | ✗ | ✗ | ✗ | (app) |
| zcontainer | ✗ | ✗ | ✗ | ✗ | ✗ | `zcontainer-core` |

**Worst-off (nothing shared embedded): `zcite`, `zterm`, `zcontainer`.**
**Universal gaps: hooks-editor (10 apps), file-browser (11 apps).**

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
- [ ] **A5 File browser is shared** (`zpwr-file-browser` exists; confirm it's the promoted
  multi-pane browser behind an fs shim, not a haxor fork) (R10).
- [ ] **A6 Tile/tab/header components** — shared tile, tab bar, and header-strip components
  (R5/R6).

---

## Phase B — Embed the universal component set in every app

Every Desktop App MUST embed all of these (submodule + wired + transport shim). Check a box
when the app has it as a real, working embed (not just a `.gitmodules` line).

### B1 — `zpwr-embed-terminal` (R3) — missing in 3
- [ ] zcite  - [ ] zterm  - [ ] zcontainer

### B2 — `zpwr-hooks-editor` (R2) — missing in 10
- [ ] zpdf  - [ ] zemail  - [ ] zoffice  - [ ] zreq  - [ ] ztunnel  - [ ] zgo
- [ ] zftp  - [ ] zcite  - [ ] zterm  - [ ] zcontainer

### B3 — `zpwr-file-browser` (R10) — missing in 11
- [ ] zpwr-daw  - [ ] zpdf  - [ ] zemail  - [ ] zoffice  - [ ] zreq  - [ ] ztunnel
- [ ] zgo  - [ ] zftp  - [ ] zcite  - [ ] zterm  - [ ] zcontainer

### B4 — `zpwr-i18n` (G3 runtime) — missing in 3
- [ ] zcite  - [ ] zterm  - [ ] zcontainer

### B5 — Command palette + fzf filters + shared table (R1/R7/R8) — after Phase A
- [ ] All 14 route filters through the shared fzf matcher (no `includes()` substring filter).
- [ ] All 14 tables use the shared sortable/resizable component.
- [ ] All 14 open a Cmd/Ctrl+K palette listing every command.

### B6 — Tile dashboard + tab bar + top-left logo header (R5/R6)
- [ ] All 14 land on a tile dashboard with a tab bar and the shared header (logo top-left).

---

## Phase C — `-core` engine embeds (G2)

Per `COMPONENTS.md` "every GUI app" plan. Each box = submodule + Rust dep / C ABI + a real
view (placeholder view allowed only while that `-core` is itself a scaffold; track as such).

- [ ] **C1 own `-core`** wired natively **and** over the C ABI in every app that has one
  (`zcontainer-core`, `zpdf-core`, `zemail-core`, `zoffice-core`, `zreq-core`, `ztunnel-core`,
  `zgo-core`, `zcite-core`, `ztranslator-core`).
- [ ] **C2 `zpdf-core`** + a PDF view in all 13 non-source apps.
- [ ] **C3 `zoffice-core`** + an office view in all 13 non-source apps.
- [ ] **C4 `zemail-core`** + a mail view in all 13 non-source apps.
- [ ] **C5 `ztranslator-core`** in show-control-relevant apps (currently haxor/traderview/daw;
  finish the extraction from the `ztranslator` app first).
- [ ] **C6 `zpwr-clip-engine` grid (R9)** + an app-specific domain in every app with
  time/sequence content (e.g. `zcontainer` → container/pod event + log timelines;
  `traderview` → trades; `zreq`/`zgo` → request/run history). Mark **N/A + reason** otherwise.
- [ ] **C7 `zpwr-crate`** in asset apps only; **N/A + reason** for non-asset apps
  (`zcontainer`, `zterm`, `zreq`, `ztunnel`, `zgo`, `zcite`, …).

---

## Phase D — Full i18n (G3) for all 14

- [ ] **D1** The 11 apps that embed `zpwr-i18n` actually **pass** the 18 i18n proof-contract
  tests across all 27 locales (embedding ≠ passing — verify, don't assume).
- [ ] **D2 zcite / zterm / zcontainer**: adopt `zpwr-i18n`, extract every UI string to
  `app_i18n_en.json`, seed all 27 locales (`cs da de el en es es_419 fi fr hi hu id it ja ko
  nb nl pl pt pt_br ro ru sv tr uk vi zh`), port the 18 `test/i18n-*.test.js`, make green.
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

A row in `COMPONENTS.md`'s "Target state" and `GUI_POLISH_GATE.md`'s ledger flips to PASS only
when its F-checklist is fully ticked and G1–G4 are green.

---

## Suggested execution order

1. **Phase A** (shared sources) — unblocks everything; one-time.
2. **B1 + B4 + D2** for `zcite`/`zterm`/`zcontainer` — the three worst-off apps reach the same
   floor as the rest (terminal + i18n).
3. **B2 (hooks) + B3 (file-browser)** fan-out — the two biggest universal gaps.
4. **Phase E** (scripts) — cheap, mechanical, parallelizable across all 14.
5. **Phase C** (`-core` views) — heaviest; gated on each `-core` maturing.
6. **Phase D1 + Phase F** — verify and flip ledger rows to PASS.
