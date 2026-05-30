#!/usr/bin/env bash
# For every docs/*.html across the umbrella, pin that the document
# carries a `<meta name="viewport" content="...">` tag.
#
# Without it, mobile WebKit (iOS Safari, Android Chrome, in-app
# browsers like LinkedIn / X / Slack) renders the page at a fixed
# 980px desktop width, then visually scales it down — leaving the
# user pinch-zooming to read text. Every accessibility / SEO /
# mobile-readiness audit (Lighthouse, axe-core, PageSpeed Insights)
# flags missing viewport as a hard mobile failure.
#
# Convention: `<meta name="viewport" content="width=device-width,
# initial-scale=1">` is the canonical value — content scales to
# the device's physical width and renders at 1:1 zoom on load.
#
# Test only asserts the tag's existence — exact `content="..."`
# value is left to per-repo discretion. The bare presence of the
# tag is what mobile WebKit reads to switch out of legacy-desktop
# rendering mode.
#
# 894/894 docs files passing at iter-58 add — this is a pure
# regression floor (catches accidental hand-edit deletion, no
# active drift yet).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r doc; do
    [[ -f "$doc" ]] || continue
    checked=$((checked + 1))
    if ! grep -qiE '<meta[^>]+name=["'\'']viewport["'\'']' "$doc" 2>/dev/null; then
        echo "FAIL  $doc: no <meta name=\"viewport\"> tag"
        missing=$((missing + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/docs/*.html' -print 2>/dev/null)

echo "---"
echo "Summary: $checked docs/*.html files checked, $missing without viewport meta"

[[ $ok -eq 1 ]] && exit 0 || exit 1
