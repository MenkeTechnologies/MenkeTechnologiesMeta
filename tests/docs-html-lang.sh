#!/usr/bin/env bash
# For every docs/*.html across the umbrella, pin that the `<html>`
# tag carries a `lang` attribute (e.g. `<html lang="en">`).
#
# Without `lang`, accessibility and SEO both degrade silently:
#   - Screen readers can't switch pronunciation rules (en-US "data"
#     vs en-GB "data") and may fall back to the user's system
#     locale, mispronouncing content
#   - Google language detection takes a guess based on document
#     body and may misclassify (especially for short or
#     code-heavy pages), affecting search ranking
#   - WCAG 2.1 Level A: 3.1.1 Language of Page is a hard
#     accessibility requirement; automated audits (Lighthouse,
#     axe-core) fail without it
#
# Test scans every line for `<html [...] lang=` rather than just
# the top of the file — some docs (zshrs/port_report.html) have
# long comment headers between DOCTYPE and the actual <html> tag.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r doc; do
    [[ -f "$doc" ]] || continue
    checked=$((checked + 1))
    # Find any `<html` tag and check it has a lang attribute.
    # `grep -m1` stops at first match for efficiency on large files.
    html_tag=$(grep -m1 -oE '<html[^>]*>' "$doc" 2>/dev/null)
    if [[ -z "$html_tag" ]]; then
        echo "FAIL  $doc: no <html> tag found at all"
        missing=$((missing + 1))
        ok=0
    elif [[ "$html_tag" != *lang=* ]]; then
        echo "FAIL  $doc: <html> tag missing lang attribute (got: $html_tag)"
        missing=$((missing + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -path './MenkeTechnologiesPublications' -prune -o -path '*/node_modules' -prune -o -path '*/runtime/grammars/sources' -prune -o -path '*/libs/JUCE' -prune -o -path '*/frontend/vendor' -prune -o -type f -path '*/docs/*.html' -print 2>/dev/null)

echo "---"
echo "Summary: $checked docs/*.html files checked, $missing without <html lang=...>"

[[ $ok -eq 1 ]] && exit 0 || exit 1
