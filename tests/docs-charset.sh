#!/usr/bin/env bash
# For every docs/*.html across the umbrella, pin that there is a
# `<meta charset="utf-8">` declaration.
#
# Without `<meta charset>`, browsers fall back to encoding heuristics
# (or `Content-Type` HTTP header — but GitHub Pages serves with a
# generic header). For UTF-8-encoded HTML containing em-dashes,
# typographic quotes, or any non-ASCII character, the fallback
# produces mojibake (e.g., `—` rendered as `â€"`).
#
# The HTML5 spec requires `<meta charset>` within the first 1024
# bytes of the document — the browser starts encoding-detection
# parsing AT byte 0 and can't change midway. A `<meta charset>`
# placed deep in the body is silently ignored.
#
# Test verifies BOTH presence AND that the value is utf-8 (case-
# insensitive). A `<meta charset="iso-8859-1">` form would pass a
# naive presence check but break utf-8 content rendering.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0
wrong=0

while IFS= read -r doc; do
    [[ -f "$doc" ]] || continue
    checked=$((checked + 1))

    # Extract first <meta charset="..."> declaration, case-insensitive.
    val=$(grep -m1 -ioE '<meta[[:space:]]+charset="[^"]+"' "$doc" 2>/dev/null \
          | sed -E 's/.*charset="([^"]+)".*/\1/' | tr '[:upper:]' '[:lower:]')

    if [[ -z "$val" ]]; then
        echo "FAIL  $doc: no <meta charset> declaration"
        missing=$((missing + 1))
        ok=0
    elif [[ "$val" != "utf-8" ]]; then
        echo "FAIL  $doc: <meta charset=\"$val\"> — non-utf-8 will mojibake non-ASCII content"
        wrong=$((wrong + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -path './MenkeTechnologiesPublications' -prune -o -type f -path '*/docs/*.html' -print 2>/dev/null)

echo "---"
echo "Summary: $checked docs/*.html files checked, $missing without charset, $wrong with non-utf-8 charset"

[[ $ok -eq 1 ]] && exit 0 || exit 1
