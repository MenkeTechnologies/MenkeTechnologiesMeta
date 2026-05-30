#!/usr/bin/env bash
# For every Cargo.toml `description` field, pin that the first
# character is uppercase A-Z or a digit 0-9.
#
# Cargo-side mirror of iter-137 (brew formula desc capitalization).
# Same rationale on the crates.io side:
#
#   - crates.io card view: desc is the one-line tagline.
#     Lowercase lead reads as a fragment ("ust port of awk
#     in Rust" — starting "ust" looks broken at a glance).
#   - `cargo search` output: each row's desc column reads
#     left-to-right; capitalization signals "start of a new
#     blurb" vs continuation of a wrapped line.
#   - docs.rs crate page: desc renders as the `<meta
#     description>` and the on-page subtitle. Both contexts
#     expect sentence-case per HTML/SEO conventions.
#   - rust-analyzer hover tooltips on `extern crate <name>`:
#     desc appears as the hover text. Lowercase first char
#     is jarring next to the formatted "name" header.
#
# Allowed first characters: [A-Z] (canonical sentence-case)
# or [0-9] (digit-leading descs like "1:1 Rust port of..."
# from powerliners — the digit prefix is intentional content
# that conveys the ratio).
#
# Rejected: lowercase a-z, punctuation, special chars.
#
# Detection: `${desc:0:1}` extracts the first byte, regex
# match against [A-Z0-9].
#
# The cargo description shape catalog now has SIX gates:
#
#   iter-27:  length ≤ 150  (crates.io display fit)
#   iter-47:  no trailing period (style — blurb not sentence)
#   iter-53:  length ≥ 20  (meaningful blurb)
#   iter-94:  no URL inside  (URLs in other fields)
#   iter-141: no TODO/FIXME placeholders (no abandoned dev)
#   iter-143: starts with capital letter or digit (this gate)
#
# Now symmetric with the brew formula desc catalog from
# iter-137 / iter-138 / iter-142.
#
# 27/27 crates green at iter-143 add — pure regression floor.
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

    first="${desc:0:1}"
    if echo "$first" | grep -qE '^[A-Z0-9]$'; then
        echo "PASS  $cargo: description starts with '$first'"
    else
        echo "FAIL  $cargo: description starts with '$first' (expected [A-Z] or [0-9]): \"$desc\""
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked descriptions checked, $bad with non-capital first char"

[[ $ok -eq 1 ]] && exit 0 || exit 1
