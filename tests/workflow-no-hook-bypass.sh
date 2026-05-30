#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# command uses `--no-verify` or `--no-gpg-sign` flags to
# bypass git security hooks.
#
# Per CLAUDE.md's git safety protocol: NEVER skip hooks
# (--no-verify) or bypass signing (--no-gpg-sign,
# --no-gpg-sign=false, -c commit.gpgsign=false) unless the
# user has EXPLICITLY asked for it. CI workflows shouldn't
# preemptively encode hook-bypass — if a hook fails, the
# fix is to investigate the underlying issue, not to skip
# the hook.
#
# Why these flags are dangerous in CI:
#
#   --no-verify (git commit / push / merge):
#     Skips:
#       - pre-commit hook (catches secrets, lint errors,
#         test failures, formatting violations)
#       - pre-push hook (catches forbidden branches,
#         protected references, large-file commits)
#       - commit-msg hook (catches malformed messages,
#         missing issue references)
#       - prepare-commit-msg hook (auto-fills templates)
#       - pre-receive hook on the remote (catches policy
#         violations server-side)
#
#     Bypassing in CI means: whatever local protections
#     contributors rely on don't apply to CI-authored
#     commits. A CI-bot commit can ship things that would
#     be caught at every developer's machine.
#
#   --no-gpg-sign / -c commit.gpgsign=false:
#     Skips signature verification on commits. For repos
#     that require signed commits (branch protection
#     "require signed commits" setting), this flag will
#     cause the resulting commits to be REJECTED at push
#     time — so the bypass doesn't even achieve its
#     intended purpose. Worse, it removes the integrity
#     guarantee that downstream consumers rely on when
#     trusting org commits.
#
#     Worse, --no-gpg-sign on a release-tag commit means
#     the released tag's authenticity can't be verified by
#     downstream consumers (`gpg --verify` fails on the
#     tag).
#
# Correct pattern: fix the underlying issue that caused
# the hook to fail, not bypass the hook. If the hook is
# wrong, fix the hook. If a CI workflow legitimately
# can't satisfy a hook (e.g., dependabot-style commits
# that bypass signed-commit requirements via API), use
# the github-actions[bot] GPG key via actions/checkout
# rather than --no-gpg-sign.
#
# Detection: regex on `--no-verify` or `--no-gpg-sign`
# in run blocks. Comments excluded.
#
# Pairs with workflow security defense family. ELEVENTH
# security gate.
#
# 0/90 workflows use hook-bypass flags at iter-182 add —
# pure regression floor.
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
            \#*) continue ;;
        esac
        if echo "$stripped" | grep -qE -- '--no-verify\b|--no-gpg-sign\b'; then
            echo "FAIL  $wf:$ln_num: hook-bypass flag — fix the underlying issue instead. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE -- '--no-verify|--no-gpg-sign' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky hook-bypass flag uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
