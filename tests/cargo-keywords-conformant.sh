#!/usr/bin/env bash
# For every publishable Rust crate's `keywords = [...]` array, pin
# that each entry satisfies crates.io's ingest constraints:
#   - At most 5 entries per crate (max_keywords in crates.io API)
#   - Each entry ≤ 20 chars (max_keyword_length)
#   - Each entry must start with a lowercase letter
#   - Each entry must contain only [a-z0-9_-]
#
# crates.io's ingest endpoint rejects publishes that violate these
# rules at the API level (cargo publish fails with a 400 error from
# the registry), but the violation isn't caught locally before
# attempting to push — wasting the release.yml workflow run and
# requiring a manual roll-forward.
#
# Skips publish=false crates (the 14 stryke-* connectors + Tauri
# apps) — they never go to crates.io so the ingest constraints
# don't apply.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

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
violations=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Skip publish=false crates.
    if grep -qE '^publish *= *false' "$cargo"; then
        continue
    fi

    kw_line=$(grep -m1 -E '^keywords *=' "$cargo" 2>/dev/null)
    [[ -n "$kw_line" ]] || continue

    checked=$((checked + 1))

    # Extract each "..."-quoted entry.
    kws=$(echo "$kw_line" | grep -oE '"[^"]*"' | sed 's/"//g')
    [[ -n "$kws" ]] || continue

    n=$(printf '%s\n' "$kws" | grep -c .)
    issues=""

    if (( n > 5 )); then
        issues="$issues 6+entries($n)"
    fi

    while IFS= read -r kw; do
        [[ -z "$kw" ]] && continue
        len=${#kw}
        if (( len > 20 )); then
            issues="$issues toolong:'$kw'($len)"
        fi
        if [[ ! "$kw" =~ ^[a-z][a-z0-9_-]*$ ]]; then
            issues="$issues badchars:'$kw'"
        fi
    done <<< "$kws"

    if [[ -z "$issues" ]]; then
        echo "PASS  $cargo: $n keywords, all conformant"
    else
        echo "FAIL  $cargo:$issues"
        violations=$((violations + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked publishable crates with keywords checked, $violations with crates.io constraint violations"

[[ $ok -eq 1 ]] && exit 0 || exit 1
