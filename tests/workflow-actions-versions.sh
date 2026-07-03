#!/usr/bin/env bash
# Inventory of GitHub Actions versions referenced across every
# .github/workflows/*.yml in the umbrella. Surfaces version mix
# (e.g., actions/checkout@v4 mixed with @v6) without enforcing a
# specific version.
#
# This is INFORMATIONAL only — exits 0 regardless of findings.
# Reasoning: forcing a single version across all 64 submodules
# would create a coordinated-update burden that doesn't match how
# each repo's own dev cadence works. The signal is "here's your
# version distribution; coordinate updates if you want consistency."
#
# Tracks the action-name + version pairs and reports counts. Also
# flags actions referenced by SHA (full 40-char hex) — those are
# the most reproducible reference shape per GitHub's own security
# best-practice docs.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit

# Find every .github/workflows/*.yml across the umbrella + meta.
files=$(find . -path './.git' -prune \
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
[[ -n "$files" ]] || { echo "SKIP  no workflow files found"; exit 0; }

n_files=$(echo "$files" | wc -l | tr -d ' ')
echo "Scanning $n_files workflow files for action version references..."
echo

# Extract `uses: <name>@<ref>` lines. ref shapes:
#   @vN          — major-version float (most common)
#   @vN.M[.P]    — pinned semver
#   @<40-hex>    — SHA-pinned (most reproducible per GH security guidance)
echo "=== action-version distribution (top 20) ==="
echo "$files" | xargs grep -h "uses: " 2>/dev/null \
    | grep -oE 'uses: *[A-Za-z0-9_/.-]+@[A-Za-z0-9._-]+' \
    | sed 's|^uses: *||' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -20

# Count SHA-pinned references (40-char hex after @).
sha_pinned=$(echo "$files" | xargs grep -hE 'uses: *[^@]+@[0-9a-f]{40}\b' 2>/dev/null | wc -l | tr -d ' ')
total_refs=$(echo "$files" | xargs grep -c "uses: " 2>/dev/null | awk -F: '{t+=$NF} END{print t}')

echo
echo "=== summary ==="
echo "Total action references: $total_refs"
echo "SHA-pinned (40-hex):     $sha_pinned"

# Informational only.
exit 0
