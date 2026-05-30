#!/usr/bin/env bash
# For every Homebrew formula's `desc` field, pin that the
# value is a SINGLE-LINE string (no heredoc form, no
# unterminated double-quote continuation).
#
# Brew-side mirror of iter-190 (cargo description single-
# line). Ruby's syntax accepts multi-line strings via:
#
#   desc <<~DESC
#     First line of description.
#     Second line.
#   DESC
#
# or via line-continuation with escape:
#
#   desc "First part of long " \
#        "description that continues"
#
# or by accident if a contributor leaves the closing
# quote on the next line:
#
#   desc "First line
#     of description"
#
# Homebrew's parser accepts all three forms, but the
# rendering ecosystem expects single-line:
#
#   - `brew info <name>` info card renders desc as one
#     line. Multi-line gets truncated at first newline
#     or rendered with escape sequences visible.
#
#   - `brew search <pattern>` table column shows desc
#     left-truncated to fit column width. Embedded
#     newlines collapse to whitespace, producing
#     mashed-together blobs.
#
#   - formulae.brew.sh page renders desc as the SEO
#     `<meta description>` and the page subtitle.
#     Multi-line breaks the single-line spec for both
#     contexts.
#
# Detection:
#   - heredoc form: `desc <<` or `desc <<~`
#   - unterminated quote: line ending with `"<text>$`
#     where the closing quote is on a later line
#
# The unterminated-quote check is approximate (a single-
# line `desc "x"` would also match if it had an
# unterminated final character, but those aren't current
# patterns). The form check is precise.
#
# Pairs with the brew formula desc shape catalog:
#
#   iter-75:  presence (field exists)
#   iter-136: length ≤ 80 chars
#   iter-137: starts with capital or digit
#   iter-138: no trailing period
#   iter-142: no placeholder markers
#   iter-152: no double spaces
#   iter-177: no shouty 4+ ALL-CAPS
#   iter-191: single-line (this gate)
#
# Now fully symmetric with cargo description shape catalog
# (iter-27/47/53/94/141/143/151/178/190).
#
# 10/10 formulas green at iter-191 add — pure regression
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
bad=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    if grep -qE '^\s+desc\s+<<' "$f"; then
        echo "FAIL  $f: desc uses heredoc form — brew info renders single-line only"
        bad=$((bad + 1))
        ok=0
        continue
    fi

    # Check for unterminated double-quote on desc line
    if grep -qE '^\s+desc\s+"[^"]*$' "$f"; then
        echo "FAIL  $f: desc has unterminated quote on its own line — multi-line continuation"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $bad with multi-line desc"

[[ $ok -eq 1 ]] && exit 0 || exit 1
