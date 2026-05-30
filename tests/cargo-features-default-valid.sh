#!/usr/bin/env bash
# For every Cargo.toml with a [features] section, pin that each
# item in the `default = [...]` array references either:
#   - a feature declared in the same [features] table, OR
#   - an optional dependency declared in [dependencies] /
#     [dev-dependencies] / [build-dependencies]
#
# Cargo's `default` feature controls what's enabled when nothing
# is requested explicitly (`cargo build` without --features).
# Each entry must resolve to a real feature name or an optional
# dep, otherwise:
#
#   error[E0599]: failed to select a version for `foo`
#   the package `foo` depends on `bar`, with features: `nonexistent`
#   but `bar` does not have these features
#
# (Plus a "feature not found" warning at `cargo build` time.)
#
# This is a publish-time-failure-mode-adjacent gate (catches
# config that builds locally but breaks for downstream consumers
# when they enable a different feature subset). The cost of the
# build failure is paid by everyone who depends on the crate,
# not just the crate author.
#
# Common drift caught:
#   - Remove a feature without updating `default`
#   - Rename a feature without updating `default`
#   - Typo in default list (`default = ["std", "deafult-impl"]`)
#   - Add an item to `default` referencing an optional dep that
#     was never declared
#
# Item shapes handled:
#   "feature_name"             — local feature
#   "dep:foo"                  — explicit optional-dep activation
#                                (Cargo 1.60+ syntax)
#   "foo/bar"                  — activate feature `bar` on dep
#                                `foo` (only `foo` checked here)
#
# Implementation note: `dep:` prefix is stripped with
# `removeprefix` semantics (str slice). NOT lstrip("dep:") —
# that strips a char SET, so "daemon".lstrip("dep:") returns
# "aemon" (strips 'd', then stops at 'a'), producing false
# FAILs on feature names starting with d/e/p. This bit me
# during the iter-91 survey before being caught and fixed.
#
# 3/3 crates with [features] green at iter-91 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
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

audit_one() {
    python3 - "$1" << 'PY'
import sys, re
cargo = sys.argv[1]
content = open(cargo).read()
m = re.search(r'(?ms)^\[features\]\n(.*?)(?=\n\[|\Z)', content)
if not m:
    print("NO_FEATURES")
    sys.exit()
body = m.group(1)
names = set()
default = []
for ln in body.splitlines():
    ln = ln.strip()
    if not ln or ln.startswith('#'):
        continue
    nm = re.match(r'^([a-zA-Z0-9_-]+) *= *(\[.*\])', ln)
    if not nm:
        continue
    n, v = nm.group(1), nm.group(2)
    names.add(n)
    if n == 'default':
        default = re.findall(r'"([^"]+)"', v)

def strip_dep(s):
    return s[4:] if s.startswith('dep:') else s

bad_refs = []
for item in default:
    base = strip_dep(item.split('/')[0])
    if base in names:
        continue
    # Optional dep / declared dep counts as valid.
    if re.search(r'(?m)^\s*' + re.escape(base) + r'\s*=', content):
        continue
    bad_refs.append(item)
print("OK" if not bad_refs else "BAD:" + ",".join(bad_refs))
PY
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    output=$(audit_one "$cargo")
    case "$output" in
        NO_FEATURES) continue ;;
        OK)
            checked=$((checked + 1))
            echo "PASS  $cargo: default refs all valid"
            ;;
        BAD:*)
            checked=$((checked + 1))
            echo "FAIL  $cargo: default refs ${output#BAD:} are not declared features or deps"
            n=$(echo "${output#BAD:}" | tr ',' '\n' | grep -c .)
            bad=$((bad + n))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked crates with [features] checked, $bad unresolved default refs"

[[ $ok -eq 1 ]] && exit 0 || exit 1
