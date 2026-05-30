#!/usr/bin/env bash
# For every Homebrew formula's `desc "..."` field, pin that
# the value does NOT end with a period.
#
# Homebrew's style guide and `brew audit --strict` both enforce
# "no trailing period in desc." The reasons:
#
#   - desc is a SHORT BLURB (≤ 80 chars per iter-136), not a
#     full sentence. The convention treats it as a NOUN PHRASE
#     describing what the formula is ("AWK in Rust") rather
#     than a SENTENCE asserting something ("This formula is
#     AWK in Rust.").
#   - Many display contexts append their own terminal
#     punctuation. `brew info` appends a blank line; the
#     formulae.brew.sh page renders desc inside a div with
#     CSS padding. A trailing period then renders as
#     redundant or appears stranded:
#
#       AWK in Rust.
#                 ↑ trailing period orphaned in the rendered
#                   card
#
#   - Consistency with crates.io desc convention (iter-47
#     covers cargo-side: no trailing period there either).
#     Both ecosystems treat the description as a blurb.
#
# Detection: `${desc: -1}` extracts the last char, compare
# against `.`.
#
# Pairs with iter-75 (desc presence), iter-136 (≤ 80 chars),
# iter-137 (starts with capital). Four gates now pin the desc
# field's shape from start to end:
#   - Presence (iter-75)
#   - Starting character (iter-137)
#   - Length (iter-136)
#   - Ending punctuation (iter-138)
#
# 10/10 formulas green at iter-138 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
trailing=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    desc=$(grep -m1 -oE '^\s+desc *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ -z "$desc" ]]; then
        continue  # presence checked by iter-75
    fi

    last="${desc: -1}"
    if [[ "$last" == "." ]]; then
        echo "FAIL  $f: desc ends with period — last 40 chars: ...${desc: -40}"
        trailing=$((trailing + 1))
        ok=0
    else
        echo "PASS  $f: desc ends with '$last'"
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $trailing with trailing period in desc"

[[ $ok -eq 1 ]] && exit 0 || exit 1
