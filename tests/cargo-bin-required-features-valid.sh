#!/usr/bin/env bash
# For every Cargo.toml `[[bin]] required-features = [...]` array,
# pin that each item resolves to either a declared feature in
# [features] or a declared dependency name (Cargo 1.60+ allows
# dep names as feature names per the unified syntax).
#
# `required-features` gates whether a [[bin]] target is buildable
# under a given feature subset. When the array references a
# nonexistent feature:
#
#   error: feature `nonexistent` does not exist
#
# fires at `cargo build` time — only when the bin target is
# actually built. Library-only `cargo build` doesn't trigger
# it. The drift can sit dormant for entire release cycles
# before someone runs `cargo build --bin <name>` and discovers
# the gap.
#
# Why this is its own gate vs piggy-backing on
# cargo-features-default-valid (iter-91): default-feature
# validation walks the [features].default array; required-
# features validation walks per-[[bin]] arrays. Different
# section, same kind of dangling-reference check. Both fail in
# different ways at different times.
#
# Item shapes handled:
#   "feature_name"             — local feature
#   "dep:foo"                  — explicit dep activation
#                                (Cargo 1.60+ syntax)
#   "foo/bar"                  — activate feature `bar` on dep
#                                `foo` (only `foo` resolution
#                                checked here)
#
# Implementation note: same `dep:` prefix-strip trap as iter-91
# documented (str-slice, not lstrip — `lstrip("dep:")` is a
# char-set match that returns "aemon" for "daemon"). Reuses
# the canonical Python prefix-strip helper.
#
# 2/2 required-features items green at iter-111 add — pure
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

def strip_dep(s):
    return s[4:] if s.startswith('dep:') else s

# Collect features.
m = re.search(r'(?ms)^\[features\]\n(.*?)(?=\n\[|\Z)', content)
feats = set()
if m:
    for ln in m.group(1).splitlines():
        ln = ln.strip()
        if not ln or ln.startswith('#'):
            continue
        nm = re.match(r'^([a-zA-Z0-9_-]+) *=', ln)
        if nm:
            feats.add(nm.group(1))

# Walk [[bin]] sections.
sections = re.split(r'(?m)^(\[\[?[a-zA-Z_]+\]\]?)', content)
i = 1
results = []
while i < len(sections):
    h = sections[i]
    b = sections[i+1] if i+1 < len(sections) else ''
    if h == '[[bin]]':
        rf = re.search(r'(?m)^required-features\s*=\s*\[([^\]]+)\]', b)
        if rf:
            items = re.findall(r'"([^"]+)"', rf.group(1))
            nm = re.search(r'(?m)^name\s*=\s*"([^"]+)"', b)
            bin_name = nm.group(1) if nm else '?'
            for it in items:
                base = strip_dep(it.split('/')[0])
                if base in feats:
                    results.append(f"OK:{bin_name}:{it}")
                    continue
                if re.search(r'(?m)^\s*' + re.escape(base) + r'\s*=', content):
                    results.append(f"OK:{bin_name}:{it}")
                    continue
                results.append(f"BAD:{bin_name}:{it}")
    i += 2
print("\n".join(results) if results else "NO_REQ_FEATURES")
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
    [[ "$output" == "NO_REQ_FEATURES" ]] && continue

    while IFS=: read -r status bin_name item; do
        [[ -z "$status" ]] && continue
        checked=$((checked + 1))
        if [[ "$status" == "OK" ]]; then
            echo "PASS  $cargo: [[bin]] $bin_name required-feature \"$item\""
        else
            echo "FAIL  $cargo: [[bin]] $bin_name required-feature \"$item\" — not a declared feature or dep"
            bad=$((bad + 1))
            ok=0
        fi
    done <<< "$output"
done

echo "---"
echo "Summary: $checked required-features items checked, $bad unresolved"

[[ $ok -eq 1 ]] && exit 0 || exit 1
