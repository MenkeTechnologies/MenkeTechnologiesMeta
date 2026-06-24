```
 ███╗   ███╗███████╗████████╗ █████╗
 ████╗ ████║██╔════╝╚══██╔══╝██╔══██╗
 ██╔████╔██║█████╗     ██║   ███████║
 ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║
 ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║
 ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
```

[![Submodules](https://img.shields.io/badge/submodules-113-blue.svg)](#0x01-submodule-map)
[![Tier 1](https://img.shields.io/badge/tier_1-24_core-cyan.svg)](#tier-1--core-24)
[![Tier 2](https://img.shields.io/badge/tier_2-32_stryke%2Btap-green.svg)](#tier-2--stryke-ecosystem--tap-32)
[![Tier 3](https://img.shields.io/badge/tier_3-1_completions-magenta.svg)](#tier-3--zsh-more-completions-1)
[![Tier 4](https://img.shields.io/badge/tier_4-28_zsh_plugins-yellow.svg)](#tier-4--zsh-ecosystem-plugins-28)
[![Tier 5](https://img.shields.io/badge/tier_5-11_editor%20%2F%20tmux-purple.svg)](#tier-5--editor--multiplexer-plugins-11)
[![Tier 6](https://img.shields.io/badge/tier_6-17_apps_+_web%20+%20APIs-orange.svg)](#tier-6--apps-extensions-web--web-apis-17)
[![Rust](https://img.shields.io/badge/rust-2.36M_LOC-orange.svg)](#0x09-code-volume)
[![Code](https://img.shields.io/badge/code-8.14M_lines-brightgreen.svg)](#0x09-code-volume)
[![Website](https://img.shields.io/badge/website-menketechnologies.github.io-blue.svg)](https://menketechnologies.github.io/)
[![App Store](https://img.shields.io/badge/app_store-storefront-red.svg)](https://menketechnologies.github.io/app-store/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### `[META REPO // 113 SUBMODULES // ONE COMMAND, EVERY MENKETECHNOLOGIES PROJECT]`

> *"One repo to rule them all, one repo to fetch them, one repo to bring them all, and on every host bind them."*

**MenkeTechnologiesMeta** is a single umbrella repo that vendors every active [MenkeTechnologies](https://github.com/MenkeTechnologies) project as a git submodule. Clone once with `--recurse-submodules` and a fresh host has the entire stack: `strykelang` (the language), `zshrs` (the shell), `fusevm` (the bytecode VM), `lsofrs` / `awkrs` / `temprs` / `nmaprs` / `powerliners` (the Rust CLI tools), `iftoprs` / `storageshower` (TUIs), `zpwr-jobs` (the job-application pipeline CLI), `Audio-Haxor` / `traderview` (Tauri v2 desktop GUI apps), `ztranslator` (the real-time MIDI/OSC/DMX event-translation desktop app + embeddable routing engine), `zpwr-synth` / `zpwr-fx` / `zpwr-midi-fx` / `zpwr-daw` (the four JUCE patch-graph audio plugins — three perform plugins plus the FL-style DAW, every track a patch graph of blocks) + `zpwr-patch-core` (their shared signal-agnostic patch graph) + `zpwr-crate` (the shared Rust sample-library crate browser behind `Audio-Haxor` and `zpwr-daw`) + `zpwr-embed-terminal` (the shared PTY terminal vendored into the desktop apps) + `zpwr-file-browser` (the shared multi-pane file browser — JS front end + Rust `fs` crate) + `zpwr-hooks-editor` (their shared stryke Hooks code editor) + `zpwr-i18n` (the shared portable i18n runtime) + `zpwr-clip-engine` (the shared JS arranger/sequencer frontend extracted from `zpwr-daw`) + `zpwr-algo-production` (the algorithmic music-production engine behind `zpwr-daw`'s one-click track generation) + `app-store` (the storefront) + `MenkeTechnologiesPublications` (the private paid books / reference manuals / zpwr encyclopedia + their build pipeline), `zpwr` (the terminal OS), the 31-repo stryke ecosystem (`stryke-aws`, `stryke-azure`, `stryke-clickhouse`, `stryke-scylla`, `stryke-search`, `stryke-gcp`, `stryke-k8s`, `stryke-kafka`, `stryke-zmq`, `stryke-gui`, `stryke-polars`, `stryke-utils`, ...), the 28-repo zsh plugin family (`zsh-more-completions`, `zsh-expand`, `zsh-cargo-completion`, `fzf-tab`, `revolver`, `zunit`, ...), editor / multiplexer plugins (`VimColorSchemes`, `vim-stryke`, `vscode-stryke`, `emacs-stryke`, `vim-zsh`, `vscode-zsh`, `emacs-zsh`, `vscode-awk`, `vim-awk`, `emacs-awk`, `tmux-fzf-url`), the cyberpunk editor theme (`zpwr-theme` — VS Code + JetBrains), the Chrome extension (`zpwrchrome`), the public website (`MenkeTechnologies.github.io`), and the web-API services `api-rest-generator` and `LearningCollectionAPI`.

### [`MenkeTechnologies on GitHub`](https://github.com/MenkeTechnologies) &middot; [`strykelang`](https://github.com/MenkeTechnologies/strykelang) · [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

---

## Table of Contents

- [\[0x00\] Quick Start](#0x00-quick-start)
- [\[0x01\] Submodule Map](#0x01-submodule-map)
  - [Tier 1 — Core (24)](#tier-1--core-24)
  - [Tier 2 — Stryke ecosystem + tap (32)](#tier-2--stryke-ecosystem--tap-32)
  - [Tier 3 — zsh-more-completions (1)](#tier-3--zsh-more-completions-1)
  - [Tier 4 — Zsh ecosystem plugins (28)](#tier-4--zsh-ecosystem-plugins-28)
  - [Tier 5 — Editor / multiplexer plugins (11)](#tier-5--editor--multiplexer-plugins-11)
  - [Tier 6 — Apps, extensions, web & web-APIs (16)](#tier-6--apps-extensions-web--web-apis-16)
- [\[0x02\] CI Status Board](#0x02-ci-status-board)
- [\[0x03\] Common Operations](#0x03-common-operations)
- [\[0x04\] Helper Scripts](#0x04-helper-scripts)
- [\[0x05\] Updating Submodule Pointers](#0x05-updating-submodule-pointers)
- [\[0x06\] Per-Host Setup](#0x06-per-host-setup)
- [\[0x07\] Working Inside a Submodule](#0x07-working-inside-a-submodule)
- [\[0x08\] Disk Footprint](#0x08-disk-footprint)
- [\[0x09\] Code Volume](#0x09-code-volume)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] QUICK START

**Fresh host — clone everything in one shot:**

```bash
git clone --recurse-submodules https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta
```

The `--recurse-submodules` flag fetches all 113 submodules in parallel during the initial clone.

**Already cloned without `--recurse-submodules`? Add them after the fact:**

```bash
git submodule update --init --recursive
```

**Faster initial clone (parallel jobs):**

```bash
git clone --recurse-submodules -j 8 https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
```

`-j 8` clones up to 8 submodules concurrently. Bump higher on fast networks.

---

## [0x01] SUBMODULE MAP

All 113 submodules sit flat at the repository root. URLs are HTTPS for fresh-host portability (no SSH key needed for `clone --recurse`).

### Tier 1 — Core (24)

The set of MenkeTechnologies projects that share the unified `strykelang`-authored documentation template (README header, ToC convention `[0xNN]`, `docs/index.html` chrome, `docs/report.html` engineering report, `man/man1/<name>.1` + `<name>all.1` man pages).

| Project | What it is |
|---|---|
| [`strykelang`](https://github.com/MenkeTechnologies/strykelang) | The fastest dynamic language for parallel ops. Perl 5 compatible interpreter in Rust, bytecode VM + Cranelift JIT, 10,450 builtins. &middot; <sub>[docs](https://menketechnologies.github.io/strykelang/) · [report](https://menketechnologies.github.io/strykelang/report.html) · [reference](https://menketechnologies.github.io/strykelang/reference.html)</sub> |
| [`zshrs`](https://github.com/MenkeTechnologies/zshrs) | The first compiled Unix shell. 1:1 zsh C-port + extensions, persistent worker pool, AOP intercept, rkyv bytecode cache. &middot; <sub>[docs](https://menketechnologies.github.io/zshrs/) · [report](https://menketechnologies.github.io/zshrs/report.html) · [reference](https://menketechnologies.github.io/zshrs/reference.html)</sub> |
| [`fusevm`](https://github.com/MenkeTechnologies/fusevm) | Language-agnostic bytecode VM with fused superinstructions and 3-tier Cranelift JIT. The execution engine behind strykelang, zshrs, awkrs. &middot; <sub>[docs](https://menketechnologies.github.io/fusevm/) · [report](https://menketechnologies.github.io/fusevm/report.html)</sub> |
| [`lsofrs`](https://github.com/MenkeTechnologies/lsofrs) | Rust rewrite of `lsof` — 5–21× faster, **7-tab TUI** (ratatui), 31 cyberpunk themes. &middot; <sub>[docs](https://menketechnologies.github.io/lsofrs/) · [report](https://menketechnologies.github.io/lsofrs/report.html)</sub> |
| [`temprs`](https://github.com/MenkeTechnologies/temprs) | Temporary file stack manager. Atomic `flock`-protected master record, dual indexing (position or `@name`). &middot; <sub>[docs](https://menketechnologies.github.io/temprs/) · [report](https://menketechnologies.github.io/temprs/report.html)</sub> |
| [`awkrs`](https://github.com/MenkeTechnologies/awkrs) | AWK in Rust. Bytecode VM + Cranelift JIT + persistent rkyv bytecode cache + parallel records. LSP + DAP servers (`awkrs --lsp` / `--dap`) in progress; editor plugins `vscode-awk` / `vim-awk` / `emacs-awk`. &middot; <sub>[docs](https://menketechnologies.github.io/awkrs/) · [report](https://menketechnologies.github.io/awkrs/report.html)</sub> |
| [`iftoprs`](https://github.com/MenkeTechnologies/iftoprs) | Real-time bandwidth monitor. **TUI** built on ratatui, 31 themes, process attribution via `lsof`, NDJSON streaming. &middot; <sub>[docs](https://menketechnologies.github.io/iftoprs/) · [report](https://menketechnologies.github.io/iftoprs/report.html)</sub> |
| [`ztranslator`](https://github.com/MenkeTechnologies/ztranslator) | **Real-time event-translation desktop app** in pure Rust — also embeddable as the routing engine inside other apps. Watches MIDI input ports (`midir`), OSC, DMX, and the file system for triggers, matches each event against per-translator rules on a signed-32-bit integer VM (faithful BOME rules: arithmetic + bitwise, `IF/THEN`, `Goto`/`Skip`, 10 locals + globals, wrap-on-overflow), and fires an outgoing action — MIDI / OSC / DMX out, keystroke / mouse / AppleScript (macOS `CGEvent`), timer, or host-defined custom command. Built-in auto-update. Imports and exports BOME MIDI Translator Pro `.bmtp` projects (lossless, unsigned export round-trips through import) and stores native projects as JSON. Ships its own GUI; the same engine drops into a host GUI/CLI app. **Paid product** — docs vendored locally. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/ztranslator) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/ztranslator/report)</sub> |
| [`Audio-Haxor`](https://github.com/MenkeTechnologies/Audio-Haxor) | **Tauri v2 desktop GUI app** + JUCE engine. VST2/VST3/AU/CLAP scanner, sample vault, DAW project index, KVR version checker. **Paid product** — docs vendored locally. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/Audio-Haxor) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/Audio-Haxor/report)</sub> |
| [`traderview`](https://github.com/MenkeTechnologies/traderview) | **Tauri v2 desktop GUI app** (sibling to Audio-Haxor) — TraderVue-style trading journal with embedded Postgres, vanilla JS + uPlot frontend. The same Rust workspace crates also ship a multi-user axum web service. **Paid product** — docs vendored locally. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/traderview) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/traderview/report)</sub> |
| [`zpwr-daw`](https://github.com/MenkeTechnologies/zpwr-daw) | **DAW arranger + the 4th patch-graph plugin** (standalone app, VST3/AU/CLAP, and embeddable library) — one generalized grid engine over notes / arrangement / automation / trigger domains, with Arrangement & Session views, a swung step clock, MIDI/JSON export, and a JUCE-free C++ core exposing a C ABI + Rust bindings. Every track is a patch graph of `zpwr-patch-core` blocks (178 note-stream modules + the shared audio pack). Powers the CLIP tab in the JUCE plugins and the timelines in `ztranslator` / `Audio-Haxor`. **Private** — docs vendored to meta. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-daw/report)</sub> |
| [`zpwr-crate`](https://github.com/MenkeTechnologies/zpwr-crate) | **Shared sample-library "crate" browser** (Rust) — one source of truth for the audio stack's filesystem + SQLite/FTS5 sample scanner and faceted crate-query layer (category/pack/manufacturer/BPM/key filters, regex search, facets, incremental rescans). Scanner + schema + query code lifted verbatim from the Audio-Haxor backend with the Tauri glue stripped. Builds `rlib` + `staticlib` + `cdylib`: consumed natively by `Audio-Haxor` and over a C ABI by `zpwr-daw`, so both run identical indexing/browsing against the same schema. **Private** — internal shared library, not published to crates.io. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-crate) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-crate/report)</sub> |
| [`zpwr-embed-terminal`](https://github.com/MenkeTechnologies/zpwr-embed-terminal) | **Shared embedded PTY terminal** (Rust) — one PTY-backed login-shell terminal (`portable-pty` core + xterm.js front end) extracted from Audio-Haxor so a single source of truth backs every desktop app. Builds `rlib` + `staticlib` + `cdylib`: `Audio-Haxor` / `traderview` / `ztranslator` use it natively (forwarding `on_output`/`on_exit` to `app.emit`), `zpwr-daw` drives it over the C ABI (`include/zpwr_embed_terminal.h`) from JUCE/C++. **Private** — internal shared library, not published to crates.io. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-embed-terminal) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-embed-terminal/report)</sub> |
| [`zpwr-file-browser`](https://github.com/MenkeTechnologies/zpwr-file-browser) | **Shared multi-pane file browser** (JS front end + Rust `fs` crate) — one source of truth for the file browser across every desktop app, extracted from Audio-Haxor. Host-agnostic front end (`webui/file-browser.{js,css,html}`): multi-pane layout, sortable + resizable columns, fuzzy filter, color labels, tree sidebar, context menu, previews (audio waveform/key/bpm, image/video thumbs, pdf, exif, git status, dedup, diff, grep). Each host supplies the filesystem backend (the `window.vstUpdater` fs-command contract) — `Audio-Haxor` / `traderview` / `ztranslator` as `#[tauri::command]`s, `zpwr-daw` over a C ABI like `zpwr-embed-terminal`. Ships `crate/` — the shared Rust `fs_*` backend (core filesystem ops ported verbatim from the Audio-Haxor `src-tauri` layer with the Tauri glue stripped to pure functions). **Private** — internal shared library. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-file-browser) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-file-browser/report)</sub> |
| [`zpwr-algo-production`](https://github.com/MenkeTechnologies/zpwr-algo-production) | **Algorithmic music-production engine** (Rust) — one action generates a complete, professionally-arranged track: song structure + key/tempo, per-section MIDI, and an exported Ableton Live Set (`.als`), with genre engines (trance, …). Ported from the Audio-Haxor `src-tauri` generators with the library-scanner couplings abstracted behind a host-provided sample source. Powers `zpwr-daw`'s one-click production (INVENTIONS #5). **Private** — docs vendored to meta. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-algo-production) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-algo-production/report)</sub> |
| [`nmaprs`](https://github.com/MenkeTechnologies/nmaprs) | Rust port of `nmap`. Full async TCP/UDP/SCTP/IP-protocol scans, idle/zombie scans, NSE-style script probes, ARP/ICMP/timestamp/mask host discovery, top-ports list embedded. &middot; <sub>[docs](https://menketechnologies.github.io/nmaprs/) · [report](https://menketechnologies.github.io/nmaprs/report.html)</sub> |
| [`powerliners`](https://github.com/MenkeTechnologies/powerliners) | **Rust CLI** — mature port of Python's [`powerline-status`](https://github.com/powerline/powerline) (v0.2.15, 3,000+ `#[test]` functions, 5-binary suite: `powerline` / `powerline-daemon` / `powerline-config` / `powerline-render` / `powerline-lint`, parity-tested against upstream Python). Drop-in for tmux / zsh / bash / vim with sub-millisecond render replacing the ~100 ms python startup tax. &middot; <sub>[docs](https://menketechnologies.github.io/powerliners/) · [report](https://menketechnologies.github.io/powerliners/report.html)</sub> |
| [`zpwr`](https://github.com/MenkeTechnologies/zpwr) | The terminal OS. 504 verbs, 190k LOC, zinit-based, stryke-powered. ⭐ 220 &middot; <sub>[docs](https://menketechnologies.github.io/zpwr/) · [report](https://menketechnologies.github.io/zpwr/report.html)</sub> |
| [`zpdf`](https://github.com/MenkeTechnologies/zpdf) | **PDF editor replacing Adobe Acrobat + Preview** (Rust, Tauri v2 desktop app) — full document editing, annotation/markup, AcroForms, digital & certificate signatures, OCR, redaction, page management, convert/export. Consumes `zpdf-core`. **Paid product** — in the app-store. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpdf) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpdf/report)</sub> |
| [`zpdf-core`](https://github.com/MenkeTechnologies/zpdf-core) | **Embeddable PDF engine** (pure Rust, no GUI deps) — parse / render / edit / annotate / sign / page-ops behind `zpdf`; builds `rlib` + `staticlib` + `cdylib` so it embeds into `traderview` and the other GUI apps (same pattern as `zpwr-embed-terminal`). Ships a source-derived feature port report. **Private.** &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpdf-core) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpdf-core/report)</sub> |
| [`zemail`](https://github.com/MenkeTechnologies/zemail) | **Email client** (Rust, Tauri v2 desktop app) — a fast, owned desktop mail app behind a cyberpunk HUD. Consumes `zemail-core`. **Paid product** — in the app-store. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zemail) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zemail/report)</sub> |
| [`zemail-core`](https://github.com/MenkeTechnologies/zemail-core) | **Embeddable mail engine** (pure Rust, no GUI deps) extracted from `zemail` so the same engine embeds across the GUI stack. **Private.** &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zemail-core) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zemail-core/report)</sub> |
| [`zoffice`](https://github.com/MenkeTechnologies/zoffice) | **Office suite replacing Microsoft Office** (Rust, Tauri v2 desktop app) — documents, spreadsheets, presentations. Consumes `zoffice-core`. **Paid product** — in the app-store. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zoffice) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zoffice/report)</sub> |
| [`zoffice-core`](https://github.com/MenkeTechnologies/zoffice-core) | **Embeddable office engine** (pure Rust, no GUI deps) — document / spreadsheet / presentation parse + edit, extracted from `zoffice`. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zoffice-core) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zoffice-core/report)</sub> |

### Tier 2 — Stryke ecosystem + tap (32)

MenkeTechnologies distribution (single tap for every CLI tool) + per-service connector libraries for `stryke`.

| Project | What it is |
|---|---|
| [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) | Single Homebrew tap for 11 MenkeTechnologies CLI formulas (`awkrs` / `iftoprs` / `lsofrs` / `nmaprs` / `powerliners` / `storageshower` / `stryke` / `temprs` / `zpwrchrome-host` / `zshrs` / `zshrs-all`). Formulas auto-bumped by each tool's `Release` workflow via `HOMEBREW_TAP_TOKEN`. |
| [`stryke-arrow`](https://github.com/MenkeTechnologies/stryke-arrow) | Apache Arrow integration. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-arrow/) · [report](https://menketechnologies.github.io/stryke-arrow/report.html)</sub> |
| [`stryke-aws`](https://github.com/MenkeTechnologies/stryke-aws) | AWS SDK bindings (S3, EC2, SQS, Lambda, ...). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-aws/) · [report](https://menketechnologies.github.io/stryke-aws/report.html)</sub> |
| [`stryke-azure`](https://github.com/MenkeTechnologies/stryke-azure) | Microsoft Azure SDK bindings. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-azure/) · [report](https://menketechnologies.github.io/stryke-azure/report.html)</sub> |
| [`stryke-clickhouse`](https://github.com/MenkeTechnologies/stryke-clickhouse) | ClickHouse client — SELECT, JSONEachRow insert, DDL, schema introspection over the HTTP interface (port 8123). Pure-Rust `ureq`/rustls, no tokio. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-clickhouse/) · [report](https://menketechnologies.github.io/stryke-clickhouse/report.html)</sub> |
| [`stryke-demo`](https://github.com/MenkeTechnologies/stryke-demo) | Demo scripts + example programs. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-demo/) · [report](https://menketechnologies.github.io/stryke-demo/report.html)</sub> |
| [`stryke-docker`](https://github.com/MenkeTechnologies/stryke-docker) | Docker engine API client. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-docker/) · [report](https://menketechnologies.github.io/stryke-docker/report.html)</sub> |
| [`stryke-duckdb`](https://github.com/MenkeTechnologies/stryke-duckdb) | DuckDB embedded analytics. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-duckdb/) · [report](https://menketechnologies.github.io/stryke-duckdb/report.html)</sub> |
| [`stryke-email`](https://github.com/MenkeTechnologies/stryke-email) | Email + campaign client — SMTP send, personalized mass mailing with `{{merge}}` templates, List-Unsubscribe + suppression + rate limiting, through your own authenticated SMTP (lettre, rustls, no tokio). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-email/) · [report](https://menketechnologies.github.io/stryke-email/report.html)</sub> |
| [`stryke-fleet`](https://github.com/MenkeTechnologies/stryke-fleet) | Parallel expect/PTY automation — transcripted sessions, declarative playbooks, recipe corpus for interactive CLIs, multi-host fan-out. Pure stryke, loaded on `use Fleet`. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-fleet/) · [report](https://menketechnologies.github.io/stryke-fleet/report.html)</sub> |
| [`stryke-gcp`](https://github.com/MenkeTechnologies/stryke-gcp) | Google Cloud Platform SDK bindings. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-gcp/) · [report](https://menketechnologies.github.io/stryke-gcp/report.html)</sub> |
| [`stryke-grpc`](https://github.com/MenkeTechnologies/stryke-grpc) | gRPC client/server. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-grpc/) · [report](https://menketechnologies.github.io/stryke-grpc/report.html)</sub> |
| [`stryke-gui`](https://github.com/MenkeTechnologies/stryke-gui) | GUI automation bridge — `stryke_gui` cdylib `dlopen`ed in-process on `use GUI`, fronting mouse/keyboard synthesis (enigo) + screen capture (xcap). Persistent `Enigo` handle in `OnceCell`, no fork-per-call. Isolates X11 / Wayland / CGEvent / SendInput linkage out of the stryke core. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-gui/) · [report](https://menketechnologies.github.io/stryke-gui/report.html)</sub> |
| [`stryke-k8s`](https://github.com/MenkeTechnologies/stryke-k8s) | Kubernetes API client. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-k8s/) · [report](https://menketechnologies.github.io/stryke-k8s/report.html)</sub> |
| [`stryke-kafka`](https://github.com/MenkeTechnologies/stryke-kafka) | Kafka producer/consumer (rdkafka bindings). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-kafka/) · [report](https://menketechnologies.github.io/stryke-kafka/report.html)</sub> |
| [`stryke-mcpd`](https://github.com/MenkeTechnologies/stryke-mcpd) | MCP servers as single native binaries — validated tool specs, crash-isolated serving, root-jailed stock tool pack. Pure stryke, loaded on `use Mcpd`. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mcpd/) · [report](https://menketechnologies.github.io/stryke-mcpd/report.html)</sub> |
| [`stryke-mongo`](https://github.com/MenkeTechnologies/stryke-mongo) | MongoDB driver. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mongo/) · [report](https://menketechnologies.github.io/stryke-mongo/report.html)</sub> |
| [`stryke-mssql`](https://github.com/MenkeTechnologies/stryke-mssql) | Microsoft SQL Server / Azure SQL client — parametrized query/execute, transaction batches, scalar/exists, schema introspection over tiberius (pure-Rust TDS, blocking facade over tokio). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mssql/) · [report](https://menketechnologies.github.io/stryke-mssql/report.html)</sub> |
| [`stryke-mysql`](https://github.com/MenkeTechnologies/stryke-mysql) | MySQL/MariaDB driver. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mysql/) · [report](https://menketechnologies.github.io/stryke-mysql/report.html)</sub> |
| [`stryke-neo4j`](https://github.com/MenkeTechnologies/stryke-neo4j) | Neo4j graph client — parametrized Cypher query/run, scalar/row helpers, schema introspection (labels, rel types, indexes, constraints) over Bolt (neo4rs, pure-Rust, blocking facade over tokio). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-neo4j/) · [report](https://menketechnologies.github.io/stryke-neo4j/report.html)</sub> |
| [`stryke-office`](https://github.com/MenkeTechnologies/stryke-office) | Office/ODF/PDF/image import+export — Excel/Word/PowerPoint (xlsx/docx/pptx) + OpenDocument (ods/odt/odp) + PDF + PIL-style images (png/jpeg/gif/bmp/webp/tiff), all native (no LibreOffice). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-office/) · [report](https://menketechnologies.github.io/stryke-office/report.html)</sub> |
| [`stryke-parquet`](https://github.com/MenkeTechnologies/stryke-parquet) | Apache Parquet read/write. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-parquet/) · [report](https://menketechnologies.github.io/stryke-parquet/report.html)</sub> |
| [`stryke-polars`](https://github.com/MenkeTechnologies/stryke-polars) | Full pandas + numpy surface — DataFrame/Series/Index/IO + ndarray/ufuncs/linalg/random/fft/polynomial/masked/datetime64 — in one cdylib, `dlopen`ed in-process on `use Polars`. Heavy deps kept out of the stryke core. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-polars/) · [report](https://menketechnologies.github.io/stryke-polars/report.html)</sub> |
| [`stryke-postgres`](https://github.com/MenkeTechnologies/stryke-postgres) | PostgreSQL driver. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-postgres/) · [report](https://menketechnologies.github.io/stryke-postgres/report.html)</sub> |
| [`stryke-redis`](https://github.com/MenkeTechnologies/stryke-redis) | Redis client. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-redis/) · [report](https://menketechnologies.github.io/stryke-redis/report.html)</sub> |
| [`stryke-scrape`](https://github.com/MenkeTechnologies/stryke-scrape) | Web scraping / crawling client — fetch, robots-respecting bounded crawl, sitemap discovery, plus pure CSS / table / link / structured-data (JSON-LD, OpenGraph) extraction. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-scrape/) · [report](https://menketechnologies.github.io/stryke-scrape/report.html)</sub> |
| [`stryke-scylla`](https://github.com/MenkeTechnologies/stryke-scylla) | ScyllaDB / Cassandra client — CQL query, DDL, schema introspection over the native binary protocol. Pure-Rust scylla driver on an embedded tokio runtime. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-scylla/) · [report](https://menketechnologies.github.io/stryke-scylla/report.html)</sub> |
| [`stryke-search`](https://github.com/MenkeTechnologies/stryke-search) | Elasticsearch / OpenSearch client — index admin, document CRUD, bulk, full query DSL + aggregation builders, scroll/PIT, templates, ingest pipelines, snapshots, cluster/tasks ops. One client for both engines; pure-Rust `ureq`/rustls transport, no JVM. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-search/) · [report](https://menketechnologies.github.io/stryke-search/report.html)</sub> |
| [`stryke-selenium`](https://github.com/MenkeTechnologies/stryke-selenium) | Selenium WebDriver bindings — browser automation. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-selenium/) · [report](https://menketechnologies.github.io/stryke-selenium/report.html)</sub> |
| [`stryke-spark`](https://github.com/MenkeTechnologies/stryke-spark) | Apache Spark integration. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-spark/) · [report](https://menketechnologies.github.io/stryke-spark/report.html)</sub> |
| [`stryke-utils`](https://github.com/MenkeTechnologies/stryke-utils) | Pure stryke library — shared helpers written in stryke itself, no Rust or external deps. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-utils/) · [report](https://menketechnologies.github.io/stryke-utils/report.html)</sub> |
| [`stryke-zmq`](https://github.com/MenkeTechnologies/stryke-zmq) | ZeroMQ client — brokerless req/rep, pub/sub, push/pull, dealer/router. cdylib with libzmq vendored. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-zmq/) · [report](https://menketechnologies.github.io/stryke-zmq/report.html)</sub> |

### Tier 3 — zsh-more-completions (1)

| Project | What it is |
|---|---|
| [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) | 47,316-completion zsh corpus (8,360 `src/` + 34,481 `more_src/`–`more_src8/` + 3,398 `man_src/` + 1,067 `architecture_src/` + 10 `override_src/`; counts `_*` completion functions only — produced by `scripts/print-repo-stats.zsh`). ⭐ 56. The largest curated completion collection in existence. Lives outside Tier 1 because it's data + completion functions, not an executable. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-more-completions/) · [report](https://menketechnologies.github.io/zsh-more-completions/report.html)</sub> |

### Tier 4 — Zsh ecosystem plugins (28)

The plugin family that `zpwr` and any zsh user can load via zinit / oh-my-zsh. The full `ZPWR_GH_PLUGINS` canonical list plus the legacy zsh-* family.

| Project | What it is |
|---|---|
| [`zsh-expand`](https://github.com/MenkeTechnologies/zsh-expand) | Expand aliases / global aliases / typos on space. ⭐ 43. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-expand/) · [report](https://menketechnologies.github.io/zsh-expand/report.html)</sub> |
| [`zsh-cargo-completion`](https://github.com/MenkeTechnologies/zsh-cargo-completion) | Cargo completion. ⭐ 35. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-cargo-completion/) · [report](https://menketechnologies.github.io/zsh-cargo-completion/report.html)</sub> |
| [`zsh-learn`](https://github.com/MenkeTechnologies/zsh-learn) | MySQL/MariaDB-backed learning collection — save, query, quiz. ⭐ 8. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-learn/) · [report](https://menketechnologies.github.io/zsh-learn/report.html)</sub> |
| [`zsh-git-acp`](https://github.com/MenkeTechnologies/zsh-git-acp) | `git add commit push` in one keybinding. ⭐ 6. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-git-acp/) · [report](https://menketechnologies.github.io/zsh-git-acp/report.html)</sub> |
| [`zsh-better-npm-completion`](https://github.com/MenkeTechnologies/zsh-better-npm-completion) | Better npm completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-better-npm-completion/) · [report](https://menketechnologies.github.io/zsh-better-npm-completion/report.html)</sub> |
| [`zsh-cpan-completion`](https://github.com/MenkeTechnologies/zsh-cpan-completion) | CPAN completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-cpan-completion/) · [report](https://menketechnologies.github.io/zsh-cpan-completion/report.html)</sub> |
| [`zsh-dotnet-completion`](https://github.com/MenkeTechnologies/zsh-dotnet-completion) | .NET completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-dotnet-completion/) · [report](https://menketechnologies.github.io/zsh-dotnet-completion/report.html)</sub> |
| [`zsh-gem-completion`](https://github.com/MenkeTechnologies/zsh-gem-completion) | Ruby gem completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-gem-completion/) · [report](https://menketechnologies.github.io/zsh-gem-completion/report.html)</sub> |
| [`zsh-git-repo-cache`](https://github.com/MenkeTechnologies/zsh-git-repo-cache) | Git repo cache helper. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-git-repo-cache/) · [report](https://menketechnologies.github.io/zsh-git-repo-cache/report.html)</sub> |
| [`zsh-nginx`](https://github.com/MenkeTechnologies/zsh-nginx) | nginx config completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-nginx/) · [report](https://menketechnologies.github.io/zsh-nginx/report.html)</sub> |
| [`zsh-pip-description-completion`](https://github.com/MenkeTechnologies/zsh-pip-description-completion) | pip completion with package descriptions. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-pip-description-completion/) · [report](https://menketechnologies.github.io/zsh-pip-description-completion/report.html)</sub> |
| [`zsh-sed-sub`](https://github.com/MenkeTechnologies/zsh-sed-sub) | sed substitution helper. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-sed-sub/) · [report](https://menketechnologies.github.io/zsh-sed-sub/report.html)</sub> |
| [`zsh-sudo`](https://github.com/MenkeTechnologies/zsh-sudo) | `Esc Esc` to prepend `sudo` to the current line. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-sudo/) · [report](https://menketechnologies.github.io/zsh-sudo/report.html)</sub> |
| [`zsh-xcode-completions`](https://github.com/MenkeTechnologies/zsh-xcode-completions) | Xcode CLI tools completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-xcode-completions/) · [report](https://menketechnologies.github.io/zsh-xcode-completions/report.html)</sub> |
| [`zsh-docker-aliases`](https://github.com/MenkeTechnologies/zsh-docker-aliases) | Docker aliases + functions. |
| [`zsh-openshift-aliases`](https://github.com/MenkeTechnologies/zsh-openshift-aliases) | 52 `oc`-* aliases + login macros (`ocdev`, `ocqa`) + auto-sourced `oc` completion. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-openshift-aliases/) · [report](https://menketechnologies.github.io/zsh-openshift-aliases/report.html)</sub> |
| [`zsh-travis`](https://github.com/MenkeTechnologies/zsh-travis) | `tg`/`tb`/`tbr`/`tpr` — open Travis CI build pages from inside the project. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-travis/) · [report](https://menketechnologies.github.io/zsh-travis/report.html)</sub> |
| [`zsh-very-colorful-manuals`](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals) | Neon-tints `man` page output via `LESS_TERMCAP_*` env. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-very-colorful-manuals/) · [report](https://menketechnologies.github.io/zsh-very-colorful-manuals/report.html)</sub> |
| [`zsh-z`](https://github.com/MenkeTechnologies/zsh-z) | `z <dir>` — frecency-jump to recently visited directories. |
| [`zsh-zinit-final`](https://github.com/MenkeTechnologies/zsh-zinit-final) | Empty-by-design latch for zinit `atinit` / `atload` ices that need to fire after every other plugin. |
| [`fasd-simple`](https://github.com/MenkeTechnologies/fasd-simple) | Frecency `cd` / file picker. v1.0.x cleanup of the original `fasd`. |
| [`fzf-tab`](https://github.com/MenkeTechnologies/fzf-tab) | Replace zsh's default tab completion with fzf. |
| [`fzf-zsh-plugin`](https://github.com/MenkeTechnologies/fzf-zsh-plugin) | fzf-shipped zsh keybindings + completion + history search. |
| [`gh_reveal`](https://github.com/MenkeTechnologies/gh_reveal) | `reveal` — open the current git project in the default browser. |
| [`jhipster-oh-my-zsh-plugin`](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin) | JHipster CLI completion + aliases. |
| [`kubectl-aliases`](https://github.com/MenkeTechnologies/kubectl-aliases) | 790 `kubectl` aliases (kg=get, kgp=get-pods, …). |
| [`revolver`](https://github.com/MenkeTechnologies/revolver) | Spinner / progress widget for zsh scripts. |
| [`zunit`](https://github.com/MenkeTechnologies/zunit) | Powerful zsh unit-testing framework. |

### Tier 5 — Editor / multiplexer plugins (11)

Plugins that target Vim/Neovim and tmux rather than zsh proper.

| Project | What it is |
|---|---|
| [`VimColorSchemes`](https://github.com/MenkeTechnologies/VimColorSchemes) | 732 hand-curated Vim colorschemes packaged as a single Pathogen / vim-plug / lazy.nvim bundle. The largest one-bundle scheme collection. &middot; <sub>[docs](https://menketechnologies.github.io/VimColorSchemes/) · [report](https://menketechnologies.github.io/VimColorSchemes/report.html)</sub> |
| [`vim-stryke`](https://github.com/MenkeTechnologies/vim-stryke) | Vim / Neovim support for the stryke language — `*.stk` + shebang filetype detection, a standalone stryke syntax grammar generated from the stryke binary's own reflection tables (all 10,450 builtins, 90 keywords, 39 parallel primitives, sigils / regex / thread macros), brace-aware indentation, ALE linting via `stryke --lint`, and LSP (vim-lsp / coc.nvim) via `stryke --lsp`. Pathogen / vim-plug / native-package install. &middot; <sub>[docs](https://menketechnologies.github.io/vim-stryke/) · [report](https://menketechnologies.github.io/vim-stryke/report.html)</sub> |
| [`vscode-stryke`](https://github.com/MenkeTechnologies/vscode-stryke) | VS Code / VSCodium extension for the stryke language — `*.stk` filetype detection, a stryke-native TextMate grammar generated from the stryke binary's reflection tables (the complete builtin surface), and LSP via `stryke --lsp`. &middot; <sub>[docs](https://menketechnologies.github.io/vscode-stryke/) · [report](https://menketechnologies.github.io/vscode-stryke/report.html)</sub> |
| [`emacs-stryke`](https://github.com/MenkeTechnologies/emacs-stryke) | `stryke-mode` for Emacs — a generated `stryke-stdlib.el` carrying the complete language surface (all 10,450 builtins + 39 parallel primitives) pulled from the stryke binary's own reflection tables. Stored as hash tables matched by a font-lock function (a single `regexp-opt` over 10,450 names overflows Emacs' regexp compiler), plus brace indent and LSP via `stryke --lsp` (eglot + lsp-mode). Regenerate after a stryke upgrade via `scripts/gen-stdlib.sh`. &middot; <sub>[docs](https://menketechnologies.github.io/emacs-stryke/) · [report](https://menketechnologies.github.io/emacs-stryke/report.html)</sub> |
| [`vim-zsh`](https://github.com/MenkeTechnologies/vim-zsh) | Vim / Neovim support for the [`zshrs`](https://github.com/MenkeTechnologies/zshrs) shell — `*.zsh` / dotfile / shebang filetype detection (`filetype=zshrs`), a standalone grammar generated from `zshrs --dump-reflection` (137 builtins, 113 zshrs extensions on their own highlight group, 245 special vars, control + decl keywords), shell-block-aware indent, ALE via `zshrs -n`, and LSP (vim-lsp / coc.nvim) via `zshrs --lsp`. &middot; <sub>[docs](https://menketechnologies.github.io/vim-zsh/) · [report](https://menketechnologies.github.io/vim-zsh/report.html)</sub> |
| [`vscode-zsh`](https://github.com/MenkeTechnologies/vscode-zsh) | VS Code / VSCodium support for `zshrs` — a `source.zshrs` TextMate grammar generated from `zshrs --dump-reflection` (137 builtins, 113 zshrs extensions on their own scope, 245 special vars), `*.zsh` / dotfile / shebang detection, and LSP via `zshrs --lsp`. &middot; <sub>[docs](https://menketechnologies.github.io/vscode-zsh/) · [report](https://menketechnologies.github.io/vscode-zsh/report.html)</sub> |
| [`emacs-zsh`](https://github.com/MenkeTechnologies/emacs-zsh) | `zshrs-mode` for Emacs — font-lock generated from `zshrs --dump-reflection` (137 builtins, 113 zshrs extensions via a dedicated `zshrs-extension-face`, 245 special vars), shell-block-aware indent, and LSP via `zshrs --lsp` (eglot + lsp-mode). Regenerate via `scripts/gen-stdlib.sh`. &middot; <sub>[docs](https://menketechnologies.github.io/emacs-zsh/) · [report](https://menketechnologies.github.io/emacs-zsh/report.html)</sub> |
| [`vscode-awk`](https://github.com/MenkeTechnologies/vscode-awk) | VS Code / VSCodium extension for AWK (`awkrs`) — `*.awk` filetype detection, a hand-written `source.awk` TextMate grammar (`BEGIN`/`END`, control keywords, built-in vars + functions, field refs, `/regex/` literals), an `awk.run` command, LSP via `awkrs --lsp`, and DAP debugging via `awkrs --dap`. &middot; <sub>[docs](https://menketechnologies.github.io/vscode-awk/) · [report](https://menketechnologies.github.io/vscode-awk/report.html)</sub> |
| [`vim-awk`](https://github.com/MenkeTechnologies/vim-awk) | Vim / Neovim support for AWK (`awkrs`) — `*.awk` filetype detection, syntax + brace-aware indent, run / `:make` via `awkrs`, and LSP via `awkrs --lsp`. &middot; <sub>[docs](https://menketechnologies.github.io/vim-awk/) · [report](https://menketechnologies.github.io/vim-awk/report.html)</sub> |
| [`emacs-awk`](https://github.com/MenkeTechnologies/emacs-awk) | `awkrs-mode` for Emacs — font-lock for AWK (keywords, built-in vars/functions, field refs, `/regex/`), indent, run via `awkrs`, eldoc + completion from a built-in-function stdlib, and LSP via `awkrs --lsp` (eglot + lsp-mode). &middot; <sub>[docs](https://menketechnologies.github.io/emacs-awk/) · [report](https://menketechnologies.github.io/emacs-awk/report.html)</sub> |
| [`tmux-fzf-url`](https://github.com/MenkeTechnologies/tmux-fzf-url) | Pop a fzf picker over every URL currently visible in the tmux pane; selected URL opens in the default browser. |

### Tier 6 — Apps, extensions, web & web-APIs (17)

Browser extensions, supporting apps, audio plugins, public website, storefront, and web-API services. (Tauri v2 desktop GUI apps `traderview` and `Audio-Haxor` live in Tier 1; the `powerliners` CLI port lives in Tier 1 too.)

| Project | What it is |
|---|---|
| [`zpwrchrome`](https://github.com/MenkeTechnologies/zpwrchrome) | Browser power-tool: UNIX `pass` integration, segmented multi-connection download manager (default Chrome takeover), JetBrains-style tab switcher with cross-window MRU + scenes + opener-tree + minimap, fzf history search, Tampermonkey-equivalent userscripts, full-page screenshot, Wappalyzer-compatible tech detection, cyberpunk page-theme injector, Turn Off the Lights cinema dimmer, reader mode, post-download custom commands, JSON viewer, UA switcher, find-in-all-tabs. Manifest V3, 54 commands (4 default-keyed + 50 user-bindable). Ships a companion Chrome theme + the **native messaging host** `zpwrchrome-host` (the Rust port of browserpass-native + the segmented downloader + `run.spawn` for post-download commands) — installable via `brew install zpwrchrome-host` from the [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) tap. &middot; <sub>[docs](https://menketechnologies.github.io/zpwrchrome/) · [report](https://menketechnologies.github.io/zpwrchrome/report.html)</sub> |
| [`storageshower`](https://github.com/MenkeTechnologies/storageshower) | Disk-usage **TUI** in Rust (sibling to iftoprs). Walks a directory tree, presents space-by-folder with sort + drill-down. |
| [`zpwr-jobs`](https://github.com/MenkeTechnologies/zpwr-jobs) | **CLI job-application pipeline manager** — tracks job postings, resumes, and cover letters through an application workflow. **Private** — docs vendored to meta. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-jobs) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-jobs/report)</sub> |
| [`MenkeTechnologies.github.io`](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io) | Public-facing personal site / project landing page (cyberpunk HUD, static HTML + CSS). |
| [`api-rest-generator`](https://github.com/MenkeTechnologies/api-rest-generator) | **Web-API codegen tool.** Rust port (v0.2.0+) of the original Kotlin Spring-Boot-REST-API generator — feed it MySQL / PostgreSQL / SQLite / MSSQL DDL, get a fully wired Spring Boot REST backend (entities, controllers, DAOs, repositories) in Java / Kotlin / Groovy. Kotlin source preserved under `src/main/kotlin/` for reference. &middot; <sub>[docs](https://menketechnologies.github.io/api-rest-generator/) · [report](https://menketechnologies.github.io/api-rest-generator/report.html)</sub> |
| [`LearningCollectionAPI`](https://github.com/MenkeTechnologies/LearningCollectionAPI) | **Web API.** Java/Kotlin Spring Boot REST service — backing service for the `zsh-learn` plugin (save / query / quiz / search vocabulary cards over HTTP). &middot; <sub>[docs](https://menketechnologies.github.io/LearningCollectionAPI/) · [report](https://menketechnologies.github.io/LearningCollectionAPI/report.html)</sub> |
| [`zpwr-synth`](https://github.com/MenkeTechnologies/zpwr-synth) | **World first** — part of the first fully-modular patch-graph audio plugin quartet (with `zpwr-daw`) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. **JUCE software synthesizer** (C++). Fully modular patch-graph instrument on the shared `zpwr-patch-core` engine, modeled on SynthMaster 3 — Instrument → Layer[16] → Voice where each voice is a free patch graph of 299 voice modules (VA/wavetable/FM/additive/supersaw/Karplus oscillators, filters, ADSR/LFO/S&H, VCA), plus a master + unlimited-aux FX-bus rack running the shared 2,772-module audio pack. A PERFORM stage (4-corner preset morph, an Omnisphere-style **Orb** with motion record/loop, XY macro pads, scene snapshots, randomize, scale/chord keyboard, arp+latch), **Stereo + Stereo Lock** chain mirroring, and MIDI **Program/Bank-Change** response toggles round it out. DSP core is a pure-C++ static lib (no JUCE dep, headless-unit-testable). Builds **VST3 / AU / CLAP / Standalone** on macOS (ARM/Intel) + Linux (x86_64/aarch64). **Paid product** — docs vendored locally. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-synth) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-synth/report)</sub> |
| [`zpwr-fx`](https://github.com/MenkeTechnologies/zpwr-fx) | **World first** — part of the first fully-modular patch-graph audio plugin quartet (with `zpwr-daw`) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. **JUCE fully modular multi-effects plugin** (C++). A free patch graph on the shared `zpwr-patch-core` engine — wire 2,772 DSP modules (incl. 171 analog-circuit models) into your own algorithm, with a per-param mod matrix, unlimited layers, and EZ-wire auto-routing. Not a fixed slot rack. Adds **Stereo + Stereo Lock** mirroring, a PERFORM stage (preset morph, **Orb** motion record/loop, XY macros, snapshots, randomize), and MIDI **Program/Bank-Change** toggles. Builds **VST3 / AU / CLAP / Standalone**. **Paid product** — docs vendored locally. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-fx) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-fx/report)</sub> |
| [`zpwr-midi-fx`](https://github.com/MenkeTechnologies/zpwr-midi-fx) | **World first** — part of the first fully-modular patch-graph audio plugin quartet (with `zpwr-daw`) to pair free patch-graph wiring with a no-cable knob panel, one-click EZ auto-wiring, and stereo-mirror + offset-preserving stereo link. **JUCE fully modular MIDI-effects plugin** — companion to `zpwr-fx`, the same free patch-graph engine instantiated on the note stream: 66 note-stream modules (arpeggiation / chord / scale / Euclidean+generative seq / humanize / transform), per-param mod matrix, EZ-wire. Shares the PERFORM stage (preset morph, **Orb**, XY macros, snapshots), **Stereo + Stereo Lock**, and MIDI **Program/Bank-Change** toggles. Builds **VST3 / AU / CLAP / Standalone**. **Paid product** — docs vendored locally. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-midi-fx) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-midi-fx/report)</sub> |
| [`zpwr-patch-core`](https://github.com/MenkeTechnologies/zpwr-patch-core) | **Signal-agnostic modular patch graph** (C++20, depends on `juce_core`). The shared cable-routing core behind the plugin stack — owns what's identical in every modular plugin (patch graph, soft knobs, shared WebEditor, patch versioning/migration) and knows nothing about audio or MIDI. Reused by `zpwr-fx`, `zpwr-synth`, and `zpwr-midi-fx`. **Private** — part of the paid audio stack. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-patch-core) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-patch-core/report)</sub> |
| [`zpwr-hooks-editor`](https://github.com/MenkeTechnologies/zpwr-hooks-editor) | **Shared stryke Hooks code editor** (JS) — a Monaco editor (+ monaco-vim, monaco-emacs, and a thin stryke-LSP adapter) esbuild-bundled into vendored IIFE artifacts (`hooks-editor.bundle.{js,css}` + `hooks-editor.worker.js`). Extracted from Audio-Haxor so the editor is single-sourced instead of duplicated across apps. Build-on-each-consumer: the bundler reads `src/` from this repo but resolves `monaco-*` from the consuming app's `node_modules` and writes into its `frontend/lib/`. Consumed by all four apps — `Audio-Haxor`, `traderview`, `ztranslator` (Tauri, at `crates/`) and `zpwr-daw` (JUCE WebView, at `libs/`). **Private** — internal shared component. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-hooks-editor) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-hooks-editor/report)</sub> |
| [`zpwr-i18n`](https://github.com/MenkeTechnologies/zpwr-i18n) | **Shared i18n runtime** (JS) — one portable internationalization runtime shared across all four GUI apps, extracted from Audio-Haxor. Host-agnostic: catalogs load from **JSON files** (not Audio-Haxor's SQLite/Tauri loader), so the same code runs in Tauri apps and JUCE WebViews. Flat `{ "namespace.key": "string with {vars}" }` catalogs, one JSON per locale, 27 supported UI locales; shared components (e.g. `zpwr-file-browser`) ship their own per-locale fragment that the host merges in via `extraBases`. API on `window` — `appFmt`/`toastFmt`/`t` (interpolate + missing-key fallback to the key), `applyUiI18n`, `loadLocale`, `bootI18n`, `mergeI18nCatalog`. **Private** — internal shared component. &middot; <sub>[docs](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-i18n) · [report](https://menketechnologies.github.io/MenkeTechnologiesMeta/zpwr-i18n/report)</sub> |
| [`zpwr-clip-engine`](https://github.com/MenkeTechnologies/zpwr-clip-engine) | **Shared DAW arranger/sequencer frontend** (JS) — the canvas clip-grid + swappable *domains* (arranger, piano-roll, session launcher, automation lanes) plus the clip palette, MIDI export, and project/bank serialization, extracted from `zpwr-daw` so every GUI app embeds one arranger through a single `initClipSeq({ nf, getCAT })` entry point. `zpwr-daw` (JUCE/C++) supplies a native audio backend; the synth / fx / midi-fx apps use the bundled non-audio JS backend (`window.makeBasicClipBackend()`). **Private** — internal shared component. |
| [`zpwr-theme`](https://github.com/MenkeTechnologies/zpwr-theme) | **Cyberpunk HUD color theme for VS Code + JetBrains** — the Strykelang HUD palette (deep-space ink `#05050a`, neon cyan `#05d9e8`, magenta scanlines `#d300c5`) shared with `zpwrchrome`, `zpwr`, and the docs design system, packaged for both editor families from one `PALETTE.md`. `vscode/` ships a `contributes.themes` extension with full workbench + token colors (stryke sigils / `~>` threading / parallel builtins get the magenta accent); `jetbrains/` ships a UI theme + matching editor color scheme with a dependency-free `zip`-only packager (no Gradle/SDK). Companion to `vscode-stryke`. |
| [`app-store`](https://github.com/MenkeTechnologies/app-store) | **Static storefront** (HTML/CSS/JS) for the entire MenkeTechnologies catalog — 69 products across 6 categories: paid Tauri/JUCE apps & plugins (`Audio-Haxor`, `traderview`, `ztranslator`, `zpwr-daw`, `zpwr-synth`, `zpwr-fx`, `zpwr-midi-fx`, licensed **per major version**) plus every free/OSS repo (`zshrs`, `stryke`, the Rust CLI tools, the stryke package ecosystem, the zsh-plugin family) with GitHub download links (`releases/latest` or `/tags`). Shopify-style checkout, search + category filters, live catalog stats. Shares the strykelang-docs HUD design system; no build step; dependency-free `node:test` suite + CI. &middot; <sub>[store](https://menketechnologies.github.io/app-store/) · [docs](https://menketechnologies.github.io/app-store/docs/) · [report](https://menketechnologies.github.io/app-store/docs/report.html)</sub> |
| [`zpwr-license`](https://github.com/MenkeTechnologies/zpwr-license) | **Offline-first software licensing** for the paid catalog (PRIVATE). Ed25519-signed license keys, an issuer CLI, and an optional self-hosted activation server. Verification runs offline in the binary (kills keygens, works air-gapped); **offline node-locking** binds a key to a machine with no server (anti-sharing); online activation adds live seats + revocation. Embedded **anti-tamper** layer (debugger / injection / self-binary-signature / key-substitution / clock-rollback checks) with obfuscated strings + symbols. Rust workspace (`license-core` + `license-cli` + `license-server`), no licensing SaaS. **Private** — anti-piracy infrastructure. |
| [`MenkeTechnologiesPublications`](https://github.com/MenkeTechnologies/MenkeTechnologiesPublications) | **Paid publications** (PRIVATE). The companion books, reference manuals/PDFs, and the zpwr encyclopedia for `strykelang`, `zshrs`, and `zpwr`, plus their generation pipeline (pandoc + LaTeX). Self-contained: vendors the public source repos as `src/` submodules and builds each book from that source; the free public docs sites stay in each product's own repo. **Private** — paid product. |

---

## [0x02] CI STATUS BOARD

Live GitHub Actions status for every submodule in one table — scan the whole org from one page; the Tier column matches the [submodule map](#0x01-submodule-map). CI badges pin each repo's default branch; Release badges show the latest tag-triggered run; Version badges show each repo's latest semver tag (live from shields.io, linked to the repo's tags page). `—` = no workflow / no tags yet, or a **private repo** (paid products have no public Actions runs, badges, or tags). The board is generated from `.gitmodules` + each repo's active workflow list (`gh api repos/MenkeTechnologies/<repo>/actions/workflows`).

| Tier | Repo | CI | Release | Version |
|---|---|---|---|---|
| 1 — Core | [`strykelang`](https://github.com/MenkeTechnologies/strykelang) | [![CI](https://github.com/MenkeTechnologies/strykelang/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/strykelang/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/strykelang/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/strykelang/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/strykelang?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/strykelang/tags) |
| 1 — Core | [`zshrs`](https://github.com/MenkeTechnologies/zshrs) | [![CI](https://github.com/MenkeTechnologies/zshrs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zshrs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/zshrs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/zshrs/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zshrs?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zshrs/tags) |
| 1 — Core | [`fusevm`](https://github.com/MenkeTechnologies/fusevm) | [![CI](https://github.com/MenkeTechnologies/fusevm/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fusevm/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/fusevm?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/fusevm/tags) |
| 1 — Core | [`lsofrs`](https://github.com/MenkeTechnologies/lsofrs) | [![CI](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/lsofrs?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/lsofrs/tags) |
| 1 — Core | [`temprs`](https://github.com/MenkeTechnologies/temprs) | [![CI](https://github.com/MenkeTechnologies/temprs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/temprs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/temprs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/temprs/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/temprs?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/temprs/tags) |
| 1 — Core | [`awkrs`](https://github.com/MenkeTechnologies/awkrs) | [![CI](https://github.com/MenkeTechnologies/awkrs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/awkrs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/awkrs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/awkrs/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/awkrs?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/awkrs/tags) |
| 1 — Core | [`iftoprs`](https://github.com/MenkeTechnologies/iftoprs) | [![CI](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/iftoprs?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/iftoprs/tags) |
| 1 — Core | [`ztranslator`](https://github.com/MenkeTechnologies/ztranslator) | — | — | — |
| 1 — Core | [`Audio-Haxor`](https://github.com/MenkeTechnologies/Audio-Haxor) | — | — | — |
| 1 — Core | [`traderview`](https://github.com/MenkeTechnologies/traderview) | — | — | — |
| 1 — Core | [`zpwr-daw`](https://github.com/MenkeTechnologies/zpwr-daw) | — | — | — |
| 1 — Core | [`zpwr-crate`](https://github.com/MenkeTechnologies/zpwr-crate) | — | — | — |
| 1 — Core | [`zpwr-embed-terminal`](https://github.com/MenkeTechnologies/zpwr-embed-terminal) | — | — | — |
| 1 — Core | [`zpwr-file-browser`](https://github.com/MenkeTechnologies/zpwr-file-browser) | — | — | — |
| 1 — Core | [`zpwr-algo-production`](https://github.com/MenkeTechnologies/zpwr-algo-production) | — | — | — |
| 1 — Core | [`nmaprs`](https://github.com/MenkeTechnologies/nmaprs) | [![CI](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/nmaprs?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/nmaprs/tags) |
| 1 — Core | [`powerliners`](https://github.com/MenkeTechnologies/powerliners) | [![CI](https://github.com/MenkeTechnologies/powerliners/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/powerliners/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/powerliners/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/powerliners/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/powerliners?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/powerliners/tags) |
| 1 — Core | [`zpwr`](https://github.com/MenkeTechnologies/zpwr) | [![CI](https://github.com/MenkeTechnologies/zpwr/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zpwr/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zpwr?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zpwr/tags) |
| 2 — Stryke ecosystem + tap | [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) | [![CI](https://github.com/MenkeTechnologies/homebrew-menketech/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/homebrew-menketech/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/homebrew-menketech?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/homebrew-menketech/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-arrow`](https://github.com/MenkeTechnologies/stryke-arrow) | [![CI](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-arrow?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-arrow/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-aws`](https://github.com/MenkeTechnologies/stryke-aws) | [![CI](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-aws?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-aws/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-azure`](https://github.com/MenkeTechnologies/stryke-azure) | [![CI](https://github.com/MenkeTechnologies/stryke-azure/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-azure/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-azure/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-azure/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-azure?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-azure/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-clickhouse`](https://github.com/MenkeTechnologies/stryke-clickhouse) | [![CI](https://github.com/MenkeTechnologies/stryke-clickhouse/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-clickhouse/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-clickhouse/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-clickhouse/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-clickhouse?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-clickhouse/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-demo`](https://github.com/MenkeTechnologies/stryke-demo) | [![CI](https://github.com/MenkeTechnologies/stryke-demo/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-demo/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-demo?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-demo/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-docker`](https://github.com/MenkeTechnologies/stryke-docker) | [![CI](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-docker?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-docker/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-duckdb`](https://github.com/MenkeTechnologies/stryke-duckdb) | [![CI](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-duckdb?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-duckdb/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-email`](https://github.com/MenkeTechnologies/stryke-email) | [![CI](https://github.com/MenkeTechnologies/stryke-email/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-email/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-email/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-email/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-email?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-email/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-fleet`](https://github.com/MenkeTechnologies/stryke-fleet) | [![CI](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-fleet?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-fleet/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-gcp`](https://github.com/MenkeTechnologies/stryke-gcp) | [![CI](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-gcp?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-gcp/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-grpc`](https://github.com/MenkeTechnologies/stryke-grpc) | [![CI](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-grpc?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-grpc/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-gui`](https://github.com/MenkeTechnologies/stryke-gui) | [![CI](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-gui?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-gui/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-k8s`](https://github.com/MenkeTechnologies/stryke-k8s) | [![CI](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-k8s?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-k8s/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-kafka`](https://github.com/MenkeTechnologies/stryke-kafka) | [![CI](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-kafka?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-kafka/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-mcpd`](https://github.com/MenkeTechnologies/stryke-mcpd) | [![CI](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-mcpd?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-mcpd/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-mongo`](https://github.com/MenkeTechnologies/stryke-mongo) | [![CI](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-mongo?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-mongo/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-mssql`](https://github.com/MenkeTechnologies/stryke-mssql) | [![CI](https://github.com/MenkeTechnologies/stryke-mssql/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mssql/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mssql/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mssql/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-mssql?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-mssql/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-mysql`](https://github.com/MenkeTechnologies/stryke-mysql) | [![CI](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-mysql?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-mysql/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-neo4j`](https://github.com/MenkeTechnologies/stryke-neo4j) | [![CI](https://github.com/MenkeTechnologies/stryke-neo4j/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-neo4j/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-neo4j/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-neo4j/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-neo4j?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-neo4j/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-office`](https://github.com/MenkeTechnologies/stryke-office) | [![CI](https://github.com/MenkeTechnologies/stryke-office/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-office/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-office/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-office/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-office?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-office/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-parquet`](https://github.com/MenkeTechnologies/stryke-parquet) | [![CI](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-parquet?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-parquet/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-polars`](https://github.com/MenkeTechnologies/stryke-polars) | [![CI](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-polars?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-polars/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-postgres`](https://github.com/MenkeTechnologies/stryke-postgres) | [![CI](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-postgres?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-postgres/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-redis`](https://github.com/MenkeTechnologies/stryke-redis) | [![CI](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-redis?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-redis/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-scrape`](https://github.com/MenkeTechnologies/stryke-scrape) | [![CI](https://github.com/MenkeTechnologies/stryke-scrape/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-scrape/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-scrape/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-scrape/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-scrape?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-scrape/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-scylla`](https://github.com/MenkeTechnologies/stryke-scylla) | [![CI](https://github.com/MenkeTechnologies/stryke-scylla/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-scylla/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-scylla/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-scylla/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-scylla?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-scylla/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-search`](https://github.com/MenkeTechnologies/stryke-search) | [![CI](https://github.com/MenkeTechnologies/stryke-search/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-search/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-search/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-search/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-search?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-search/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-selenium`](https://github.com/MenkeTechnologies/stryke-selenium) | [![CI](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-selenium?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-selenium/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-spark`](https://github.com/MenkeTechnologies/stryke-spark) | [![CI](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-spark?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-spark/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-utils`](https://github.com/MenkeTechnologies/stryke-utils) | [![CI](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-utils?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-utils/tags) |
| 2 — Stryke ecosystem + tap | [`stryke-zmq`](https://github.com/MenkeTechnologies/stryke-zmq) | [![CI](https://github.com/MenkeTechnologies/stryke-zmq/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-zmq/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-zmq/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-zmq/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/stryke-zmq?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/stryke-zmq/tags) |
| 3 — zsh-more-completions | [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) | [![CI](https://github.com/MenkeTechnologies/zsh-more-completions/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-more-completions/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-more-completions?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-more-completions/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-expand`](https://github.com/MenkeTechnologies/zsh-expand) | [![CI](https://github.com/MenkeTechnologies/zsh-expand/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-expand/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-expand?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-expand/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-cargo-completion`](https://github.com/MenkeTechnologies/zsh-cargo-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-cargo-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-cargo-completion/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-cargo-completion?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-cargo-completion/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-learn`](https://github.com/MenkeTechnologies/zsh-learn) | [![CI](https://github.com/MenkeTechnologies/zsh-learn/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-learn/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-learn?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-learn/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-git-acp`](https://github.com/MenkeTechnologies/zsh-git-acp) | [![CI](https://github.com/MenkeTechnologies/zsh-git-acp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-git-acp/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-git-acp?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-git-acp/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-better-npm-completion`](https://github.com/MenkeTechnologies/zsh-better-npm-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-better-npm-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-better-npm-completion/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-better-npm-completion?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-better-npm-completion/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-cpan-completion`](https://github.com/MenkeTechnologies/zsh-cpan-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-cpan-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-cpan-completion/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-cpan-completion?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-cpan-completion/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-dotnet-completion`](https://github.com/MenkeTechnologies/zsh-dotnet-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-dotnet-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-dotnet-completion/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-dotnet-completion?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-dotnet-completion/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-gem-completion`](https://github.com/MenkeTechnologies/zsh-gem-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-gem-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-gem-completion/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-gem-completion?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-gem-completion/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-git-repo-cache`](https://github.com/MenkeTechnologies/zsh-git-repo-cache) | [![CI](https://github.com/MenkeTechnologies/zsh-git-repo-cache/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-git-repo-cache/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-git-repo-cache?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-git-repo-cache/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-nginx`](https://github.com/MenkeTechnologies/zsh-nginx) | [![CI](https://github.com/MenkeTechnologies/zsh-nginx/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-nginx/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-nginx?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-nginx/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-pip-description-completion`](https://github.com/MenkeTechnologies/zsh-pip-description-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-pip-description-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-pip-description-completion/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-pip-description-completion?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-pip-description-completion/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-sed-sub`](https://github.com/MenkeTechnologies/zsh-sed-sub) | [![CI](https://github.com/MenkeTechnologies/zsh-sed-sub/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-sed-sub/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-sed-sub?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-sed-sub/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-sudo`](https://github.com/MenkeTechnologies/zsh-sudo) | [![CI](https://github.com/MenkeTechnologies/zsh-sudo/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-sudo/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-sudo?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-sudo/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-xcode-completions`](https://github.com/MenkeTechnologies/zsh-xcode-completions) | [![CI](https://github.com/MenkeTechnologies/zsh-xcode-completions/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-xcode-completions/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-xcode-completions?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-xcode-completions/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-docker-aliases`](https://github.com/MenkeTechnologies/zsh-docker-aliases) | [![CI](https://github.com/MenkeTechnologies/zsh-docker-aliases/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-docker-aliases/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-docker-aliases?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-docker-aliases/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-openshift-aliases`](https://github.com/MenkeTechnologies/zsh-openshift-aliases) | [![CI](https://github.com/MenkeTechnologies/zsh-openshift-aliases/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-openshift-aliases/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-openshift-aliases?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-openshift-aliases/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-travis`](https://github.com/MenkeTechnologies/zsh-travis) | [![CI](https://github.com/MenkeTechnologies/zsh-travis/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-travis/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-travis?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-travis/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-very-colorful-manuals`](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals) | [![CI](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-very-colorful-manuals?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-z`](https://github.com/MenkeTechnologies/zsh-z) | [![CI](https://github.com/MenkeTechnologies/zsh-z/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-z/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-z?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-z/tags) |
| 4 — Zsh ecosystem plugins | [`zsh-zinit-final`](https://github.com/MenkeTechnologies/zsh-zinit-final) | [![CI](https://github.com/MenkeTechnologies/zsh-zinit-final/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-zinit-final/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zsh-zinit-final?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zsh-zinit-final/tags) |
| 4 — Zsh ecosystem plugins | [`fasd-simple`](https://github.com/MenkeTechnologies/fasd-simple) | [![CI](https://github.com/MenkeTechnologies/fasd-simple/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fasd-simple/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/fasd-simple?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/fasd-simple/tags) |
| 4 — Zsh ecosystem plugins | [`fzf-tab`](https://github.com/MenkeTechnologies/fzf-tab) | [![CI](https://github.com/MenkeTechnologies/fzf-tab/actions/workflows/test.yaml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-tab/actions/workflows/test.yaml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/fzf-tab?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/fzf-tab/tags) |
| 4 — Zsh ecosystem plugins | [`fzf-zsh-plugin`](https://github.com/MenkeTechnologies/fzf-zsh-plugin) | [![CI](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/ci.yml) [![awesomebot](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/awesomebot.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/awesomebot.yml) [![superlinter](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/superlinter.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/superlinter.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/fzf-zsh-plugin?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/tags) |
| 4 — Zsh ecosystem plugins | [`gh_reveal`](https://github.com/MenkeTechnologies/gh_reveal) | [![CI](https://github.com/MenkeTechnologies/gh_reveal/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/gh_reveal/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/gh_reveal?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/gh_reveal/tags) |
| 4 — Zsh ecosystem plugins | [`jhipster-oh-my-zsh-plugin`](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin) | [![CI](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/jhipster-oh-my-zsh-plugin?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin/tags) |
| 4 — Zsh ecosystem plugins | [`kubectl-aliases`](https://github.com/MenkeTechnologies/kubectl-aliases) | [![CI](https://github.com/MenkeTechnologies/kubectl-aliases/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/kubectl-aliases/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/kubectl-aliases?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/kubectl-aliases/tags) |
| 4 — Zsh ecosystem plugins | [`revolver`](https://github.com/MenkeTechnologies/revolver) | [![CI](https://github.com/MenkeTechnologies/revolver/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/revolver/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/revolver?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/revolver/tags) |
| 4 — Zsh ecosystem plugins | [`zunit`](https://github.com/MenkeTechnologies/zunit) | [![CI](https://github.com/MenkeTechnologies/zunit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zunit/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zunit?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zunit/tags) |
| 5 — Editor / multiplexer plugins | [`VimColorSchemes`](https://github.com/MenkeTechnologies/VimColorSchemes) | [![CI](https://github.com/MenkeTechnologies/VimColorSchemes/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/VimColorSchemes/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/VimColorSchemes?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/VimColorSchemes/tags) |
| 5 — Editor / multiplexer plugins | [`vim-stryke`](https://github.com/MenkeTechnologies/vim-stryke) | [![CI](https://github.com/MenkeTechnologies/vim-stryke/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/vim-stryke/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/vim-stryke?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/vim-stryke/tags) |
| 5 — Editor / multiplexer plugins | [`vscode-stryke`](https://github.com/MenkeTechnologies/vscode-stryke) | [![CI](https://github.com/MenkeTechnologies/vscode-stryke/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/vscode-stryke/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/vscode-stryke?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/vscode-stryke/tags) |
| 5 — Editor / multiplexer plugins | [`emacs-stryke`](https://github.com/MenkeTechnologies/emacs-stryke) | [![CI](https://github.com/MenkeTechnologies/emacs-stryke/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/emacs-stryke/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/emacs-stryke?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/emacs-stryke/tags) |
| 5 — Editor / multiplexer plugins | [`vim-zsh`](https://github.com/MenkeTechnologies/vim-zsh) | [![CI](https://github.com/MenkeTechnologies/vim-zsh/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/vim-zsh/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/vim-zsh?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/vim-zsh/tags) |
| 5 — Editor / multiplexer plugins | [`vscode-zsh`](https://github.com/MenkeTechnologies/vscode-zsh) | [![CI](https://github.com/MenkeTechnologies/vscode-zsh/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/vscode-zsh/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/vscode-zsh?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/vscode-zsh/tags) |
| 5 — Editor / multiplexer plugins | [`emacs-zsh`](https://github.com/MenkeTechnologies/emacs-zsh) | [![CI](https://github.com/MenkeTechnologies/emacs-zsh/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/emacs-zsh/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/emacs-zsh?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/emacs-zsh/tags) |
| 5 — Editor / multiplexer plugins | [`tmux-fzf-url`](https://github.com/MenkeTechnologies/tmux-fzf-url) | [![CI](https://github.com/MenkeTechnologies/tmux-fzf-url/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/tmux-fzf-url/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/tmux-fzf-url?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/tmux-fzf-url/tags) |
| 6 — Apps, extensions, web & web-APIs | [`zpwrchrome`](https://github.com/MenkeTechnologies/zpwrchrome) | [![CI](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/release-host.yml/badge.svg)](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/release-host.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zpwrchrome?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zpwrchrome/tags) |
| 6 — Apps, extensions, web & web-APIs | [`storageshower`](https://github.com/MenkeTechnologies/storageshower) | [![CI](https://github.com/MenkeTechnologies/storageshower/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/storageshower/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/storageshower/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/storageshower/actions/workflows/release.yml) | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/storageshower?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/storageshower/tags) |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-jobs`](https://github.com/MenkeTechnologies/zpwr-jobs) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`MenkeTechnologies.github.io`](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io) | [![CI](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/MenkeTechnologies.github.io?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io/tags) |
| 6 — Apps, extensions, web & web-APIs | [`api-rest-generator`](https://github.com/MenkeTechnologies/api-rest-generator) | [![CI](https://github.com/MenkeTechnologies/api-rest-generator/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/api-rest-generator/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/api-rest-generator?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/api-rest-generator/tags) |
| 6 — Apps, extensions, web & web-APIs | [`LearningCollectionAPI`](https://github.com/MenkeTechnologies/LearningCollectionAPI) | [![CI](https://github.com/MenkeTechnologies/LearningCollectionAPI/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/LearningCollectionAPI/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/LearningCollectionAPI?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/LearningCollectionAPI/tags) |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-synth`](https://github.com/MenkeTechnologies/zpwr-synth) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-fx`](https://github.com/MenkeTechnologies/zpwr-fx) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-midi-fx`](https://github.com/MenkeTechnologies/zpwr-midi-fx) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-patch-core`](https://github.com/MenkeTechnologies/zpwr-patch-core) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-hooks-editor`](https://github.com/MenkeTechnologies/zpwr-hooks-editor) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-i18n`](https://github.com/MenkeTechnologies/zpwr-i18n) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-theme`](https://github.com/MenkeTechnologies/zpwr-theme) | [![CI](https://github.com/MenkeTechnologies/zpwr-theme/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zpwr-theme/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/zpwr-theme?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/zpwr-theme/tags) |
| 6 — Apps, extensions, web & web-APIs | [`app-store`](https://github.com/MenkeTechnologies/app-store) | [![CI](https://github.com/MenkeTechnologies/app-store/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/app-store/actions/workflows/ci.yml) | — | [![Version](https://img.shields.io/github/v/tag/MenkeTechnologies/app-store?sort=semver&label=&color=blue)](https://github.com/MenkeTechnologies/app-store/tags) |
| 6 — Apps, extensions, web & web-APIs | [`zpwr-license`](https://github.com/MenkeTechnologies/zpwr-license) | — | — | — |
| 6 — Apps, extensions, web & web-APIs | [`MenkeTechnologiesPublications`](https://github.com/MenkeTechnologies/MenkeTechnologiesPublications) | — | — | — |

## [0x03] COMMON OPERATIONS

### Pull every submodule to its remote tip

```bash
git submodule update --remote --merge
```

`--remote` fetches the latest commit from each submodule's tracking branch (defaults to the remote's default branch). `--merge` merges local + remote rather than detaching HEAD.

### Status across all submodules at once

```bash
git submodule foreach --recursive 'git status -s'
```

Shows uncommitted changes inside every submodule. Use `--quiet` to suppress the per-submodule banner.

### Pull (fast-forward) every submodule

```bash
git submodule foreach --recursive 'git pull --ff-only || true'
```

`|| true` keeps the loop going even if one submodule has unrelated history.

### Commit + push from inside one submodule

```bash
cd strykelang
git commit -am 'feat: ...'
git push
cd ..
git add strykelang
git commit -m 'bump strykelang pointer'
git push
```

The outer meta-repo commit records the new SHA the submodule points to.

### List every submodule with its pinned SHA

```bash
git submodule status
```

Prefix `+` means the working tree diverges from the pinned SHA; `-` means the submodule isn't initialized.

---

## [0x04] HELPER SCRIPTS

The `bin/` directory ships a few wrappers for common operations. All are POSIX shell with no dependencies beyond `git`, except `gen-ci-board` (bash + authenticated `gh`).

| Script | What it does |
|---|---|
| [`bin/pull-all`](bin/pull-all) | Pull every submodule to its tracking-branch tip in parallel. |
| [`bin/status-all`](bin/status-all) | One-line status for every submodule (branch + ahead/behind + dirty marker). |
| [`bin/foreach`](bin/foreach) | Run an arbitrary shell command inside every submodule. |
| [`bin/sync-pointers`](bin/sync-pointers) | After running pull-all, stage + commit all submodule pointer bumps in one commit. |
| [`bin/release-all`](bin/release-all) | Coordinated `Cargo.toml` bump + commit + tag + push across every submodule that backs a homebrew formula. |
| [`bin/gen-ci-board`](bin/gen-ci-board) | Regenerate the [\[0x02\] CI Status Board](#0x02-ci-status-board) from the submodule map + live workflow lists (`--in-place` splices README.md). |

```bash
# pull everything
./bin/pull-all

# what's dirty?
./bin/status-all

# build every Rust project
./bin/foreach 'test -f Cargo.toml && cargo build --release || true'

# bump every pointer to current submodule HEAD
./bin/sync-pointers && git push

# preview a coordinated patch-bump across every formula-backed crate
./bin/release-all --dry-run

# cut a minor release across two crates and push tags
./bin/release-all --bump=minor --only=awkrs,zshrs
```

`release-all` reads `homebrew-menketech/Formula/*.rb` to learn which submodules ship as binaries, derives the tag prefix from each formula's release URL (so `awkrs` gets `vX.Y.Z` and `zpwrchrome-host` gets `host-vX.Y.Z`), and dedupes formulae that share a repo (e.g. `zshrs.rb` + `zshrs-all.rb` → one bump). It does **not** regenerate the formulae — each crate's release CI builds the artifacts; once those exist, update `Formula/*.rb` (url + sha256 + version) and commit the tap.

---

## [0x05] UPDATING SUBMODULE POINTERS

A submodule entry in `.gitmodules` points to a specific commit SHA in the submodule's history. The meta repo doesn't auto-follow new commits — you bump the pointer explicitly.

```bash
# fetch latest commits from every remote
git submodule foreach --recursive 'git fetch --quiet'

# fast-forward each submodule to its tracking branch tip
git submodule update --remote --merge

# stage + commit the new SHAs
git add .
git commit -m 'submodules: weekly pointer sync'
git push
```

Or use the helper:

```bash
./bin/pull-all && ./bin/sync-pointers && git push
```

---

## [0x06] PER-HOST SETUP

### macOS / Linux

```bash
# prereq: git 2.13+ (parallel submodule clones) and ~3 GB free
git clone --recurse-submodules -j 8 https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta

# build the Rust CLIs
./bin/foreach 'test -f Cargo.toml && cargo build --release || true'

# install zpwr (the terminal OS)
./zpwr/install/zpwrInstall.sh

# install any CLI tool via the unified homebrew tap (11 formulas: awkrs, iftoprs, lsofrs, nmaprs, powerliners, storageshower, stryke, temprs, zpwrchrome-host, zshrs, zshrs-all)
brew tap MenkeTechnologies/menketech
brew install stryke zshrs lsofrs iftoprs awkrs nmaprs temprs powerliners storageshower zpwrchrome-host
# `zshrs-all` is the full zshrs install (shell + zd client + recorder +
# daemon). It conflicts_with `zshrs` — pick one. Use `zshrs-all` if you
# want the recorder/daemon tooling alongside the shell binary.
```

### CI / Docker

```dockerfile
FROM rust:1-bookworm
RUN git clone --recurse-submodules -j 8 \
    https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git /workspace
WORKDIR /workspace
RUN ./bin/foreach 'test -f Cargo.toml && cargo build --release || true'
```

### Air-gapped / mirror

The meta repo is mirror-friendly — every submodule URL is unauthenticated HTTPS to a single `MenkeTechnologies/<repo>.git` namespace. Mirror with:

```bash
git clone --recurse-submodules --mirror https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
```

---

## [0x07] WORKING INSIDE A SUBMODULE

Submodules check out in **detached HEAD** state at the pinned SHA. Before committing changes:

```bash
cd strykelang
git checkout main          # detach -> branch
# make changes, commit, push
git push origin main
cd ..
git add strykelang         # record the new SHA in the meta repo
git commit -m 'bump strykelang'
git push
```

To make `git submodule update` always check out the tracking branch instead of detaching:

```bash
git config -f .gitmodules submodule.strykelang.update merge
git config -f .gitmodules submodule.strykelang.branch main
git commit -am 'config: track strykelang main branch'
```

---

## [0x08] DISK FOOTPRINT

Measured fresh-clone size (working tree + `.git/modules/`, after `git clone --recurse-submodules`):

| Tier | Repos | Approx size |
|---|---|---|
| Tier 1 — Core | 17 | ~805 MB |
| Tier 2 — Stryke ecosystem | 32 | ~38 MB |
| Tier 3 — zsh-more-completions | 1 | ~203 MB |
| Tier 4 — Zsh ecosystem plugins | 28 | ~66 MB |
| Tier 5 — Editor / multiplexer plugins | 5 | ~12 MB |
| Tier 6 — Apps, extensions, web & web-APIs | 14 | ~1.06 GB |
| **Total** | **100** | **~2.2 GB** |

The bulk is in `MenkeTechnologies.github.io/` (~514 MB — accumulated screenshot history), `strykelang/` (~352 MB — vendored compiler/runtime sources), `zsh-more-completions/` (~203 MB), `Audio-Haxor/` (~161 MB — Tauri v2 frontend assets + JUCE C++), and `zshrs/` (~120 MB). `MenkeTechnologiesPublications/` itself is small (~22 MB of books/PDFs/tex), but it vendors `strykelang`, `zshrs`, and `zpwr` as its own `src/` submodules, so a full recursive clone re-fetches those three (~500 MB) a second time under it. Cargo `target/` directories are `.gitignore`d and re-derived during build. Numbers refresh as repos add commits — current counts are from a fresh recursive clone.

To save space on a host where you only need a subset, init only those:

```bash
git clone https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta
git submodule init strykelang zshrs lsofrs    # init only what you want
git submodule update --depth 1                # shallow clone for the initialized set
```

---

## [0x09] CODE VOLUME

Measured with `tokei 14.0.0` across the full recursive working tree. **Code** is source lines only (blanks and comments excluded). `.stk` (stryke source) has no `tokei` lexer, so its code is counted separately as non-blank, non-`#`-comment lines — the same definition `tokei` uses. Build artifacts (`target/`, `node_modules/`, `.cargo/`), all `vendor/` trees (incl. the vendored fish source at `zshrs/vendor/fish/` and the upstream Python powerline under `powerliners/vendor/`), and the `MenkeTechnologiesPublications/src/{zshrs,strykelang,zpwr}` nested submodules (identical files already counted under their own top-level checkouts), the third-party audio-framework submodules `zpwr-fx/libs/JUCE` + `zpwr-fx/libs/clap-juce-extensions` (the JUCE and CLAP frameworks — not authored here), and the nested plugin-library submodules `*/libs/zpwr-patch-core` + `*/libs/zpwr-daw` (the JUCE plugins vendor each other under `libs/`; identical files already counted under their own top-level checkouts) are excluded so nothing is double-counted or wrongly attributed.

| Language | Code | Files |
|---|---:|---:|
| Rust | 2,355,499 | 6,286 |
| JSON | 1,964,774 | 365 |
| Perl | 1,904,744 | 19,746 |
| JavaScript | 453,942 | 2,800 |
| Zsh | 280,215 | 1,301 |
| HTML | 217,676 | 1,025 |
| Stryke (`.stk`) | 201,028 | 3,382 |
| TeX | 138,233 | 13 |
| Vim Script | 115,282 | 748 |
| AWK | 82,368 | 2,191 |
| CSS | 67,069 | 138 |
| C Header | 66,561 | 183 |
| Shell | 66,535 | 1,989 |
| C++ | 60,881 | 106 |
| C | 45,218 | 22 |
| Python | 33,291 | 521 |
| SQL | 29,187 | 118 |
| Kotlin | 23,672 | 173 |
| **Total** | **8,137,952** | **41,877** |

The JSON mass is dominated by `traderview` frontend i18n — 27 locale files at ~1.58M lines — plus `zpwr-synth` factory-preset banks (~188k); the remainder is fixtures, completion data, and bytecode/cache snapshots. The Perl mass is `strykelang/parity/cases` — 19,505 hand-written parity scripts that pin `strykelang` behavior 1:1 against Perl 5.

Largest single repos by source (same exclusions; `.stk` counted as above):

| Repo | Primary | Secondary |
|---|---:|---:|
| `traderview` | Rust 751,329 | JavaScript 310,801 |
| `zshrs` | Rust 436,672 | Zsh 50,324 |
| `strykelang` | Rust 410,176 | Stryke 162,462 · Perl 1.9M |
| `Audio-Haxor` | Rust 138,557 | JavaScript 68,248 |
| `fusevm` | Rust 127,470 | — |
| `zpwr` | Zsh 74,539 | Shell 8,197 |
| `powerliners` | Rust 62,996 | — |
| `awkrs` | AWK 82,138 | Rust 47,700 |

Numbers refresh as repos add commits — regenerate with `tokei` (plus the `.stk` awk pass) from a fresh recursive clone.

### Against a typical engineer-career

Every line above is hand-authored. The standard software-engineering productivity figures (Brooks' *Mythical Man-Month*, COCOMO, Capers Jones) put *net maintained* output at roughly 20–100 lines/day sustained — call a 40-year career ~9,200 working days. The multiple below is `8,137,952 ÷ (rate × 9,200)`:

| Net LOC/day baseline | Career total | This tree ÷ baseline |
|---:|---:|---:|
| 100/day (optimistic ceiling) | ~920,000 | **~8.8×** |
| 50/day (mid estimate) | ~460,000 | ~18× |
| 20/day (conservative) | ~184,000 | ~44× |

The defensible floor is **≥8 engineer-careers of authored code, produced in one** — it uses the *highest* productivity baseline, so the multiple only grows under any more realistic assumption. The baseline is an industry estimate, not a measured value; the 8.1M is measured (`tokei` + the `.stk` pass). This is line-volume, not a claim about impact or difficulty.

---

## [0xFF] LICENSE

MIT License — Jacob Menke. See [LICENSE](LICENSE).

Each submodule retains its own license; see the `LICENSE` file inside each submodule directory.
