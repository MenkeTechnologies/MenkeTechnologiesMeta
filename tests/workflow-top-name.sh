#!/usr/bin/env bash
# For every .github/workflows/*.yml across the umbrella, pin that
# the workflow declares a top-level `name:` field.
#
# Without it, GitHub Actions falls back to the FILE PATH as the
# workflow's display name:
#
#   ".github/workflows/ci.yml"
#
# rendered in:
#   - The Actions tab sidebar (workflow list)
#   - PR check-run names
#   - Status badge generators
#   - GitHub API responses (`gh run list`)
#   - Audit-log entries
#
# A repo with 5 workflows all showing as ".github/workflows/*.yml"
# is unnavigable. Status badges like
# https://github.com/MenkeTechnologies/zshrs/actions/workflows/ci.yml/badge.svg
# render with the FILENAME as the badge label, which the README
# embeds as alt-text — leaking implementation detail to readers
# and breaking on any future filename rename.
#
# A top-level `name:` decouples display from filename: rename the
# workflow file freely without invalidating badge URLs (those use
# the filename) or breaking the display label (that uses `name`).
#
# Test pattern: `^name: <anything>` at line start. Job-level
# `name:` (indented) does NOT count — it's a different namespace.
#
# 90/90 workflow files green at iter-69 add — pure regression
# floor against accidental name-field deletion during reformatting.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
missing=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    if ! grep -qE '^name: *.+' "$wf"; then
        echo "FAIL  $wf: no top-level \`name:\` field (will display as file path in Actions UI)"
        missing=$((missing + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/_deps/*' -prune \
    -o -path '*/libs/JUCE/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $missing without top-level \`name:\`"

[[ $ok -eq 1 ]] && exit 0 || exit 1
