```
 ███╗   ███╗███████╗████████╗ █████╗
 ████╗ ████║██╔════╝╚══██╔══╝██╔══██╗
 ██╔████╔██║█████╗     ██║   ███████║
 ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║
 ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║
 ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
```

[![Submodules](https://img.shields.io/badge/submodules-70-blue.svg)](#0x01-submodule-map)
[![Tier 1](https://img.shields.io/badge/tier_1-12_core-cyan.svg)](#tier-1--core-12)
[![Tier 2](https://img.shields.io/badge/tier_2-22_stryke-green.svg)](#tier-2--stryke-ecosystem-22)
[![Tier 3](https://img.shields.io/badge/tier_3-1_completions-magenta.svg)](#tier-3--zsh-more-completions-1)
[![Tier 4](https://img.shields.io/badge/tier_4-28_zsh_plugins-yellow.svg)](#tier-4--zsh-ecosystem-plugins-28)
[![Tier 5](https://img.shields.io/badge/tier_5-2_editor%20%2F%20tmux-purple.svg)](#tier-5--editor--multiplexer-plugins-2)
[![Tier 6](https://img.shields.io/badge/tier_6-5_apps_+_web%20+%20APIs-orange.svg)](#tier-6--apps-extensions-web--web-apis-5)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### `[META REPO // 70 SUBMODULES // ONE COMMAND, EVERY MENKETECHNOLOGIES PROJECT]`

> *"One repo to rule them all, one repo to fetch them, one repo to bring them all, and on every host bind them."*

**MenkeTechnologiesMeta** is a single umbrella repo that vendors every active [MenkeTechnologies](https://github.com/MenkeTechnologies) project as a git submodule. Clone once with `--recurse-submodules` and a fresh host has the entire stack: `strykelang` (the language), `zshrs` (the shell), `fusevm` (the bytecode VM), `lsofrs` / `awkrs` / `temprs` / `nmaprs` / `powerliners` (the Rust CLI tools), `iftoprs` / `storageshower` (TUIs), `Audio-Haxor` / `traderview` (Tauri v2 desktop GUI apps), `zpwr` (the terminal OS), the 22-repo stryke ecosystem (`stryke-aws`, `stryke-k8s`, `stryke-kafka`, `stryke-gui`, `stryke-polars`, `stryke-utils`, ...), the 28-repo zsh plugin family (`zsh-more-completions`, `zsh-expand`, `zsh-cargo-completion`, `fzf-tab`, `revolver`, `zunit`, ...), editor / multiplexer plugins (`VimColorSchemes`, `tmux-fzf-url`), the Chrome extension (`zpwrchrome`), the public website (`MenkeTechnologies.github.io`), and the web-API services `api-rest-generator` and `LearningCollectionAPI`.

### [`MenkeTechnologies on GitHub`](https://github.com/MenkeTechnologies) &middot; [`strykelang`](https://github.com/MenkeTechnologies/strykelang) · [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

---

## Table of Contents

- [\[0x00\] Quick Start](#0x00-quick-start)
- [\[0x01\] Submodule Map](#0x01-submodule-map)
  - [Tier 1 — Core (12)](#tier-1--core-12)
  - [Tier 2 — Stryke ecosystem (22)](#tier-2--stryke-ecosystem-22)
  - [Tier 3 — zsh-more-completions (1)](#tier-3--zsh-more-completions-1)
  - [Tier 4 — Zsh ecosystem plugins (28)](#tier-4--zsh-ecosystem-plugins-28)
  - [Tier 5 — Editor / multiplexer plugins (2)](#tier-5--editor--multiplexer-plugins-2)
  - [Tier 6 — Apps, extensions, web & web-APIs (5)](#tier-6--apps-extensions-web--web-apis-5)
- [\[0x02\] CI Status Board](#0x02-ci-status-board)
- [\[0x03\] Common Operations](#0x03-common-operations)
- [\[0x04\] Helper Scripts](#0x04-helper-scripts)
- [\[0x05\] Updating Submodule Pointers](#0x05-updating-submodule-pointers)
- [\[0x06\] Per-Host Setup](#0x06-per-host-setup)
- [\[0x07\] Working Inside a Submodule](#0x07-working-inside-a-submodule)
- [\[0x08\] Disk Footprint](#0x08-disk-footprint)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] QUICK START

**Fresh host — clone everything in one shot:**

```bash
git clone --recurse-submodules https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta
```

The `--recurse-submodules` flag fetches all 70 submodules in parallel during the initial clone.

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

All 70 submodules sit flat at the repository root. URLs are HTTPS for fresh-host portability (no SSH key needed for `clone --recurse`).

### Tier 1 — Core (12)

The set of MenkeTechnologies projects that share the unified `strykelang`-authored documentation template (README header, ToC convention `[0xNN]`, `docs/index.html` chrome, `docs/report.html` engineering report, `man/man1/<name>.1` + `<name>all.1` man pages).

| Project | What it is |
|---|---|
| [`strykelang`](https://github.com/MenkeTechnologies/strykelang) | The fastest dynamic language for parallel ops. Perl 5 interpreter in Rust, bytecode VM + Cranelift JIT, 10,435 builtins. &middot; <sub>[docs](https://menketechnologies.github.io/strykelang/) · [report](https://menketechnologies.github.io/strykelang/report.html) · [reference](https://menketechnologies.github.io/strykelang/reference.html)</sub> |
| [`zshrs`](https://github.com/MenkeTechnologies/zshrs) | The first compiled Unix shell. 1:1 zsh C-port + extensions, persistent worker pool, AOP intercept, rkyv bytecode cache. &middot; <sub>[docs](https://menketechnologies.github.io/zshrs/) · [report](https://menketechnologies.github.io/zshrs/report.html) · [reference](https://menketechnologies.github.io/zshrs/reference.html)</sub> |
| [`fusevm`](https://github.com/MenkeTechnologies/fusevm) | Language-agnostic bytecode VM with fused superinstructions and 3-tier Cranelift JIT. The execution engine behind strykelang, zshrs, awkrs. &middot; <sub>[docs](https://menketechnologies.github.io/fusevm/) · [report](https://menketechnologies.github.io/fusevm/report.html)</sub> |
| [`lsofrs`](https://github.com/MenkeTechnologies/lsofrs) | Rust rewrite of `lsof` — 5–21× faster, **7-tab TUI** (ratatui), 31 cyberpunk themes. &middot; <sub>[docs](https://menketechnologies.github.io/lsofrs/) · [report](https://menketechnologies.github.io/lsofrs/report.html)</sub> |
| [`temprs`](https://github.com/MenkeTechnologies/temprs) | Temporary file stack manager. Atomic `flock`-protected master record, dual indexing (position or `@name`). &middot; <sub>[docs](https://menketechnologies.github.io/temprs/) · [report](https://menketechnologies.github.io/temprs/report.html)</sub> |
| [`awkrs`](https://github.com/MenkeTechnologies/awkrs) | AWK in Rust. Bytecode VM + Cranelift JIT + persistent rkyv bytecode cache + parallel records. &middot; <sub>[docs](https://menketechnologies.github.io/awkrs/) · [report](https://menketechnologies.github.io/awkrs/report.html)</sub> |
| [`iftoprs`](https://github.com/MenkeTechnologies/iftoprs) | Real-time bandwidth monitor. **TUI** built on ratatui, 31 themes, process attribution via `lsof`, NDJSON streaming. &middot; <sub>[docs](https://menketechnologies.github.io/iftoprs/) · [report](https://menketechnologies.github.io/iftoprs/report.html)</sub> |
| [`Audio-Haxor`](https://github.com/MenkeTechnologies/Audio-Haxor) | **Tauri v2 desktop GUI app** + JUCE engine. VST2/VST3/AU/CLAP scanner, sample vault, DAW project index, KVR version checker. &middot; <sub>[docs](https://menketechnologies.github.io/Audio-Haxor/) · [report](https://menketechnologies.github.io/Audio-Haxor/report.html)</sub> |
| [`traderview`](https://github.com/MenkeTechnologies/traderview) | **Tauri v2 desktop GUI app** (sibling to Audio-Haxor) — TraderVue-style trading journal with embedded Postgres, vanilla JS + uPlot frontend. The same Rust workspace crates also ship a multi-user axum web service. &middot; <sub>[docs](https://menketechnologies.github.io/traderview/) · [report](https://menketechnologies.github.io/traderview/report.html)</sub> |
| [`nmaprs`](https://github.com/MenkeTechnologies/nmaprs) | Rust port of `nmap`. Full async TCP/UDP/SCTP/IP-protocol scans, idle/zombie scans, NSE-style script probes, ARP/ICMP/timestamp/mask host discovery, top-ports list embedded. &middot; <sub>[docs](https://menketechnologies.github.io/nmaprs/) · [report](https://menketechnologies.github.io/nmaprs/report.html)</sub> |
| [`powerliners`](https://github.com/MenkeTechnologies/powerliners) | **Rust CLI** — mature port of Python's [`powerline-status`](https://github.com/powerline/powerline) (v0.2.15, 3,000+ `#[test]` functions, 5-binary suite: `powerline` / `powerline-daemon` / `powerline-config` / `powerline-render` / `powerline-lint`, parity-tested against upstream Python). Drop-in for tmux / zsh / bash / vim with sub-millisecond render replacing the ~100 ms python startup tax. &middot; <sub>[docs](https://menketechnologies.github.io/powerliners/) · [report](https://menketechnologies.github.io/powerliners/report.html)</sub> |
| [`zpwr`](https://github.com/MenkeTechnologies/zpwr) | The terminal OS. 461 verbs, 190k LOC, zinit-based, stryke-powered. ⭐ 221 &middot; <sub>[docs](https://menketechnologies.github.io/zpwr/) · [report](https://menketechnologies.github.io/zpwr/report.html)</sub> |

### Tier 2 — Stryke ecosystem (22)

MenkeTechnologies distribution (single tap for every CLI tool) + per-service connector libraries for `stryke`.

| Project | What it is |
|---|---|
| [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) | Single Homebrew tap for 11 MenkeTechnologies CLI formulas (`awkrs` / `iftoprs` / `lsofrs` / `nmaprs` / `powerliners` / `storageshower` / `stryke` / `temprs` / `zpwrchrome-host` / `zshrs` / `zshrs-all`). Formulas auto-bumped by each tool's `Release` workflow via `HOMEBREW_TAP_TOKEN`. |
| [`stryke-arrow`](https://github.com/MenkeTechnologies/stryke-arrow) | Apache Arrow integration. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-arrow/) · [report](https://menketechnologies.github.io/stryke-arrow/report.html)</sub> |
| [`stryke-aws`](https://github.com/MenkeTechnologies/stryke-aws) | AWS SDK bindings (S3, EC2, SQS, Lambda, ...). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-aws/) · [report](https://menketechnologies.github.io/stryke-aws/report.html)</sub> |
| [`stryke-demo`](https://github.com/MenkeTechnologies/stryke-demo) | Demo scripts + example programs. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-demo/) · [report](https://menketechnologies.github.io/stryke-demo/report.html)</sub> |
| [`stryke-docker`](https://github.com/MenkeTechnologies/stryke-docker) | Docker engine API client. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-docker/) · [report](https://menketechnologies.github.io/stryke-docker/report.html)</sub> |
| [`stryke-duckdb`](https://github.com/MenkeTechnologies/stryke-duckdb) | DuckDB embedded analytics. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-duckdb/) · [report](https://menketechnologies.github.io/stryke-duckdb/report.html)</sub> |
| [`stryke-fleet`](https://github.com/MenkeTechnologies/stryke-fleet) | Parallel expect/PTY automation — transcripted sessions, declarative playbooks, recipe corpus for interactive CLIs, multi-host fan-out. Pure stryke, loaded on `use Fleet`. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-fleet/) · [report](https://menketechnologies.github.io/stryke-fleet/report.html)</sub> |
| [`stryke-gcp`](https://github.com/MenkeTechnologies/stryke-gcp) | Google Cloud Platform SDK bindings. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-gcp/) · [report](https://menketechnologies.github.io/stryke-gcp/report.html)</sub> |
| [`stryke-grpc`](https://github.com/MenkeTechnologies/stryke-grpc) | gRPC client/server. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-grpc/) · [report](https://menketechnologies.github.io/stryke-grpc/report.html)</sub> |
| [`stryke-gui`](https://github.com/MenkeTechnologies/stryke-gui) | GUI automation bridge — `stryke_gui` cdylib `dlopen`ed in-process on `use GUI`, fronting mouse/keyboard synthesis (enigo) + screen capture (xcap). Persistent `Enigo` handle in `OnceCell`, no fork-per-call. Isolates X11 / Wayland / CGEvent / SendInput linkage out of the stryke core. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-gui/) · [report](https://menketechnologies.github.io/stryke-gui/report.html)</sub> |
| [`stryke-k8s`](https://github.com/MenkeTechnologies/stryke-k8s) | Kubernetes API client. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-k8s/) · [report](https://menketechnologies.github.io/stryke-k8s/report.html)</sub> |
| [`stryke-kafka`](https://github.com/MenkeTechnologies/stryke-kafka) | Kafka producer/consumer (rdkafka bindings). &middot; <sub>[docs](https://menketechnologies.github.io/stryke-kafka/) · [report](https://menketechnologies.github.io/stryke-kafka/report.html)</sub> |
| [`stryke-mcpd`](https://github.com/MenkeTechnologies/stryke-mcpd) | MCP servers as single native binaries — validated tool specs, crash-isolated serving, root-jailed stock tool pack. Pure stryke, loaded on `use Mcpd`. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mcpd/) · [report](https://menketechnologies.github.io/stryke-mcpd/report.html)</sub> |
| [`stryke-mongo`](https://github.com/MenkeTechnologies/stryke-mongo) | MongoDB driver. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mongo/) · [report](https://menketechnologies.github.io/stryke-mongo/report.html)</sub> |
| [`stryke-mysql`](https://github.com/MenkeTechnologies/stryke-mysql) | MySQL/MariaDB driver. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-mysql/) · [report](https://menketechnologies.github.io/stryke-mysql/report.html)</sub> |
| [`stryke-parquet`](https://github.com/MenkeTechnologies/stryke-parquet) | Apache Parquet read/write. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-parquet/) · [report](https://menketechnologies.github.io/stryke-parquet/report.html)</sub> |
| [`stryke-polars`](https://github.com/MenkeTechnologies/stryke-polars) | Full pandas + numpy surface — DataFrame/Series/Index/IO + ndarray/ufuncs/linalg/random/fft/polynomial/masked/datetime64 — in one cdylib, `dlopen`ed in-process on `use Polars`. Heavy deps kept out of the stryke core. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-polars/) · [report](https://menketechnologies.github.io/stryke-polars/report.html)</sub> |
| [`stryke-postgres`](https://github.com/MenkeTechnologies/stryke-postgres) | PostgreSQL driver. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-postgres/) · [report](https://menketechnologies.github.io/stryke-postgres/report.html)</sub> |
| [`stryke-redis`](https://github.com/MenkeTechnologies/stryke-redis) | Redis client. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-redis/) · [report](https://menketechnologies.github.io/stryke-redis/report.html)</sub> |
| [`stryke-selenium`](https://github.com/MenkeTechnologies/stryke-selenium) | Selenium WebDriver bindings — browser automation. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-selenium/) · [report](https://menketechnologies.github.io/stryke-selenium/report.html)</sub> |
| [`stryke-spark`](https://github.com/MenkeTechnologies/stryke-spark) | Apache Spark integration. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-spark/) · [report](https://menketechnologies.github.io/stryke-spark/report.html)</sub> |
| [`stryke-utils`](https://github.com/MenkeTechnologies/stryke-utils) | Pure stryke library — shared helpers written in stryke itself, no Rust or external deps. &middot; <sub>[docs](https://menketechnologies.github.io/stryke-utils/) · [report](https://menketechnologies.github.io/stryke-utils/report.html)</sub> |

### Tier 3 — zsh-more-completions (1)

| Project | What it is |
|---|---|
| [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) | 38,940-completion zsh corpus (8,360 `src/` + 26,105 `more_src/`–`more_src3/` + 3,398 `man_src/` + 1,067 `architecture_src/` + 10 `override_src/`; counts `_*` completion functions only — produced by `scripts/print-repo-stats.zsh`). ⭐ 56. The largest curated completion collection in existence. Lives outside Tier 1 because it's data + completion functions, not an executable. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-more-completions/) · [report](https://menketechnologies.github.io/zsh-more-completions/report.html)</sub> |

### Tier 4 — Zsh ecosystem plugins (28)

The plugin family that `zpwr` and any zsh user can load via zinit / oh-my-zsh. The full `ZPWR_GH_PLUGINS` canonical list plus the legacy zsh-* family.

| Project | What it is |
|---|---|
| [`zsh-expand`](https://github.com/MenkeTechnologies/zsh-expand) | Expand aliases / global aliases / typos on space. ⭐ 42. &middot; <sub>[docs](https://menketechnologies.github.io/zsh-expand/) · [report](https://menketechnologies.github.io/zsh-expand/report.html)</sub> |
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
| [`zsh-openshift-aliases`](https://github.com/MenkeTechnologies/zsh-openshift-aliases) | 52 `oc`-* aliases + login macros (`ocdev`, `ocqa`) + auto-sourced `oc` completion. |
| [`zsh-travis`](https://github.com/MenkeTechnologies/zsh-travis) | `tg`/`tb`/`tbr`/`tpr` — open Travis CI build pages from inside the project. |
| [`zsh-very-colorful-manuals`](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals) | Neon-tints `man` page output via `LESS_TERMCAP_*` env. |
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

### Tier 5 — Editor / multiplexer plugins (2)

Plugins that target Vim/Neovim and tmux rather than zsh proper.

| Project | What it is |
|---|---|
| [`VimColorSchemes`](https://github.com/MenkeTechnologies/VimColorSchemes) | 732 hand-curated Vim colorschemes packaged as a single Pathogen / vim-plug / lazy.nvim bundle. The largest one-bundle scheme collection. |
| [`tmux-fzf-url`](https://github.com/MenkeTechnologies/tmux-fzf-url) | Pop a fzf picker over every URL currently visible in the tmux pane; selected URL opens in the default browser. |

### Tier 6 — Apps, extensions, web & web-APIs (5)

Browser extensions, supporting apps, public website, and web-API services. (Tauri v2 desktop GUI apps `traderview` and `Audio-Haxor` live in Tier 1; the `powerliners` CLI port lives in Tier 1 too.)

| Project | What it is |
|---|---|
| [`zpwrchrome`](https://github.com/MenkeTechnologies/zpwrchrome) | Browser power-tool: UNIX `pass` integration, segmented multi-connection download manager (default Chrome takeover), JetBrains-style tab switcher with cross-window MRU + scenes + opener-tree + minimap, fzf history search, Tampermonkey-equivalent userscripts, full-page screenshot, Wappalyzer-compatible tech detection, cyberpunk page-theme injector, Turn Off the Lights cinema dimmer, reader mode, post-download custom commands, JSON viewer, UA switcher, find-in-all-tabs. Manifest V3, 54 commands (4 default-keyed + 50 user-bindable). Ships a companion Chrome theme + the **native messaging host** `zpwrchrome-host` (the Rust port of browserpass-native + the segmented downloader + `run.spawn` for post-download commands) — installable via `brew install zpwrchrome-host` from the [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) tap. &middot; <sub>[docs](https://menketechnologies.github.io/zpwrchrome/) · [report](https://menketechnologies.github.io/zpwrchrome/report.html)</sub> |
| [`storageshower`](https://github.com/MenkeTechnologies/storageshower) | Disk-usage **TUI** in Rust (sibling to iftoprs). Walks a directory tree, presents space-by-folder with sort + drill-down. |
| [`MenkeTechnologies.github.io`](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io) | Public-facing personal site / project landing page (cyberpunk HUD, static HTML + CSS). |
| [`api-rest-generator`](https://github.com/MenkeTechnologies/api-rest-generator) | **Web-API codegen tool.** Rust port (v0.2.0+) of the original Kotlin Spring-Boot-REST-API generator — feed it MySQL / PostgreSQL / SQLite / MSSQL DDL, get a fully wired Spring Boot REST backend (entities, controllers, DAOs, repositories) in Java / Kotlin / Groovy. Kotlin source preserved under `src/main/kotlin/` for reference. |
| [`LearningCollectionAPI`](https://github.com/MenkeTechnologies/LearningCollectionAPI) | **Web API.** Java/Kotlin Spring Boot REST service — backing service for the `zsh-learn` plugin (save / query / quiz / search vocabulary cards over HTTP). |

---

## [0x02] CI STATUS BOARD

Live GitHub Actions status for every submodule in one table — scan the whole org from one page; the Tier column matches the [submodule map](#0x01-submodule-map). CI badges pin each repo's default branch; Release badges show the latest tag-triggered run. `—` = no workflow yet. The board is generated from `.gitmodules` + each repo's active workflow list (`gh api repos/MenkeTechnologies/<repo>/actions/workflows`).

| Tier | Repo | CI | Release |
|---|---|---|---|
| 1 — Core | [`strykelang`](https://github.com/MenkeTechnologies/strykelang) | [![CI](https://github.com/MenkeTechnologies/strykelang/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/strykelang/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/strykelang/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/strykelang/actions/workflows/release.yml) |
| 1 — Core | [`zshrs`](https://github.com/MenkeTechnologies/zshrs) | [![CI](https://github.com/MenkeTechnologies/zshrs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zshrs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/zshrs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/zshrs/actions/workflows/release.yml) |
| 1 — Core | [`fusevm`](https://github.com/MenkeTechnologies/fusevm) | [![CI](https://github.com/MenkeTechnologies/fusevm/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fusevm/actions/workflows/ci.yml) | — |
| 1 — Core | [`lsofrs`](https://github.com/MenkeTechnologies/lsofrs) | [![CI](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/lsofrs/actions/workflows/release.yml) |
| 1 — Core | [`temprs`](https://github.com/MenkeTechnologies/temprs) | [![CI](https://github.com/MenkeTechnologies/temprs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/temprs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/temprs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/temprs/actions/workflows/release.yml) |
| 1 — Core | [`awkrs`](https://github.com/MenkeTechnologies/awkrs) | [![CI](https://github.com/MenkeTechnologies/awkrs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/awkrs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/awkrs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/awkrs/actions/workflows/release.yml) |
| 1 — Core | [`iftoprs`](https://github.com/MenkeTechnologies/iftoprs) | [![CI](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/iftoprs/actions/workflows/release.yml) |
| 1 — Core | [`Audio-Haxor`](https://github.com/MenkeTechnologies/Audio-Haxor) | [![CI](https://github.com/MenkeTechnologies/Audio-Haxor/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/Audio-Haxor/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/Audio-Haxor/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/Audio-Haxor/actions/workflows/release.yml) |
| 1 — Core | [`traderview`](https://github.com/MenkeTechnologies/traderview) | [![CI](https://github.com/MenkeTechnologies/traderview/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/traderview/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/traderview/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/traderview/actions/workflows/release.yml) |
| 1 — Core | [`nmaprs`](https://github.com/MenkeTechnologies/nmaprs) | [![CI](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/nmaprs/actions/workflows/release.yml) |
| 1 — Core | [`powerliners`](https://github.com/MenkeTechnologies/powerliners) | [![CI](https://github.com/MenkeTechnologies/powerliners/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/powerliners/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/powerliners/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/powerliners/actions/workflows/release.yml) |
| 1 — Core | [`zpwr`](https://github.com/MenkeTechnologies/zpwr) | [![CI](https://github.com/MenkeTechnologies/zpwr/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zpwr/actions/workflows/ci.yml) | — |
| 2 — Stryke ecosystem | [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) | [![CI](https://github.com/MenkeTechnologies/homebrew-menketech/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/homebrew-menketech/actions/workflows/ci.yml) | — |
| 2 — Stryke ecosystem | [`stryke-arrow`](https://github.com/MenkeTechnologies/stryke-arrow) | [![CI](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-arrow/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-aws`](https://github.com/MenkeTechnologies/stryke-aws) | [![CI](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-aws/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-demo`](https://github.com/MenkeTechnologies/stryke-demo) | [![CI](https://github.com/MenkeTechnologies/stryke-demo/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-demo/actions/workflows/ci.yml) | — |
| 2 — Stryke ecosystem | [`stryke-docker`](https://github.com/MenkeTechnologies/stryke-docker) | [![CI](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-docker/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-duckdb`](https://github.com/MenkeTechnologies/stryke-duckdb) | [![CI](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-duckdb/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-fleet`](https://github.com/MenkeTechnologies/stryke-fleet) | [![CI](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-fleet/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-gcp`](https://github.com/MenkeTechnologies/stryke-gcp) | [![CI](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-gcp/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-grpc`](https://github.com/MenkeTechnologies/stryke-grpc) | [![CI](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-grpc/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-gui`](https://github.com/MenkeTechnologies/stryke-gui) | [![CI](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-gui/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-k8s`](https://github.com/MenkeTechnologies/stryke-k8s) | [![CI](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-k8s/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-kafka`](https://github.com/MenkeTechnologies/stryke-kafka) | [![CI](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-kafka/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-mcpd`](https://github.com/MenkeTechnologies/stryke-mcpd) | [![CI](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mcpd/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-mongo`](https://github.com/MenkeTechnologies/stryke-mongo) | [![CI](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mongo/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-mysql`](https://github.com/MenkeTechnologies/stryke-mysql) | [![CI](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-mysql/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-parquet`](https://github.com/MenkeTechnologies/stryke-parquet) | [![CI](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-parquet/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-polars`](https://github.com/MenkeTechnologies/stryke-polars) | [![CI](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-polars/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-postgres`](https://github.com/MenkeTechnologies/stryke-postgres) | [![CI](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-postgres/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-redis`](https://github.com/MenkeTechnologies/stryke-redis) | [![CI](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-redis/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-selenium`](https://github.com/MenkeTechnologies/stryke-selenium) | [![CI](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-selenium/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-spark`](https://github.com/MenkeTechnologies/stryke-spark) | [![CI](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-spark/actions/workflows/release.yml) |
| 2 — Stryke ecosystem | [`stryke-utils`](https://github.com/MenkeTechnologies/stryke-utils) | [![CI](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/stryke-utils/actions/workflows/release.yml) |
| 3 — zsh-more-completions | [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) | [![CI](https://github.com/MenkeTechnologies/zsh-more-completions/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-more-completions/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-expand`](https://github.com/MenkeTechnologies/zsh-expand) | [![CI](https://github.com/MenkeTechnologies/zsh-expand/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-expand/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-cargo-completion`](https://github.com/MenkeTechnologies/zsh-cargo-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-cargo-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-cargo-completion/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-learn`](https://github.com/MenkeTechnologies/zsh-learn) | [![CI](https://github.com/MenkeTechnologies/zsh-learn/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-learn/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-git-acp`](https://github.com/MenkeTechnologies/zsh-git-acp) | [![CI](https://github.com/MenkeTechnologies/zsh-git-acp/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-git-acp/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-better-npm-completion`](https://github.com/MenkeTechnologies/zsh-better-npm-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-better-npm-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-better-npm-completion/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-cpan-completion`](https://github.com/MenkeTechnologies/zsh-cpan-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-cpan-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-cpan-completion/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-dotnet-completion`](https://github.com/MenkeTechnologies/zsh-dotnet-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-dotnet-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-dotnet-completion/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-gem-completion`](https://github.com/MenkeTechnologies/zsh-gem-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-gem-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-gem-completion/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-git-repo-cache`](https://github.com/MenkeTechnologies/zsh-git-repo-cache) | [![CI](https://github.com/MenkeTechnologies/zsh-git-repo-cache/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-git-repo-cache/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-nginx`](https://github.com/MenkeTechnologies/zsh-nginx) | [![CI](https://github.com/MenkeTechnologies/zsh-nginx/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-nginx/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-pip-description-completion`](https://github.com/MenkeTechnologies/zsh-pip-description-completion) | [![CI](https://github.com/MenkeTechnologies/zsh-pip-description-completion/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-pip-description-completion/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-sed-sub`](https://github.com/MenkeTechnologies/zsh-sed-sub) | [![CI](https://github.com/MenkeTechnologies/zsh-sed-sub/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-sed-sub/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-sudo`](https://github.com/MenkeTechnologies/zsh-sudo) | [![CI](https://github.com/MenkeTechnologies/zsh-sudo/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-sudo/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-xcode-completions`](https://github.com/MenkeTechnologies/zsh-xcode-completions) | [![CI](https://github.com/MenkeTechnologies/zsh-xcode-completions/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zsh-xcode-completions/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-docker-aliases`](https://github.com/MenkeTechnologies/zsh-docker-aliases) | [![CI](https://github.com/MenkeTechnologies/zsh-docker-aliases/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zsh-docker-aliases/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-openshift-aliases`](https://github.com/MenkeTechnologies/zsh-openshift-aliases) | [![CI](https://github.com/MenkeTechnologies/zsh-openshift-aliases/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zsh-openshift-aliases/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-travis`](https://github.com/MenkeTechnologies/zsh-travis) | [![CI](https://github.com/MenkeTechnologies/zsh-travis/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zsh-travis/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-very-colorful-manuals`](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals) | [![CI](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zsh-very-colorful-manuals/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-z`](https://github.com/MenkeTechnologies/zsh-z) | [![CI](https://github.com/MenkeTechnologies/zsh-z/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zsh-z/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zsh-zinit-final`](https://github.com/MenkeTechnologies/zsh-zinit-final) | [![CI](https://github.com/MenkeTechnologies/zsh-zinit-final/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zsh-zinit-final/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`fasd-simple`](https://github.com/MenkeTechnologies/fasd-simple) | [![CI](https://github.com/MenkeTechnologies/fasd-simple/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/fasd-simple/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`fzf-tab`](https://github.com/MenkeTechnologies/fzf-tab) | [![CI](https://github.com/MenkeTechnologies/fzf-tab/actions/workflows/test.yaml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/fzf-tab/actions/workflows/test.yaml) | — |
| 4 — Zsh ecosystem plugins | [`fzf-zsh-plugin`](https://github.com/MenkeTechnologies/fzf-zsh-plugin) | [![CI](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/ci.yml) [![awesomebot](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/awesomebot.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/awesomebot.yml) [![superlinter](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/superlinter.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/fzf-zsh-plugin/actions/workflows/superlinter.yml) | — |
| 4 — Zsh ecosystem plugins | [`gh_reveal`](https://github.com/MenkeTechnologies/gh_reveal) | [![CI](https://github.com/MenkeTechnologies/gh_reveal/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/gh_reveal/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`jhipster-oh-my-zsh-plugin`](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin) | [![CI](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/jhipster-oh-my-zsh-plugin/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`kubectl-aliases`](https://github.com/MenkeTechnologies/kubectl-aliases) | [![CI](https://github.com/MenkeTechnologies/kubectl-aliases/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/kubectl-aliases/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`revolver`](https://github.com/MenkeTechnologies/revolver) | [![CI](https://github.com/MenkeTechnologies/revolver/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/revolver/actions/workflows/ci.yml) | — |
| 4 — Zsh ecosystem plugins | [`zunit`](https://github.com/MenkeTechnologies/zunit) | [![CI](https://github.com/MenkeTechnologies/zunit/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/zunit/actions/workflows/ci.yml) | — |
| 5 — Editor / multiplexer plugins | [`VimColorSchemes`](https://github.com/MenkeTechnologies/VimColorSchemes) | [![CI](https://github.com/MenkeTechnologies/VimColorSchemes/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/VimColorSchemes/actions/workflows/ci.yml) | — |
| 5 — Editor / multiplexer plugins | [`tmux-fzf-url`](https://github.com/MenkeTechnologies/tmux-fzf-url) | [![CI](https://github.com/MenkeTechnologies/tmux-fzf-url/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/MenkeTechnologies/tmux-fzf-url/actions/workflows/ci.yml) | — |
| 6 — Apps, extensions, web & web-APIs | [`zpwrchrome`](https://github.com/MenkeTechnologies/zpwrchrome) | [![CI](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/release-host.yml/badge.svg)](https://github.com/MenkeTechnologies/zpwrchrome/actions/workflows/release-host.yml) |
| 6 — Apps, extensions, web & web-APIs | [`storageshower`](https://github.com/MenkeTechnologies/storageshower) | [![CI](https://github.com/MenkeTechnologies/storageshower/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/storageshower/actions/workflows/ci.yml) | [![Release](https://github.com/MenkeTechnologies/storageshower/actions/workflows/release.yml/badge.svg)](https://github.com/MenkeTechnologies/storageshower/actions/workflows/release.yml) |
| 6 — Apps, extensions, web & web-APIs | [`MenkeTechnologies.github.io`](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io) | [![CI](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io/actions/workflows/ci.yml) | — |
| 6 — Apps, extensions, web & web-APIs | [`api-rest-generator`](https://github.com/MenkeTechnologies/api-rest-generator) | [![CI](https://github.com/MenkeTechnologies/api-rest-generator/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/api-rest-generator/actions/workflows/ci.yml) | — |
| 6 — Apps, extensions, web & web-APIs | [`LearningCollectionAPI`](https://github.com/MenkeTechnologies/LearningCollectionAPI) | [![CI](https://github.com/MenkeTechnologies/LearningCollectionAPI/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/MenkeTechnologies/LearningCollectionAPI/actions/workflows/ci.yml) | — |

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
| Tier 1 — Core | 12 | ~804 MB |
| Tier 2 — Stryke ecosystem | 22 | ~33 MB |
| Tier 3 — zsh-more-completions | 1 | ~203 MB |
| Tier 4 — Zsh ecosystem plugins | 28 | ~66 MB |
| Tier 5 — Editor / multiplexer plugins | 2 | ~12 MB |
| Tier 6 — Apps, extensions, web & web-APIs | 5 | ~549 MB |
| **Total** | **70** | **~1.7 GB** |

The bulk is in `MenkeTechnologies.github.io/` (~514 MB — accumulated screenshot history), `strykelang/` (~352 MB — vendored compiler/runtime sources), `zsh-more-completions/` (~203 MB), `Audio-Haxor/` (~161 MB — Tauri v2 frontend assets + JUCE C++), and `zshrs/` (~120 MB). Cargo `target/` directories are `.gitignore`d and re-derived during build. Numbers refresh as repos add commits — current counts are from a fresh recursive clone.

To save space on a host where you only need a subset, init only those:

```bash
git clone https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta
git submodule init strykelang zshrs lsofrs    # init only what you want
git submodule update --depth 1                # shallow clone for the initialized set
```

---

## [0xFF] LICENSE

MIT License — Jacob Menke. See [LICENSE](LICENSE).

Each submodule retains its own license; see the `LICENSE` file inside each submodule directory.
