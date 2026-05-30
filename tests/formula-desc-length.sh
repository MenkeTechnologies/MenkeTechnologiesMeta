#!/usr/bin/env bash
# For every Homebrew formula's `desc "..."` field, pin that the
# value is ≤ 80 characters.
#
# Homebrew's style guide and `brew audit --strict` both enforce
# the 80-char cap. The reasons:
#
#   - `brew info <name>` output: the desc is rendered as the
#     second line of the info card. Terminals default to 80
#     columns; descriptions exceeding 80 chars wrap awkwardly
#     in the truncated tail.
#   - `brew search <pattern>` table view: each result shows
#     name + desc in a fixed-width column. Long descs are
#     truncated with ellipsis at the column boundary —
#     information past the boundary is hidden, defeating the
#     purpose of search.
#   - The formulae.brew.sh online index uses the desc as the
#     SEO meta-description for the formula page. Google
#     truncates search-result snippets around 160 chars
#     (including title); a 100-char desc + 60-char title +
#     padding overflows the snippet, hiding both ends.
#
# The 80-char cap matches the canonical Homebrew convention.
# crates.io's description (Rust manifest) has a SEPARATE cap
# (iter-27 covers 150 chars). The two fields serve different
# audiences (brew vs crates.io); their length conventions
# differ accordingly.
#
# Detection: `${#var}` on the desc string. The string is
# pre-extracted from the formula via grep + sed (the canonical
# pattern used by iter-75's desc-presence gate).
#
# Pairs with iter-75 (desc field exists). iter-75 pins
# PRESENCE; iter-136 pins LENGTH. Together: the desc field is
# both present and well-shaped for the formula's downstream
# rendering contexts.
#
# 10/10 formulas green at iter-136 add — pure regression floor.
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
too_long=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    desc=$(grep -m1 -oE '^\s+desc *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ -z "$desc" ]]; then
        continue  # presence checked by iter-75
    fi

    len=${#desc}
    if [[ $len -le 80 ]]; then
        echo "PASS  $f: desc $len chars"
    else
        echo "FAIL  $f: desc $len chars (exceeds 80-char cap): \"$desc\""
        too_long=$((too_long + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $too_long with desc exceeding 80 chars"

[[ $ok -eq 1 ]] && exit 0 || exit 1
