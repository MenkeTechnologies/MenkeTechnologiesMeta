#!/usr/bin/env bash
# For every publishable Rust crate's `categories = [...]` array, pin
# that each entry matches crates.io's category-slug format and
# appears in the curated allowlist of categories actually used
# across the MenkeTechnologies stack.
#
# crates.io categories must be drawn from a fixed list at
# https://crates.io/category_slugs (hundreds of entries with
# hierarchical parent::child structure). The full list is too
# brittle to hardcode here — but the categories actually USED
# across this org are a small bounded set, easy to validate.
#
# Test enforces TWO things:
#   1. Format: lowercase letters/digits/hyphens, optional `::`
#      child separators (matches the crates.io slug shape)
#   2. Allowlist: must be one of the org's known-good categories
#      OR exit-friendly INFO (not FAIL) for unrecognized ones so
#      adding a new category doesn't require a coordinated change
#      to this test
#
# When INFO fires, the user can either:
#   a) Add the category to the allowlist (if it's a real
#      crates.io slug they verified against the registry)
#   b) Fix the category if it's a typo
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Allowlist of categories currently used across the umbrella's
# publishable Rust crates. Verified manually against the
# crates.io category list before being added here.
ALLOWED=(
    "command-line-utilities"
    "compilers"
    "development-tools"
    "development-tools::build-utils"
    "development-tools::cargo-plugins"
    "development-tools::debugging"
    "development-tools::ffi"
    "filesystem"
    "network-programming"
    "os"
    "os::unix-apis"
    "os::macos-apis"
    "os::linux-apis"
    "parser-implementations"
    "parsing"
    "text-processing"
    "encoding"
    "data-structures"
    "concurrency"
    "asynchronous"
)

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

is_allowed() {
    local cat="$1"
    for a in "${ALLOWED[@]}"; do
        [[ "$a" == "$cat" ]] && return 0
    done
    return 1
}

checked=0
violations=0
unknown=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue
    if grep -qE '^publish *= *false' "$cargo"; then
        continue
    fi

    cats_line=$(grep -m1 -E '^categories *=' "$cargo" 2>/dev/null)
    [[ -n "$cats_line" ]] || continue

    checked=$((checked + 1))
    cats=$(echo "$cats_line" | grep -oE '"[^"]+"' | sed 's/"//g')
    [[ -n "$cats" ]] || continue

    issues=""
    unknown_here=""
    while IFS= read -r cat; do
        [[ -z "$cat" ]] && continue
        # Format check: lowercase letters/digits/hyphens, optional ::child segments.
        if [[ ! "$cat" =~ ^[a-z][a-z0-9-]*(::[a-z][a-z0-9-]*)*$ ]]; then
            issues="$issues bad-format:'$cat'"
        elif ! is_allowed "$cat"; then
            unknown_here="$unknown_here '$cat'"
        fi
    done <<< "$cats"

    if [[ -n "$issues" ]]; then
        echo "FAIL  $cargo: format violation:$issues"
        violations=$((violations + 1))
        ok=0
    elif [[ -n "$unknown_here" ]]; then
        echo "INFO  $cargo: unrecognized categor(ies):$unknown_here — verify against crates.io/category_slugs and add to ALLOWED if valid"
        unknown=$((unknown + 1))
    else
        echo "PASS  $cargo: all categories in allowlist"
    fi
done

echo "---"
echo "Summary: $checked publishable crates with categories checked, $violations format-violations, $unknown unrecognized (INFO)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
