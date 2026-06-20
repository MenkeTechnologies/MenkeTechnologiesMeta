#!/usr/bin/env bash
# For every docs/*.html across the umbrella, pin that the file
# opens with `<!DOCTYPE html>` (HTML5 declaration).
#
# Without a DOCTYPE, browsers fall back to "quirks mode" — a
# legacy compat layer that emulates pre-standard IE rendering.
# Quirks mode causes silent layout differences:
#   - CSS box-sizing defaults to content-box AND `padding`
#     adds OUTSIDE the box (vs standard "padding adds inside")
#   - vertical-align baseline behavior shifts
#   - <table> width sums differently
#   - `display: inline-block` shipping for non-inline elements
#     behaves like the old IE hasLayout property
#
# The page renders but doesn't match what the author intended
# in standards mode. The maintainer's local Firefox/Chrome
# inheriting the cached standards-mode resolution doesn't notice
# until a user reports a visual glitch on a fresh-cache browser.
#
# Test verifies the FIRST non-blank line (allowing leading
# whitespace) starts with case-insensitive `<!doctype`. Empty
# files or files starting with `<html>` directly are flagged.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r doc; do
    [[ -f "$doc" ]] || continue
    checked=$((checked + 1))
    # Check first 2 lines for DOCTYPE (allows for one blank line at top).
    if ! head -2 "$doc" | grep -qiE '^[[:space:]]*<!DOCTYPE'; then
        first=$(head -1 "$doc" | head -c 60)
        echo "FAIL  $doc: no <!DOCTYPE> in first 2 lines (got: '$first')"
        missing=$((missing + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -path './MenkeTechnologiesPublications' -prune -o -type f -path '*/docs/*.html' -print 2>/dev/null)

echo "---"
echo "Summary: $checked docs/*.html files checked, $missing without <!DOCTYPE>"

[[ $ok -eq 1 ]] && exit 0 || exit 1
