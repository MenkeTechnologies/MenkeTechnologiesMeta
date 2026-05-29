```
 ███╗   ███╗███████╗████████╗ █████╗
 ████╗ ████║██╔════╝╚══██╔══╝██╔══██╗
 ██╔████╔██║█████╗     ██║   ███████║
 ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║
 ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║
 ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
```

[![Submodules](https://img.shields.io/badge/submodules-64-blue.svg)](#0x01-submodule-map)
[![Tier 1](https://img.shields.io/badge/tier_1-12_core-cyan.svg)](#tier-1--core-12)
[![Tier 2](https://img.shields.io/badge/tier_2-16_stryke-green.svg)](#tier-2--stryke-ecosystem-16)
[![Tier 3](https://img.shields.io/badge/tier_3-1_completions-magenta.svg)](#tier-3--zsh-more-completions-1)
[![Tier 4](https://img.shields.io/badge/tier_4-28_zsh_plugins-yellow.svg)](#tier-4--zsh-ecosystem-plugins-28)
[![Tier 5](https://img.shields.io/badge/tier_5-2_editor%20%2F%20tmux-purple.svg)](#tier-5--editor--multiplexer-plugins-2)
[![Tier 6](https://img.shields.io/badge/tier_6-5_apps_+_web%20+%20APIs-orange.svg)](#tier-6--apps-extensions-web--web-apis-5)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### `[META REPO // 64 SUBMODULES // ONE COMMAND, EVERY MENKETECHNOLOGIES PROJECT]`

> *"One repo to rule them all, one repo to fetch them, one repo to bring them all, and on every host bind them."*

**MenkeTechnologiesMeta** is a single umbrella repo that vendors every active [MenkeTechnologies](https://github.com/MenkeTechnologies) project as a git submodule. Clone once with `--recurse-submodules` and a fresh host has the entire stack: `strykelang` (the language), `zshrs` (the shell), `fusevm` (the bytecode VM), `lsofrs` / `awkrs` / `temprs` / `nmaprs` / `powerliners` (the Rust CLI tools), `iftoprs` / `storageshower` (TUIs), `Audio-Haxor` / `traderview` (Tauri v2 desktop GUI apps), `zpwr` (the terminal OS), the 16-repo stryke ecosystem (`stryke-aws`, `stryke-k8s`, `stryke-kafka`, ...), the 28-repo zsh plugin family (`zsh-more-completions`, `zsh-expand`, `zsh-cargo-completion`, `fzf-tab`, `revolver`, `zunit`, ...), editor / multiplexer plugins (`VimColorSchemes`, `tmux-fzf-url`), the Chrome extension (`zpwrchrome`), the public website (`MenkeTechnologies.github.io`), and the web-API services `spring-boot-rest-generator` and `LearningCollectionAPI`.

### [`MenkeTechnologies on GitHub`](https://github.com/MenkeTechnologies) &middot; [`strykelang`](https://github.com/MenkeTechnologies/strykelang) · [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

---

## Table of Contents

- [\[0x00\] Quick Start](#0x00-quick-start)
- [\[0x01\] Submodule Map](#0x01-submodule-map)
  - [Tier 1 — Core (12)](#tier-1--core-12)
  - [Tier 2 — Stryke ecosystem (16)](#tier-2--stryke-ecosystem-16)
  - [Tier 3 — zsh-more-completions (1)](#tier-3--zsh-more-completions-1)
  - [Tier 4 — Zsh ecosystem plugins (28)](#tier-4--zsh-ecosystem-plugins-28)
  - [Tier 5 — Editor / multiplexer plugins (2)](#tier-5--editor--multiplexer-plugins-2)
  - [Tier 6 — Apps, extensions, web & web-APIs (5)](#tier-6--apps-extensions-web--web-apis-5)
- [\[0x02\] Common Operations](#0x02-common-operations)
- [\[0x03\] Helper Scripts](#0x03-helper-scripts)
- [\[0x04\] Updating Submodule Pointers](#0x04-updating-submodule-pointers)
- [\[0x05\] Per-Host Setup](#0x05-per-host-setup)
- [\[0x06\] Working Inside a Submodule](#0x06-working-inside-a-submodule)
- [\[0x07\] Disk Footprint](#0x07-disk-footprint)
- [\[0xFF\] License](#0xff-license)

---

## [0x00] QUICK START

**Fresh host — clone everything in one shot:**

```bash
git clone --recurse-submodules https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta
```

The `--recurse-submodules` flag fetches all 64 submodules in parallel during the initial clone.

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

All 64 submodules sit flat at the repository root. URLs are HTTPS for fresh-host portability (no SSH key needed for `clone --recurse`).

### Tier 1 — Core (12)

The set of MenkeTechnologies projects that share the unified `strykelang`-authored documentation template (README header, ToC convention `[0xNN]`, `docs/index.html` chrome, `docs/report.html` engineering report, `man/man1/<name>.1` + `<name>all.1` man pages).

| Project | What it is |
|---|---|
| [`strykelang`](https://github.com/MenkeTechnologies/strykelang) | The fastest dynamic language for parallel ops. Perl 5 interpreter in Rust, bytecode VM + Cranelift JIT, 10,431 builtins. |
| [`zshrs`](https://github.com/MenkeTechnologies/zshrs) | The first compiled Unix shell. 1:1 zsh C-port + extensions, persistent worker pool, AOP intercept, rkyv bytecode cache. |
| [`fusevm`](https://github.com/MenkeTechnologies/fusevm) | Language-agnostic bytecode VM with fused superinstructions and 3-tier Cranelift JIT. The execution engine behind strykelang, zshrs, awkrs. |
| [`lsofrs`](https://github.com/MenkeTechnologies/lsofrs) | Rust rewrite of `lsof` — 5–21× faster, **7-tab TUI** (ratatui), 31 cyberpunk themes. |
| [`temprs`](https://github.com/MenkeTechnologies/temprs) | Temporary file stack manager. Atomic `flock`-protected master record, dual indexing (position or `@name`). |
| [`awkrs`](https://github.com/MenkeTechnologies/awkrs) | AWK in Rust. Bytecode VM + Cranelift JIT + persistent rkyv bytecode cache + parallel records. |
| [`iftoprs`](https://github.com/MenkeTechnologies/iftoprs) | Real-time bandwidth monitor. **TUI** built on ratatui, 31 themes, process attribution via `lsof`, NDJSON streaming. |
| [`Audio-Haxor`](https://github.com/MenkeTechnologies/Audio-Haxor) | **Tauri v2 desktop GUI app** + JUCE engine. VST2/VST3/AU/CLAP scanner, sample vault, DAW project index, KVR version checker. |
| [`traderview`](https://github.com/MenkeTechnologies/traderview) | **Tauri v2 desktop GUI app** (sibling to Audio-Haxor) — TraderVue-style trading journal with embedded Postgres, vanilla JS + uPlot frontend. The same Rust workspace crates also ship a multi-user axum web service. |
| [`nmaprs`](https://github.com/MenkeTechnologies/nmaprs) | Rust port of `nmap`. Full async TCP/UDP/SCTP/IP-protocol scans, idle/zombie scans, NSE-style script probes, ARP/ICMP/timestamp/mask host discovery, top-ports list embedded. |
| [`powerliners`](https://github.com/MenkeTechnologies/powerliners) | **Rust CLI** — port (early) of Python's [`powerline-status`](https://github.com/powerline/powerline). Target: drop-in for tmux / zsh / bash / vim with sub-millisecond render replacing the ~100 ms python startup tax. |
| [`zpwr`](https://github.com/MenkeTechnologies/zpwr) | The terminal OS. 506+ verbs, 172k LOC, zinit-based, stryke-powered. ⭐ 220 |

### Tier 2 — Stryke ecosystem (16)

MenkeTechnologies distribution (single tap for every CLI tool) + per-service connector libraries for `stryke`.

| Project | What it is |
|---|---|
| [`homebrew-menketech`](https://github.com/MenkeTechnologies/homebrew-menketech) | Single Homebrew tap for all 7 MenkeTechnologies CLI tools (`stryke` / `zshrs` / `lsofrs` / `iftoprs` / `awkrs` / `nmaprs` / `temprs`). Formulas auto-bumped by each tool's `Release` workflow. |
| [`stryke-arrow`](https://github.com/MenkeTechnologies/stryke-arrow) | Apache Arrow integration. |
| [`stryke-aws`](https://github.com/MenkeTechnologies/stryke-aws) | AWS SDK bindings (S3, EC2, SQS, Lambda, ...). |
| [`stryke-demo`](https://github.com/MenkeTechnologies/stryke-demo) | Demo scripts + example programs. |
| [`stryke-docker`](https://github.com/MenkeTechnologies/stryke-docker) | Docker engine API client. |
| [`stryke-duckdb`](https://github.com/MenkeTechnologies/stryke-duckdb) | DuckDB embedded analytics. |
| [`stryke-gcp`](https://github.com/MenkeTechnologies/stryke-gcp) | Google Cloud Platform SDK bindings. |
| [`stryke-grpc`](https://github.com/MenkeTechnologies/stryke-grpc) | gRPC client/server. |
| [`stryke-k8s`](https://github.com/MenkeTechnologies/stryke-k8s) | Kubernetes API client. |
| [`stryke-kafka`](https://github.com/MenkeTechnologies/stryke-kafka) | Kafka producer/consumer (rdkafka bindings). |
| [`stryke-mongo`](https://github.com/MenkeTechnologies/stryke-mongo) | MongoDB driver. |
| [`stryke-mysql`](https://github.com/MenkeTechnologies/stryke-mysql) | MySQL/MariaDB driver. |
| [`stryke-parquet`](https://github.com/MenkeTechnologies/stryke-parquet) | Apache Parquet read/write. |
| [`stryke-postgres`](https://github.com/MenkeTechnologies/stryke-postgres) | PostgreSQL driver. |
| [`stryke-redis`](https://github.com/MenkeTechnologies/stryke-redis) | Redis client. |
| [`stryke-spark`](https://github.com/MenkeTechnologies/stryke-spark) | Apache Spark integration. |

### Tier 3 — zsh-more-completions (1)

| Project | What it is |
|---|---|
| [`zsh-more-completions`](https://github.com/MenkeTechnologies/zsh-more-completions) | 28,097-completion zsh corpus (9,253 `src/` + 14,349 `more_src/` + 3,398 `man_src/` + 1,087 `architecture_src/` + 10 `override_src/`; counts `_*` completion functions only — produced by `scripts/print-repo-stats.zsh`). ⭐ 53. The largest curated completion collection in existence. Lives outside Tier 1 because it's data + completion functions, not an executable. |

### Tier 4 — Zsh ecosystem plugins (28)

The plugin family that `zpwr` and any zsh user can load via zinit / oh-my-zsh. The full `ZPWR_GH_PLUGINS` canonical list plus the legacy zsh-* family.

| Project | What it is |
|---|---|
| [`zsh-expand`](https://github.com/MenkeTechnologies/zsh-expand) | Expand aliases / global aliases / typos on space. ⭐ 42. |
| [`zsh-cargo-completion`](https://github.com/MenkeTechnologies/zsh-cargo-completion) | Cargo completion. ⭐ 35. |
| [`zsh-learn`](https://github.com/MenkeTechnologies/zsh-learn) | MySQL/MariaDB-backed learning collection — save, query, quiz. ⭐ 8. |
| [`zsh-git-acp`](https://github.com/MenkeTechnologies/zsh-git-acp) | `git add commit push` in one keybinding. ⭐ 6. |
| [`zsh-better-npm-completion`](https://github.com/MenkeTechnologies/zsh-better-npm-completion) | Better npm completion. |
| [`zsh-cpan-completion`](https://github.com/MenkeTechnologies/zsh-cpan-completion) | CPAN completion. |
| [`zsh-dotnet-completion`](https://github.com/MenkeTechnologies/zsh-dotnet-completion) | .NET completion. |
| [`zsh-gem-completion`](https://github.com/MenkeTechnologies/zsh-gem-completion) | Ruby gem completion. |
| [`zsh-git-repo-cache`](https://github.com/MenkeTechnologies/zsh-git-repo-cache) | Git repo cache helper. |
| [`zsh-nginx`](https://github.com/MenkeTechnologies/zsh-nginx) | nginx config completion. |
| [`zsh-pip-description-completion`](https://github.com/MenkeTechnologies/zsh-pip-description-completion) | pip completion with package descriptions. |
| [`zsh-sed-sub`](https://github.com/MenkeTechnologies/zsh-sed-sub) | sed substitution helper. |
| [`zsh-sudo`](https://github.com/MenkeTechnologies/zsh-sudo) | `Esc Esc` to prepend `sudo` to the current line. |
| [`zsh-xcode-completions`](https://github.com/MenkeTechnologies/zsh-xcode-completions) | Xcode CLI tools completion. |
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
| [`VimColorSchemes`](https://github.com/MenkeTechnologies/VimColorSchemes) | 731 hand-curated Vim colorschemes packaged as a single Pathogen / vim-plug / lazy.nvim bundle. The largest one-bundle scheme collection. |
| [`tmux-fzf-url`](https://github.com/MenkeTechnologies/tmux-fzf-url) | Pop a fzf picker over every URL currently visible in the tmux pane; selected URL opens in the default browser. |

### Tier 6 — Apps, extensions, web & web-APIs (5)

Browser extensions, supporting apps, public website, and web-API services. (Tauri v2 desktop GUI apps `traderview` and `Audio-Haxor` live in Tier 1; the `powerliners` CLI port lives in Tier 1 too.)

| Project | What it is |
|---|---|
| [`zpwrchrome`](https://github.com/MenkeTechnologies/zpwrchrome) | The fastest recent-tabs Chrome extension with the most keyboard shortcuts. Manifest V3, cross-window MRU stack, 38 commands (3 default-keyed + 35 user-bindable), sub-popup live-filter search, companion Chrome theme matching the strykelang HUD palette. |
| [`storageshower`](https://github.com/MenkeTechnologies/storageshower) | Disk-usage **TUI** in Rust (sibling to iftoprs). Walks a directory tree, presents space-by-folder with sort + drill-down. |
| [`MenkeTechnologies.github.io`](https://github.com/MenkeTechnologies/MenkeTechnologies.github.io) | Public-facing personal site / project landing page (cyberpunk HUD, static HTML + CSS). |
| [`spring-boot-rest-generator`](https://github.com/MenkeTechnologies/spring-boot-rest-generator) | **Web-API codegen tool.** Rust port (v0.2.0+) of the original Kotlin Spring-Boot-REST-API generator — feed it MySQL / PostgreSQL / SQLite / MSSQL DDL, get a fully wired Spring Boot REST backend (entities, controllers, DAOs, repositories) in Java / Kotlin / Groovy. Kotlin source preserved under `src/main/kotlin/` for reference. |
| [`LearningCollectionAPI`](https://github.com/MenkeTechnologies/LearningCollectionAPI) | **Web API.** Java/Kotlin Spring Boot REST service — backing service for the `zsh-learn` plugin (save / query / quiz / search vocabulary cards over HTTP). |

---

## [0x02] COMMON OPERATIONS

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

## [0x03] HELPER SCRIPTS

The `bin/` directory ships a few wrappers for common operations. All are POSIX shell, no dependencies beyond `git`.

| Script | What it does |
|---|---|
| [`bin/pull-all`](bin/pull-all) | Pull every submodule to its tracking-branch tip in parallel. |
| [`bin/status-all`](bin/status-all) | One-line status for every submodule (branch + ahead/behind + dirty marker). |
| [`bin/foreach`](bin/foreach) | Run an arbitrary shell command inside every submodule. |
| [`bin/sync-pointers`](bin/sync-pointers) | After running pull-all, stage + commit all submodule pointer bumps in one commit. |

```bash
# pull everything
./bin/pull-all

# what's dirty?
./bin/status-all

# build every Rust project
./bin/foreach 'test -f Cargo.toml && cargo build --release || true'

# bump every pointer to current submodule HEAD
./bin/sync-pointers && git push
```

---

## [0x04] UPDATING SUBMODULE POINTERS

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

## [0x05] PER-HOST SETUP

### macOS / Linux

```bash
# prereq: git 2.13+ (parallel submodule clones) and ~2 GB free
git clone --recurse-submodules -j 8 https://github.com/MenkeTechnologies/MenkeTechnologiesMeta.git
cd MenkeTechnologiesMeta

# build the Rust CLIs
./bin/foreach 'test -f Cargo.toml && cargo build --release || true'

# install zpwr (the terminal OS)
./zpwr/install/zpwrInstall.sh

# install any CLI tool via the unified homebrew tap
brew tap MenkeTechnologies/menketech
brew install stryke zshrs lsofrs iftoprs awkrs nmaprs temprs
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

## [0x06] WORKING INSIDE A SUBMODULE

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

## [0x07] DISK FOOTPRINT

| Tier | Repos | Approx size |
|---|---|---|
| Tier 1 — Core | 12 | ~720 MB |
| Tier 2 — Stryke ecosystem | 16 | +5 MB |
| Tier 3 — zsh-more-completions | 1 | +18 MB |
| Tier 4 — Zsh ecosystem plugins | 28 | +220 MB |
| Tier 5 — Editor / multiplexer plugins | 2 | +25 MB |
| Tier 6 — Apps, extensions, web & web-APIs | 5 | +5 MB |
| **Total** | **64** | **~993 MB** |

The bulk is in `zshrs/src/zsh/` (vendored upstream zsh C source) and `strykelang/`. Cargo `target/` directories are `.gitignore`d and re-derived during build.

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
