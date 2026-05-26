```
 ███╗   ███╗███████╗████████╗ █████╗
 ████╗ ████║██╔════╝╚══██╔══╝██╔══██╗
 ██╔████╔██║█████╗     ██║   ███████║
 ██║╚██╔╝██║██╔══╝     ██║   ██╔══██║
 ██║ ╚═╝ ██║███████╗   ██║   ██║  ██║
 ╚═╝     ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝
```

[![Submodules](https://img.shields.io/badge/submodules-44-blue.svg)](#0x01-submodule-map)
[![Tier 1](https://img.shields.io/badge/tier_1-9_core-cyan.svg)](#tier-1--core-9)
[![Tier 2](https://img.shields.io/badge/tier_2-16_stryke-green.svg)](#tier-2--stryke-ecosystem-16)
[![Tier 3](https://img.shields.io/badge/tier_3-3_siblings-magenta.svg)](#tier-3--sibling-rust-tools--zsh-more-completions-3)
[![Tier 4](https://img.shields.io/badge/tier_4-14_zsh_plugins-yellow.svg)](#tier-4--zsh-ecosystem-plugins-14)
[![Tier 5](https://img.shields.io/badge/tier_5-2_apps_+_extensions-orange.svg)](#tier-5--apps--extensions-2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### `[META REPO // 44 SUBMODULES // ONE COMMAND, EVERY MENKETECHNOLOGIES PROJECT]`

> *"One repo to rule them all, one repo to fetch them, one repo to bring them all, and on every host bind them."*

**MenkeTechnologiesMeta** is a single umbrella repo that vendors every active [MenkeTechnologies](https://github.com/MenkeTechnologies) project as a git submodule. Clone once with `--recurse-submodules` and a fresh host has the entire stack: `strykelang` (the language), `zshrs` (the shell), `fusevm` (the bytecode VM), `lsofrs` / `temprs` / `awkrs` / `iftoprs` (the Rust CLI tools), `Audio-Haxor` (the Tauri GUI), `zpwr` (the terminal OS), the 16-repo stryke ecosystem (`stryke-aws`, `stryke-k8s`, `stryke-kafka`, ...), the 14-repo zsh plugin family (`zsh-more-completions`, `zsh-expand`, `zsh-cargo-completion`, ...), and the companion apps `traderview` (Tauri v2 + axum trading journal) and `zpwrchrome` (Chrome MRU-tabs extension).

### [`MenkeTechnologies on GitHub`](https://github.com/MenkeTechnologies) &middot; [`strykelang`](https://github.com/MenkeTechnologies/strykelang) · [`zshrs`](https://github.com/MenkeTechnologies/zshrs) · [`zpwr`](https://github.com/MenkeTechnologies/zpwr)

---

## Table of Contents

- [\[0x00\] Quick Start](#0x00-quick-start)
- [\[0x01\] Submodule Map](#0x01-submodule-map)
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

The `--recurse-submodules` flag fetches all 44 submodules in parallel during the initial clone.

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

All 44 submodules sit flat at the repository root. URLs are HTTPS for fresh-host portability (no SSH key needed for `clone --recurse`).

### Tier 1 — Core (9)

The set of MenkeTechnologies projects that share the unified `strykelang`-authored documentation template (README header, ToC convention `[0xNN]`, `docs/index.html` chrome, `docs/report.html` engineering report, `man/man1/<name>.1` + `<name>all.1` man pages).

| Project | What it is |
|---|---|
| [`strykelang`](strykelang/) | The fastest dynamic language for parallel ops. Perl 5 interpreter in Rust, bytecode VM + Cranelift JIT, 10,329 builtins. |
| [`zshrs`](zshrs/) | The first compiled Unix shell. 1:1 zsh C-port + extensions, persistent worker pool, AOP intercept, rkyv bytecode cache. |
| [`fusevm`](fusevm/) | Language-agnostic bytecode VM with fused superinstructions and 3-tier Cranelift JIT. The execution engine behind strykelang, zshrs, awkrs. |
| [`lsofrs`](lsofrs/) | Rust rewrite of `lsof` — 5–21× faster, 7-tab TUI, 31 cyberpunk themes. |
| [`temprs`](temprs/) | Temporary file stack manager. Atomic `flock`-protected master record, dual indexing (position or `@name`). |
| [`awkrs`](awkrs/) | AWK in Rust. Bytecode VM + Cranelift JIT + persistent rkyv bytecode cache + parallel records. |
| [`iftoprs`](iftoprs/) | Real-time bandwidth monitor. ratatui TUI, 31 themes, process attribution via `lsof`, NDJSON streaming. |
| [`Audio-Haxor`](Audio-Haxor/) | Tauri v2 + JUCE desktop app. VST2/VST3/AU/CLAP scanner, sample vault, DAW project index, KVR version checker. |
| [`zpwr`](zpwr/) | The terminal OS. 506+ verbs, 172k LOC, zinit-based, stryke-powered. ⭐ 220 |

### Tier 2 — Stryke ecosystem (16)

MenkeTechnologies distribution (single tap for every CLI tool) + per-service connector libraries for `stryke`.

| Project | What it is |
|---|---|
| [`homebrew-menketech`](homebrew-menketech/) | Single Homebrew tap for all 7 MenkeTechnologies CLI tools (`stryke` / `zshrs` / `lsofrs` / `iftoprs` / `awkrs` / `nmaprs` / `temprs`). Formulas auto-bumped by each tool's `Release` workflow. |
| [`stryke-arrow`](stryke-arrow/) | Apache Arrow integration. |
| [`stryke-aws`](stryke-aws/) | AWS SDK bindings (S3, EC2, SQS, Lambda, ...). |
| [`stryke-demo`](stryke-demo/) | Demo scripts + example programs. |
| [`stryke-docker`](stryke-docker/) | Docker engine API client. |
| [`stryke-duckdb`](stryke-duckdb/) | DuckDB embedded analytics. |
| [`stryke-gcp`](stryke-gcp/) | Google Cloud Platform SDK bindings. |
| [`stryke-grpc`](stryke-grpc/) | gRPC client/server. |
| [`stryke-k8s`](stryke-k8s/) | Kubernetes API client. |
| [`stryke-kafka`](stryke-kafka/) | Kafka producer/consumer (rdkafka bindings). |
| [`stryke-mongo`](stryke-mongo/) | MongoDB driver. |
| [`stryke-mysql`](stryke-mysql/) | MySQL/MariaDB driver. |
| [`stryke-parquet`](stryke-parquet/) | Apache Parquet read/write. |
| [`stryke-postgres`](stryke-postgres/) | PostgreSQL driver. |
| [`stryke-redis`](stryke-redis/) | Redis client. |
| [`stryke-spark`](stryke-spark/) | Apache Spark integration. |

### Tier 3 — Sibling Rust tools + zsh-more-completions (3)

Predecessors / siblings referenced from Tier 1 projects.

| Project | What it is |
|---|---|
| [`lsofng`](lsofng/) | The modernized `lsof` fork that `lsofrs` rewrote. C source still maintained as the compat reference. |
| [`nmaprs`](nmaprs/) | Rust port of `nmap` (in progress). |
| [`zsh-more-completions`](zsh-more-completions/) | 27,387-file zsh completion corpus (9,253 `src/` + 13,659 `more_src/` + 3,398 `man_src/` + 1,067 `architecture_src/` + 10 `override_src/`). ⭐ 53. The largest curated completion collection in existence. |

### Tier 4 — Zsh ecosystem plugins (14)

The plugin family that `zpwr` and any zsh user can load via zinit / oh-my-zsh.

| Project | What it is |
|---|---|
| [`zsh-expand`](zsh-expand/) | Expand aliases / global aliases / typos on space. ⭐ 42. |
| [`zsh-cargo-completion`](zsh-cargo-completion/) | Cargo completion. ⭐ 35. |
| [`zsh-learn`](zsh-learn/) | MySQL/MariaDB-backed learning collection — save, query, quiz. ⭐ 8. |
| [`zsh-git-acp`](zsh-git-acp/) | `git add commit push` in one keybinding. ⭐ 6. |
| [`zsh-better-npm-completion`](zsh-better-npm-completion/) | Better npm completion. |
| [`zsh-cpan-completion`](zsh-cpan-completion/) | CPAN completion. |
| [`zsh-dotnet-completion`](zsh-dotnet-completion/) | .NET completion. |
| [`zsh-gem-completion`](zsh-gem-completion/) | Ruby gem completion. |
| [`zsh-git-repo-cache`](zsh-git-repo-cache/) | Git repo cache helper. |
| [`zsh-nginx`](zsh-nginx/) | nginx config completion. |
| [`zsh-pip-description-completion`](zsh-pip-description-completion/) | pip completion with package descriptions. |
| [`zsh-sed-sub`](zsh-sed-sub/) | sed substitution helper. |
| [`zsh-sudo`](zsh-sudo/) | `Esc Esc` to prepend `sudo` to the current line. |
| [`zsh-xcode-completions`](zsh-xcode-completions/) | Xcode CLI tools completion. |

### Tier 5 — Apps & extensions (2)

Standalone end-user apps and browser extensions that sit outside the CLI / language / shell core.

| Project | What it is |
|---|---|
| [`traderview`](traderview/) | TraderVue-style trading journal. Rust workspace, Postgres backend, vanilla JS + uPlot frontend. Ships as a Tauri v2 desktop app (with embedded Postgres) **and** as a multi-user axum web service from the same crates. |
| [`zpwrchrome`](zpwrchrome/) | The fastest recent-tabs Chrome extension with the most keyboard shortcuts. Manifest V3, cross-window MRU stack, 29 commands (4 default-keyed + 25 user-bindable), sub-popup live-filter search, companion Chrome theme matching the strykelang HUD palette. |

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
| Tier 1 | 9 | ~705 MB |
| Tier 2 | 16 | +5 MB |
| Tier 3 | 3 | +20 MB |
| Tier 4 | 14 | +200 MB |
| Tier 5 | 2 | +2 MB |
| **Total** | **44** | **~932 MB** |

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
