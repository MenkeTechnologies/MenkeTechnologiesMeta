#!/usr/bin/env bash
# For every docs/*.html across the umbrella, pin that the file has
# a non-empty <title> tag in the <head>.
#
# Without a title:
#   - Browser tabs show the URL slug (or "Untitled" on some browsers)
#   - Bookmarks save with no human-readable label
#   - Google search results show the URL or first <h1> as fallback
#   - Twitter/Slack/Discord link cards have no title bar
#   - History API surfaces are unsearchable by title
#
# Iter-3's docs-brand-consistency gate checks that <title> mentions
# the submodule name. Iter-54 covers the upstream concern: <title>
# exists and is non-empty in the first place. Together they bound
# the title's existence + content correctness.
#
# Test extracts the inner text of the first <title>...</title> pair
# and verifies it's non-empty after trimming whitespace.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r doc; do
    [[ -f "$doc" ]] || continue
    checked=$((checked + 1))

    # Extract inner text of first <title>...</title>. tr strips
    # whitespace so a `<title>   </title>` form fails as empty.
    title=$(grep -m1 -oE '<title>[^<]*</title>' "$doc" 2>/dev/null \
            | sed -E 's|^<title>(.*)</title>$|\1|' \
            | tr -d '[:space:]')

    if [[ -z "$title" ]]; then
        # Diagnose: is the tag missing or empty?
        if grep -qE '<title>' "$doc"; then
            echo "FAIL  $doc: <title> tag present but empty (or whitespace only)"
        else
            echo "FAIL  $doc: no <title> tag at all"
        fi
        missing=$((missing + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -path './MenkeTechnologiesPublications' -prune -o -path '*/node_modules' -prune -o -path '*/runtime/grammars/sources' -prune -o -path '*/libs/JUCE' -prune -o -path '*/frontend/vendor' -prune -o -type f -path '*/docs/*.html' -print 2>/dev/null)

echo "---"
echo "Summary: $checked docs/*.html files checked, $missing without non-empty <title>"

[[ $ok -eq 1 ]] && exit 0 || exit 1
