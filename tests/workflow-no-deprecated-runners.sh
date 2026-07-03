#!/usr/bin/env bash
# For every .github/workflows/*.yml across the umbrella, pin that
# no `runs-on:` line references a GitHub-deprecated OS image.
#
# GitHub retires hosted runner images on a published schedule:
#
#   - ubuntu-18.04:  retired 2022-08-08
#   - macos-10.15:   retired 2022-08-30
#   - macos-11:      retired 2024-06-28
#   - windows-2019:  retired 2025-06-30
#   - ubuntu-20.04:  retired 2025-04-15
#
# Once retired, workflows referencing the image FAIL with:
#
#   The runner of "ubuntu-20.04" Runner is removed at YYYY-MM-DD.
#   For more information, see https://github.blog/...
#
# Workflows using a still-supported-but-deprecation-announced
# image continue running but emit annotations. The fix is
# trivial — bump to `-latest` or the current LTS tag — but the
# fix gets forgotten until the workflow fails on retirement day.
# This gate catches the drift the moment it lands rather than on
# the retirement deadline.
#
# Allowlist (current supported images as of 2026-05-30):
#   ubuntu-latest, ubuntu-24.04, ubuntu-22.04
#   windows-latest, windows-2025, windows-2022
#   macos-latest, macos-15, macos-14, macos-13
#
# Test enforces by EXCLUSION: any `runs-on:` referencing a known-
# retired image fails. Unknown images (matrix vars, custom
# runners with `self-hosted`) are PASSED — the test doesn't
# enumerate every valid value.
#
# 89/89 workflow files green at iter-67 add — pure regression
# floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Retired images — patterns to FAIL on.
deprecated_re='ubuntu-(14\.04|16\.04|18\.04|20\.04)|macos-(10|11|12)([^0-9]|$)|windows-(2016|2019)'

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
deprecated_hits=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    # Look for `runs-on:` followed by an image identifier.
    # Strip leading whitespace and skip matrix-var references like
    # `runs-on: ${{ matrix.os }}` (those expand at runtime; the
    # matrix definition is checked separately).
    runs_on_lines=$(grep -nE '^\s*runs-on: *[A-Za-z0-9._-]+' "$wf" 2>/dev/null || true)
    [[ -n "$runs_on_lines" ]] || continue

    bad_lines=$(echo "$runs_on_lines" | grep -E "($deprecated_re)" || true)

    if [[ -n "$bad_lines" ]]; then
        while IFS= read -r line; do
            echo "FAIL  $wf: $line"
            deprecated_hits=$((deprecated_hits + 1))
        done <<< "$bad_lines"
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
echo "Summary: $checked workflow files checked, $deprecated_hits references to retired GitHub runners"

[[ $ok -eq 1 ]] && exit 0 || exit 1
