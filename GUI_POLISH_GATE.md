# MenkeTechnologies — GUI Polish Gate

The pass/fail bar a desktop GUI app must clear before it counts as **done**. Where
[`GUI_APP_REQUIREMENTS.md`](GUI_APP_REQUIREMENTS.md) defines *what shared behaviour* an app
must have (R1–R10) and [`COMPONENTS.md`](COMPONENTS.md) maps *which embeds* each app
consumes, this gate is the **acceptance test over both**, plus the rules that every app is
fully localized and built with the same tooling. A new app (e.g. `zcontainer`) is not
"shipped" until it is green here.

This is a gate, not advice. An app is **PASS** only when all four pillars below are PASS.
A single unported-but-relevant haxor surface, a single missing relevant embed, a single raw
user-facing string, or a single missing haxor pnpm script is a **FAIL**.

_Reference app: **Audio-Haxor** — the most complete GUI app; it is the source of truth for
"what a finished app looks like." Everything in haxor that is relevant to another app must
exist in that app._

---

## The four pillars

### G1 — Haxor parity (port everything relevant)

Every capability that exists in Audio-Haxor must exist in the app **if it is relevant**
(see the relevance rubric). Parity is judged surface-by-surface against haxor's
`frontend/js/*` and its R1–R10 conformance, not by vibes.

**Universally relevant (every GUI app MUST have these — never app-specific):**

