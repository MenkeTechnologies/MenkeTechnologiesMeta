#!/usr/bin/env bash
# For every workflow yml step using `actions/cache`, pin
# that the major version is v4 or higher. v1, v2, and v3
# are deprecated by GitHub.
#
# GitHub's deprecation timeline for actions/cache:
#
#   v1: deprecated 2022, no longer maintained
#   v2: deprecated 2023, no longer maintained
#   v3: DEPRECATED 2025-02-01 — runs that use v3 emit
#       deprecation warnings in the Actions tab, and
#       GitHub has signaled that v3 will eventually
#       return non-zero exit (breaking cache-dependent
#       workflows entirely).
#   v4: current minimum. New cache service backend; the
#       v3-and-earlier cache service was sunset.
#   v5: latest. Cross-OS cache support, improved
#       compression, partial-key match enhancements.
#
# Why this matters:
#
#   - Deprecation warnings in CI appear in every
#     workflow run's UI. Reviewers and contributors see
#     them on every PR build and ignore them as noise,
#     which trains the org to ignore ALL deprecation
#     warnings (including ones that matter).
#
#   - When GitHub sunsets the v3 cache service backend
#     entirely (as they did with the v1/v2 backend),
#     v3-using workflows will start failing every run.
#     The fix is trivial — bump `@v3` to `@v4` — but
#     coordinating that bump across a 64-repo org is
#     not trivial unless caught early.
#
#   - Cache misses from v3 against v4-populated caches
#     waste build time. Mixed versions inside one org
#     mean cache sharing breaks between v3 and v4
#     workflows of the same repo.
#
# Detection: regex on `actions/cache@v[1-3]` (any
# minor/patch suffix). Comments excluded.
#
# Pairs with iter-87 (actions/checkout@v4 floor) which
# enforced the same hygiene on actions/checkout. The
# pattern is: any actions/* that GitHub has formally
# deprecated past a major version must be pinned to
# the minimum supported version.
#
# 0/14 cache uses are below v4 at iter-192 add (all are
# v4 or v5). Pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
old=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        checked=$((checked + 1))
        if echo "$stripped" | grep -qE 'actions/cache@v[1-3]\b'; then
            echo "FAIL  $wf:$ln_num: actions/cache pinned to deprecated major version — bump to @v4 or @v5. Line: $text"
            old=$((old + 1))
            ok=0
        fi
    done < <(grep -nE 'actions/cache@' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked actions/cache uses checked, $old below v4 floor"

[[ $ok -eq 1 ]] && exit 0 || exit 1
