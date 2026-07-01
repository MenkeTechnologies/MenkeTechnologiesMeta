#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# command uses `chmod 777` or `chmod -R 777` (permissive
# any-write permissions).
#
# Why this matters:
#
# `chmod 777` grants READ + WRITE + EXECUTE to user, group,
# AND OTHER. On Linux CI runners, "other" includes any
# process running on the runner — including potential
# malicious processes if the workflow has any privilege
# escalation issue.
#
# Real-world drift introductions:
#
#   - Quick fix for "permission denied" errors in CI logs.
#     A contributor adds `chmod 777` to unblock a build
#     without diagnosing what permission was actually
#     needed (typically the binary was missing +x, which
#     is `chmod +x` not `chmod 777`).
#
#   - Stack Overflow copy-paste — "chmod 777 to fix X" is
#     a top-three answer on permission-related SO posts
#     despite always being wrong. The right answer is
#     `chmod u+x` or `chmod +rX` (capital X executes on
#     dirs only).
#
#   - Test fixture preparation that needs world-writable
#     temp directories — should use `mktemp -d` (creates
#     with safe 700 default) instead of `chmod 777
#     /tmp/foo`.
#
#   - Docker/container builds that drop privileges later.
#     The chmod runs as root in the build stage, but the
#     777 permissions persist into the runtime stage where
#     a less-privileged process can now write to the
#     opened-up location.
#
# Even on ephemeral CI runners (where the broad permissions
# don't outlive the job), 777 is a code-review SIGNAL that
# the author didn't diagnose the actual permission need.
# Force them to fix the root cause.
#
# Detection: regex on `chmod [-R] 777` (including 0777 form).
# Comments excluded. The pattern also matches `chmod -R
# 777`, `chmod 0777`, and `chmod -R 0777`.
#
# Pairs with the workflow security defense family
# (iter-93, iter-106, iter-107, iter-112, iter-114, iter-116,
# iter-126, iter-179). NINTH security gate.
#
# 0/90 workflows use chmod 777 at iter-180 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*|name:*|-\ name:*) continue ;;
        esac
        if echo "$stripped" | grep -qE 'chmod\s+([-]?R\s+)?[0]?777'; then
            echo "FAIL  $wf:$ln_num: chmod 777 grants world-write — use chmod +x or chmod u+x to fix specific permission. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'chmod' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/build/_deps/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky chmod 777 uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
