#!/usr/bin/env bash
# For every Rust submodule that publishes to crates.io (no
# `publish = false` opt-out), pin that Cargo.toml has non-empty
# `keywords` AND `categories` fields. These are the primary
# discoverability vectors on crates.io — users find a crate via
# category browsing and keyword search. Without them, the crate is
# effectively invisible outside of direct-name lookup.
#
# crates.io constraints (enforced by the cargo publish endpoint):
#   keywords: max 5 entries, each ≤ 20 chars, ASCII alphanumeric or
#             dashes/underscores
#   categories: must be from a fixed list at
#               https://crates.io/category_slugs
#
# This test verifies presence + the keyword constraints. Category
# validity against the slug list is NOT checked here (would require
# network or a cached snapshot); crates.io itself rejects unknown
# categories at publish time.
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
no_keywords=0
no_categories=0
too_many=0
skipped=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Skip publish=false crates — they're not on crates.io so the
    # discoverability requirement doesn't apply.
    if grep -qE '^publish *= *false' "$cargo"; then
        echo "SKIP  $cargo: publish = false (not on crates.io)"
        skipped=$((skipped + 1))
        continue
    fi

    checked=$((checked + 1))

    # Pull the keywords array as a single line; tolerate single-line or
    # multi-line array form.
    keywords_line=$(grep -m1 -E '^keywords *=' "$cargo" 2>/dev/null)
    categories_line=$(grep -m1 -E '^categories *=' "$cargo" 2>/dev/null)

    issues=""
    if [[ -z "$keywords_line" ]]; then
        issues="$issues missing-keywords"
        no_keywords=$((no_keywords + 1))
    else
        # Count entries: every "..." string inside the array.
        kw_count=$(echo "$keywords_line" | grep -o '"[^"]*"' | wc -l | tr -d ' ')
        if (( kw_count > 5 )); then
            issues="$issues keywords-$kw_count>5"
            too_many=$((too_many + 1))
        fi
    fi
    if [[ -z "$categories_line" ]]; then
        issues="$issues missing-categories"
        no_categories=$((no_categories + 1))
    fi

    if [[ -z "$issues" ]]; then
        kw_count=$(echo "$keywords_line" | grep -o '"[^"]*"' | wc -l | tr -d ' ')
        cat_count=$(echo "$categories_line" | grep -o '"[^"]*"' | wc -l | tr -d ' ')
        echo "PASS  $cargo: $kw_count keywords + $cat_count categories"
    else
        echo "FAIL  $cargo:$issues"
        ok=0
    fi
done

echo "---"
echo "Summary: $checked publishable crates checked, $skipped skipped (publish=false), $no_keywords without keywords, $no_categories without categories, $too_many with >5 keywords"

[[ $ok -eq 1 ]] && exit 0 || exit 1
