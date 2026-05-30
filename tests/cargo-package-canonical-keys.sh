#!/usr/bin/env bash
# For every Cargo.toml `[package]` table, pin that all
# keys are canonical Cargo package keys per the official
# manifest spec.
#
# Canonical keys (current as of Cargo 1.85+):
#
#   name              Crate name (required)
#   version           Crate version (required for publish)
#   edition           Rust edition (2015/2018/2021/2024)
#   rust-version      MSRV declaration
#   description       crates.io card text
#   documentation     docs URL (typically docs.rs)
#   readme            README file path or false
#   homepage          Project homepage URL
#   repository        Source repo URL
#   license           SPDX license expression
#   license-file      Path to LICENSE file (if non-SPDX)
#   keywords          ≤5 search keywords
#   categories        ≤5 crates.io categories
#   workspace         Path to workspace root
#   build             Custom build script
#   links             Native library link name
#   exclude           Files excluded from publish
#   include           Files included in publish
#   publish           false/true/[registry, ...]
#   metadata          Custom metadata namespace
#   default-run       Default bin for `cargo run`
#   autobins          Disable autodiscover of bins
#   autoexamples      Disable autodiscover of examples
#   autotests         Disable autodiscover of tests
#   autobenches       Disable autodiscover of benches
#   resolver          "1"/"2"/"3" dep resolver version
#   authors           Authors array
#
# A non-canonical key in [package]:
#
#   [package]
#   name = "foo"
#   descriptin = "Tool for ..."        # WRONG — typo
#   licence = "MIT"                    # WRONG — Br.E
#   rust_version = "1.85"              # WRONG — snake
#   default_run = "foo-cli"            # WRONG — snake
#   homepag = "https://..."            # WRONG — typo
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key: package.descriptin
#   warning: unused manifest key: package.licence
#   warning: unused manifest key: package.rust_version
#
# The crate still builds; warning may be filtered in CI
# logs; contributor sees it on local builds. The INTENDED
# configuration is silently NOT applied:
#
#   - descriptin = "Tool for ..." — ignored; description
#     field stays unset; crates.io shows blank tagline
#   - licence = "MIT" — ignored; cargo treats crate as
#     unlicensed; crates.io publish fails with "missing
#     license"
#   - rust_version = "1.85" — ignored; MSRV not declared;
#     downstream `cargo install --locked` users hit
#     build errors on older Rust
#   - default_run = "foo-cli" — ignored; multi-bin
#     `cargo run` errors with "use --bin"
#
# Common typo sources:
#
#   descriptin / descripton    → description
#   licence                    → license          (Br.E
#                                                  spelling)
#   licens                     → license          (truncated)
#   homepag / homepage_url     → homepage
#   rust_version               → rust-version     (snake→kebab)
#   default_run                → default-run      (snake→kebab)
#   license_file               → license-file     (snake→kebab)
#   keywords_list              → keywords         (suffix)
#   categories_list            → categories       (suffix)
#   author / authors_list      → authors          (singular
#                                                  or suffix)
#   autobin                    → autobins         (truncated)
#
# Detection: TOML-parse each Cargo.toml. Check
# d['package'].keys() against the canonical set.
#
# Pairs with cargo manifest hygiene catalog
# (cargo-bin-canonical-keys for [[bin]] tables, cargo-
# package-canonical-keys for [package] table). Together
# they enforce the manifest's table-level key set is
# canonical.
#
# 281/281 [package] keys canonical at iter-221 add —
# pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

if [[ ! -f .gitmodules ]]; then
    echo "SKIP  no .gitmodules"
    exit 0
fi

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    for cargo in "$p/Cargo.toml" "$p/src-tauri/Cargo.toml"; do
        [[ -f "$cargo" ]] || continue
        grep -qE '^\[package\]' "$cargo" || continue
        result=$(python3 - "$cargo" <<'PY'
import sys
try:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib
    with open(sys.argv[1], 'rb') as f:
        d = tomllib.load(f)
except Exception:
    print('0|')
    sys.exit()
allowed = {
    'name', 'version', 'edition', 'rust-version',
    'description', 'documentation', 'readme', 'homepage',
    'repository', 'license', 'license-file', 'keywords',
    'categories', 'workspace', 'build', 'links',
    'exclude', 'include', 'publish', 'metadata',
    'default-run', 'autobins', 'autoexamples',
    'autotests', 'autobenches', 'resolver', 'authors',
}
pkg = d.get('package', {})
if not isinstance(pkg, dict):
    print('0|')
    sys.exit()
total = len(pkg)
bad = [k for k in pkg.keys() if k not in allowed]
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for k in "${ba[@]}"; do
                echo "FAIL  $cargo: [package].$k — non-canonical key (cargo emits 'unused manifest key' warning + intended config silently NOT applied)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked [package] keys checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