| Surface | Canonical source | R# |
| --- | --- | --- |
| Command palette — **Cmd/Ctrl+K**, fzf-matched (app-owned, see below) | end-app shell | R1 / R7 |
| Stryke Hooks editor (Monaco) | `zpwr-hooks-editor` | R2 |
| Embedded PTY terminal (Ctrl+\` / Cmd+T) | `zpwr-embed-terminal` | R3 |
| Cyberpunk tokens (`Orbitron` + `Share Tech Mono`, glass surfaces) | `zpwr-patch-core/.../cyberpunk.css` | R4 |
| Tile dashboard + tab bar | shared tile/tab components | R5 |
| Logo top-left, shared header strip | shared header | R6 |
| Fuzzy filters with matched-char highlight | shared fzf matcher | R7 |
| Sortable + resizable tables | shared table component | R8 |
| Multi-pane file browser | shared file-browser module | R10 |
| Settings panel — **Cmd/Ctrl+,**, searchable (app-owned, see below) | end-app shell | — |
| Colorscheme / theme switcher (cyberpunk variants) | haxor `settings.js` theme switch + R4 tokens | R4 |
| Context menu, keyboard navigation, help overlay (`?`), drag-reorder, batch-select, multi-filter, history, favorites | haxor `frontend/js/*` → promote to shared | — |
| Full i18n (see G3) | `zpwr-i18n` | — |

#### Command palette & settings are END-APP surfaces (never in a core/embed)

A load-bearing architecture rule, not a style note:

- **The command palette and the settings panel live in the end GUI app (the shell).** They are
  **NEVER** built into an embed module or a `-core` engine. A core's job is its domain
  (containers, fs, midi, …) — it has no palette and no settings UI of its own.
- **Cores and embeds may only OFFER items**, never render the surface: an embed *contributes*
  command entries and settings entries to the host (a contribution API — e.g. the engine
  returns its commands/settings descriptors, or registers them through a host hook). **The end
  app decides** whether to surface each contributed item. Offering ≠ showing.
- **Shortcuts are mandatory in every app:** **Cmd/Ctrl+K** opens the command palette,
  **Cmd/Ctrl+,** opens settings. Bound by the app shell, reachable from anywhere in the app.
- Practically: `zcontainer-core`, `zpwr-file-browser`, `zpwr-embed-terminal`, etc. must **not**
  ship a palette or a settings window. If a core wants its action in the palette, it exposes a
  descriptor list; the `zcontainer` / `Audio-Haxor` / … shell binds the shortcut, renders the
  surface, and includes (or omits) the core's offered items.

**Domain-relevant (port only where the content fits):**

| Surface | Relevant to | Not relevant to |
| --- | --- | --- |
| Arrangement grid (`zpwr-clip-engine` `createGrid` + a domain) — R9 | any time/sequence-ordered data | a purely tabular app, **if** it has no timeline content |
| Sample/content crate browser (`zpwr-crate`) | audio/asset apps | non-asset apps (e.g. `zcontainer`) |
| Audio engine / ALS generation / genre rules / MIDI / KVR | audio apps only | everything non-audio |
| `ztranslator` view (MIDI/OSC/DMX/Link) | show-control apps | non-show-control apps |

> Domain-relevant surfaces that are **not** relevant must be recorded as "N/A — <reason>"
> in the app's ledger row. Silence is treated as an un-ported FAIL, not as N/A.

### G2 — Core / embed completeness (all relevant engines in the app)

Every `-core` engine and shared component submodule **relevant** to the app must be a real
submodule of the app and actually wired (Rust dep / C ABI + a live view or shim), per the
`-core` embed pattern in `COMPONENTS.md`. Source of truth is the app's `.gitmodules`.

**Every GUI app MUST embed (the standard set):**

- Its **own `-core` engine** (e.g. `zcontainer` ⇒ `zcontainer-core`), embedded both natively
  and behind the C ABI.
- `zpwr-embed-terminal`, `zpwr-hooks-editor`, `zpwr-file-browser`, `zpwr-i18n` — the universal
  component submodules (R2/R3/R10 + G3).
- The paid cross-cutting engines per the `COMPONENTS.md` "every GUI app" plan: **`zoffice-core`,
  `zemail-core`, `zpdf-core`** — each with a real view (placeholder views are allowed only
  while the engine itself is still a scaffold, and must be tracked as such).

**Embed only where relevant:** `zpwr-clip-engine` (R9 grid — only if the app has timeline
content), `zpwr-crate` (asset apps), `ztranslator-core` (show-control apps).

A relevant engine that is "planned" but not a submodule yet is a **FAIL** (it just hasn't
been ported), the same way a missing R-item is.

### G3 — Full i18n (no raw user-facing strings)

Every user-facing string in every surface routes through `zpwr-i18n` by key, localized across
**all 27 catalog locales** (`cs da de el en es es_419 fi fr hi hu id it ja ko nb nl pl pt
pt_br ro ru sv tr uk vi zh`). No literal label, toast, tooltip, menu item, table header,
empty-state, or error string in the UI. The enforcement is haxor's **i18n proof-contract test
suite** (18 tests), ported verbatim into the app and green in CI:

`i18n-anchor-keys`, `i18n-batch-parity`, `i18n-catalog-files`, `i18n-forbidden-html`,
`i18n-html-injection-guard`, `i18n-html-keys`, `i18n-js-keys`, `i18n-locales-and-shape`,
`i18n-no-empty-placeholders`, `i18n-no-raw-showtoast`, `i18n-per-key-placeholder-parity`,
`i18n-placeholders`, `i18n-proof-contract`, `i18n-prove-all-locales-complete`,
`i18n-seed-parity`, `i18n-ui-source`, `i18n-unmatched-braces`, `i18n-value-safety`.

`i18n-no-raw-showtoast` + `i18n-ui-source` are the load-bearing pair: they fail the build on
any raw string reaching the UI, so G3 cannot regress silently. The English catalog
(`app_i18n_en.json`) is the seed; `i18n-prove-all-locales-complete` blocks any locale that is
missing a key or has an empty value.

### G4 — Build / dev tooling parity (all haxor pnpm scripts)

Every app exposes the **same `package.json` script surface** as Audio-Haxor, so any app is
driven with identical muscle memory: `pnpm dev`, `pnpm build`, `pnpm nuke`, and the rest
behave the same everywhere. Port haxor's scripts (relevant ones), not a per-app subset.

**Lifecycle (every app MUST have, verbatim semantics):**

| Script | Does |
| --- | --- |
| `tauri` | passthrough to the Tauri CLI |
| `dev` / `tauri:dev` | `tauri dev` |
| `build` / `tauri:build` | `tauri build` (+ any postbundle step) |
| `tauri:build:ci` | `tauri build --ci --no-sign` |
| `clean` | `bash scripts/clean.sh` |
| `bust` | `bash scripts/bust.sh` |
| `rebuild` | `bash scripts/rebuild.sh` |
| `nuke` | `bash scripts/nuke.sh` |
| `ship-check` | `bash scripts/ship-check.sh` |
| `deploy` | `bash scripts/deploy.sh` |

**Test surface (MUST, scoped to the app's subsystems):**

| Script | Does |
| --- | --- |
| `test` | `bash scripts/test.sh` (runs the lot) |
| `test:js` | `node scripts/run-js-tests.mjs` |
| `test:rust` | `cargo test --manifest-path <app>/src-tauri/Cargo.toml` |
| `test:<engine>` | per embedded engine (haxor: `test:audio-engine`) |

**Docs (MUST):** `doc`, `doc:open`, `doc:sync` (`cargo doc` + sync into `docs/api`).

**i18n tooling (MUST — pairs with G3):** `i18n:sort`, `i18n:sort:check`, `i18n:audit` —
catalog sort + completeness audit. Haxor implements these in `python3`; new apps **MUST**
implement them in `node`/stryke instead (house rule: no Python).

**DB tooling (relevant only if the app has a SQLite store):** `db:vacuum`, `db:stats`.
`build:<thing>` build steps (haxor: `build:hooks-editor`) are required for each shared
bundle the app vendors.

The `scripts/` shell files (`clean.sh`, `bust.sh`, `rebuild.sh`, `nuke.sh`, `ship-check.sh`,
`deploy.sh`, `test.sh`) are themselves part of the port — same names, same behaviour, adapted
to the app's identifier/caches. A script that exists in haxor and is relevant but missing
here is a **FAIL**, same as a missing R-item.

---

## Relevance rubric

A haxor surface or embed is **relevant** to an app unless it is intrinsically tied to a
content domain the app does not have. Decision order:

1. **Is it chrome / cross-cutting UX?** (palette, terminal, hooks, filters, tables, dashboard,
   header, context menu, keyboard nav, help, i18n, file browser, office/mail/pdf views) →
   **always relevant.** Port it.
2. **Is it tied to a content domain?** (audio engine, sample crate, ALS, MIDI, show-control) →
   relevant only if the app owns that domain. Otherwise **N/A with a one-line reason** in the
   ledger.
3. **Unsure?** Default to relevant. The family bet is "open any app, everything works the
   same"; under-porting breaks that, over-porting at most adds a view nobody opens.

## Gate verdict

```
PASS  ⇔  G1 (all relevant haxor surfaces ported)
      ∧  G2 (all relevant -core/embeds wired)
      ∧  G3 (18 i18n proof tests green across all 27 locales)
      ∧  G4 (all relevant haxor pnpm scripts + scripts/ ported)
      ∧  R1–R10 conformance (GUI_APP_REQUIREMENTS.md)
```

Anything less is **FAIL**, recorded with the specific missing items. "Mostly there" is FAIL.

---

## Per-app gate ledger

Verdict per app. `✓` pillar green, `partial` some items, `✗` not started, `N/A` not relevant.
`COMPONENTS.md` holds the authoritative embed matrix; this is the polish roll-up. The
task-by-task work list to close every gap is [`GUI_POLISH_GATE_CHECKLIST.md`](GUI_POLISH_GATE_CHECKLIST.md).

| App | G1 haxor parity | G2 core/embeds | G3 i18n (27 locales) | G4 pnpm scripts | Verdict |
| --- | --- | --- | --- | --- | --- |
| **Audio-Haxor** (reference) | ✓ | ✓ | ✓ | ✓ | PASS |
| **traderview** | partial | ✓ | ✓ | partial | FAIL |
| **ztranslator** | partial | ✓ | ✓ | partial | FAIL |
| **zpwr-daw** | partial | ✓ | ✗ | partial | FAIL |
| **zcontainer** | ✗ | partial (`zcontainer-core` only) | ✗ | partial (dev/build/clean/bust/rebuild/nuke only) | FAIL |
| **zcite** | partial (R1–R10 ✓; R9 N/A — no timeline) | ✓ (terminal/hooks/file-browser/i18n + office/mail/pdf-core) | partial (935-key seed across 27 locales; 18 proof tests not ported, locales are English stubs) | partial (dev/build/test/doc/ship-check/deploy/nuke/build:hooks-editor) | FAIL |
| **zreq** | partial (R1–R10 ✓; R9 N/A — no timeline) | ✓ (terminal/hooks/file-browser/i18n + office/mail/pdf-core) | partial (935-key seed across 27 locales; 18 proof tests not ported, locales are English stubs) | partial (dev/build/nuke/build:hooks-editor) | FAIL |

### zcite / zreq — newly onboarded (R1–R10 green)

Both apps now mount the `ZGui.appShell` baseline and route **every** view surface through
`zgui-core` widgets — tables (`ZGui.dataTable`/`table`), fuzzy filters (`ZGui.fzf` +
matched-char highlight), modals (`ZGui.modal`), toasts (`ZGui.toast`), tab strips
(`ZGui.tabs`, now multi-instance), the collection tree (`ZGui.tree`), and a tile dashboard
(`ZGui.tiles`). They embed the shared PTY terminal, the Monaco hooks editor, and the
multi-pane file browser (with a real Rust `fs_*` backend). R9 (arrangement grid) is **N/A** —
neither a reference manager nor an HTTP client has timeline content.

To reach **PASS** each still owes the gate:
- **G2**: add `zoffice-core` / `zemail-core` / `zpdf-core` with real views (the paid
  cross-cutting engine set).
- **G3**: port the 18 i18n proof tests and make them green; the 935-key catalog is complete
  across all 27 locales but non-English values are English stubs pending machine translation.
- **G4**: fill out the haxor `package.json` script surface + matching `scripts/*.sh`
  (`tauri:build:ci`, `clean`/`bust`/`rebuild`, `test`/`test:js`/`test:rust`,
  `doc`/`doc:open`/`doc:sync`, `i18n:sort`/`i18n:sort:check`/`i18n:audit` in node).

### zcontainer — what it owes the gate

`zcontainer` currently embeds only `zcontainer-core` and ships a bespoke Docker/Kubernetes
UI. To reach PASS it must port the haxor family chrome onto its existing layout and localize
everything:

- **G1**: command palette (R1) over its commands; embedded terminal (R3) — already has an
  exec terminal, replace with `zpwr-embed-terminal`; hooks editor (R2); shared cyberpunk
  tokens (R4) — the current skin is hand-rolled, move to `cyberpunk.css` tokens; tile
  dashboard + tab bar (R5); shared header/logo (R6); fzf filters with highlight (R7) — the
  current search is substring; sortable + resizable tables (R8) — the current resource table
  is neither; file browser (R10); context menu, keyboard nav, help overlay.
- **G2**: add submodules `zpwr-embed-terminal`, `zpwr-hooks-editor`, `zpwr-file-browser`,
  `zpwr-i18n`, plus `zoffice-core` / `zemail-core` / `zpdf-core` with views. Arrangement grid
  (R9) is relevant — container/pod events and log timelines fit `createGrid` with a new
  domain; `zpwr-crate` and `ztranslator-core` are **N/A** (no audio/show-control domain).
- **G3**: adopt `zpwr-i18n`, extract every string in `webui/*` to `app_i18n_en.json`, seed all
  27 locales, port the 18 i18n proof tests, and make them green.
- **G4**: it already has `dev`/`build`/`tauri`/`clean`/`bust`/`rebuild`/`nuke`; add the rest of
  the haxor surface — `tauri:build:ci`, `ship-check`, `deploy`, `test` + `test:js` + `test:rust`,
  `doc`/`doc:open`/`doc:sync`, and `i18n:sort`/`i18n:sort:check`/`i18n:audit` (in node, not
  Python) — plus the matching `scripts/*.sh` (`ship-check.sh`, `deploy.sh`, `test.sh`).
  `db:*` is N/A unless a SQLite store is added.

Until these land, `zcontainer` is **FAIL** — a faithful Docker Desktop + Lens port, but not
yet a polished member of the GUI family.
