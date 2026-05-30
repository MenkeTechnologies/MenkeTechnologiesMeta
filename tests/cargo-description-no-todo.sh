#!/usr/bin/env bash
# For every Cargo.toml `description` field, pin that the value
# does NOT contain placeholder markers: TODO, FIXME, XXX, TBD,
# "placeholder".
#
# These markers signal that the description was filled in
# DURING DEVELOPMENT with the intent to refine later — and
# never refined. Common examples:
#
#   description = "TODO: write proper description"
#   description = "FIXME placeholder text"
#   description = "TBD"
#
# Each of these published to crates.io:
#
#   - Renders as the crate's one-line tagline on the card view
#   - Appears in `cargo search` output
#   - Shows in IDE tooltips on `extern crate <name>`
#   - Becomes the meta description for SEO on the crate page
#
# A placeholder description is visible to every prospective
# user. It signals abandoned development. crates.io's spam-
# detection heuristics may flag the crate.
#
# crates.io ITSELF doesn't reject placeholder text at publish
# time — the gate's value is org-side discipline catching the
# placeholder BEFORE it ships rather than relying on users to
# notice.
#
# Detection: case-insensitive word-boundary regex on TODO,
# FIXME, XXX, TBD, placeholder.
#
# Pairs with iter-27 (description ≤ 150 chars), iter-47 (no
# trailing period), iter-53 (≥ 20 chars), iter-94 (no URL),
# iter-127 (features are arrays — separate context). Five
# gates now pin the cargo description shape:
#
#   iter-27:  length ≤ 150
#   iter-47:  no trailing period
#   iter-53:  length ≥ 20
#   iter-94:  no URL inside
#   iter-141: no TODO/FIXME placeholders
#
# 27/27 crates green at iter-141 add — pure regression floor
# against placeholder-text drift.
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
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    desc=$(grep -m1 -E '^description *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$desc" ]] || continue
    checked=$((checked + 1))

    if echo "$desc" | grep -qiE '\b(TODO|FIXME|XXX|TBD|placeholder)\b'; then
        echo "FAIL  $cargo: description contains placeholder marker — \"$desc\""
        bad=$((bad + 1))
        ok=0
    else
        echo "PASS  $cargo"
    fi
done

echo "---"
echo "Summary: $checked descriptions checked, $bad containing TODO/FIXME/XXX/TBD/placeholder"

[[ $ok -eq 1 ]] && exit 0 || exit 1
