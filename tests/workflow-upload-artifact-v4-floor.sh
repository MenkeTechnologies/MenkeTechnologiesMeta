#!/usr/bin/env bash
# For every workflow yml step using `actions/upload-
# artifact`, pin that the major version is v4 or higher.
# GitHub hard-deprecated v1, v2, and v3.
#
# GitHub's deprecation timeline for actions/upload-artifact:
#
#   v1: deprecated 2022, backend sunset
#   v2: deprecated 2023, backend sunset
#   v3: DEPRECATED 2024-11-30, HARD-FAILURE since
#       2025-01-30. v3 calls now error with:
#         "This request has been automatically failed
#          because it uses a deprecated version of
#          actions/upload-artifact: v3"
#       The action exits non-zero immediately on every
#       run. No workaround; bump to v4 or v6 is
#       mandatory.
#   v4: rewritten artifact backend (different storage,
#       different ID scheme — v3 and v4 artifacts are
#       NOT interchangeable). Per-job artifact upload.
#   v6: latest. Supports per-OS artifact name collision
#       handling, retention-days defaults aligned with
#       org settings.
#
# Why this matters:
#
#   - Unlike actions/cache (where v3 still works but
#     emits warnings), upload-artifact@v3 is now a hard
#     failure on every workflow run. A workflow with
#     v3 still in it doesn't just warn — it BREAKS.
#
#   - The cost of catching this drift late is concrete:
#     every PR build, every release build, every
#     scheduled job pinned to v3 is currently failing
#     in CI. Reviewers see red checkmarks on every PR
#     because of a 1-line dependency that should be
#     bumped trivially.
#
#   - Cross-job artifact passing (job A uploads, job B
#     downloads) breaks ASYMMETRICALLY when one side
#     is on v3 and the other on v4. Mixed versions in
#     one workflow file produce confusing "artifact
#     not found" errors at download time.
#
#   - actions/download-artifact has the same timeline:
#     v3 deprecated 2024-11-30, hard-failure 2025-
#     01-30. v3 download against v4 upload also fails.
#     This gate covers both sides of the artifact
#     handshake.
#
# Detection: regex on `actions/upload-artifact@v[1-3]`
# OR `actions/download-artifact@v[1-3]` (any minor/
# patch suffix). Comments excluded.
#
# Pairs with:
#   iter-87:  actions/checkout@v4+ floor
#   iter-192: actions/cache@v4+ floor
#   iter-193: actions/upload-artifact@v4+ floor (this)
#
# The actions/* deprecation-floor family now spans
# three gates. Pattern: any actions/* GitHub formally
# deprecates past a major version gets pinned to the
# minimum supported.
#
# 6/6 upload/download-artifact uses on v4 or v6 at
# iter-193 add (no v3 or earlier remaining). Pure
# regression floor.
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
        if echo "$stripped" | grep -qE 'actions/(upload|download)-artifact@v[1-3]\b'; then
            echo "FAIL  $wf:$ln_num: actions/(up|down)load-artifact pinned to deprecated major version — v3 hard-fails since 2025-01-30, bump to @v4 or @v6. Line: $text"
            old=$((old + 1))
            ok=0
        fi
    done < <(grep -nE 'actions/(upload|download)-artifact@' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked artifact action uses checked, $old below v4 floor"

[[ $ok -eq 1 ]] && exit 0 || exit 1
