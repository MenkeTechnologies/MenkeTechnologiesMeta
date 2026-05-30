#!/usr/bin/env bash
# For every Cargo.toml `description` field, pin that the value
# does NOT contain two consecutive spaces.
#
# Double-spaces in description text:
#
#   - Are nearly always typos (sloppy fingers, dropped word
#     leaving its trailing space adjacent to the next word's
#     leading space)
#   - Render in crates.io's card view as visible gaps that
#     readers notice as "looks wrong but I can't tell why"
#   - Confuse downstream parsers that split on whitespace —
#     e.g., a tool building a tag cloud from descriptions
#     would treat "  " as an empty token
#   - Indicate the description was hand-edited rather than
#     generated, signaling reduced editorial polish
#
# The convention across every modern manual style guide
# (Chicago Manual, AP, etc.) is single-space between
# sentences and within text. The two-space convention is a
# typewriter-era holdover that's been deprecated for decades
# in published writing.
#
# Detection: grep for `  ` (two consecutive ASCII spaces) in
# the extracted description string. Tab + space, multiple
# tabs, or other whitespace combinations are NOT flagged
# (those are TOML-level concerns caught by iter-73 TOML
# parseability, not description-content concerns).
#
# Pairs with iter-27 / iter-47 / iter-53 / iter-94 / iter-141 /
# iter-143 — the cargo description shape catalog now has SEVEN
# gates:
#   length cap (27), no period (47), length floor (53),
#   no URL (94), no placeholders (141), capitalized (143),
#   no double-space (151).
#
# 27/27 crates green at iter-151 add — pure regression floor.
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

    if echo "$desc" | grep -qE '  '; then
        echo "FAIL  $cargo: description contains double space — \"$desc\""
        bad=$((bad + 1))
        ok=0
    else
        echo "PASS  $cargo"
    fi
done

echo "---"
echo "Summary: $checked descriptions checked, $bad with double-space content"

[[ $ok -eq 1 ]] && exit 0 || exit 1
