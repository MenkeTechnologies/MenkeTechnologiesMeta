#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# `git commit --amend` command rewrites the previous
# commit.
#
# Per CLAUDE.md's git safety protocol: "CRITICAL: Always
# create NEW commits rather than amending, unless the user
# explicitly requests a git amend. When a pre-commit hook
# fails, the commit did NOT happen — so --amend would
# modify the PREVIOUS commit, which may result in
# destroying work or losing previous changes."
#
# In CI workflows, the failure mode is worse than in
# interactive use:
#
#   - CI runs UNATTENDED. A workflow that uses --amend
#     rewrites the previous commit's SHA. The new SHA is
#     then pushed (typically with iter-183's forbidden
#     --force flag, but --force-with-lease is also a CI
#     anti-pattern). Downstream consumers who already
#     fetched the old SHA see git divergence and need
#     manual rebase.
#
#   - HOOK INTERACTION: if a pre-commit hook fails, the
#     amend modifies the prior commit instead of the
#     intended new one. A CI-bot workflow that amends
#     after a hook failure can silently mutate previously-
#     signed commits — breaking the commit signing chain
#     for the entire history past that point.
#
#   - LOSS OF AUTHORSHIP: --amend by default preserves
#     the original author but updates the committer. CI
#     workflows that amend over a contributor's commit
#     leave the original Author field intact while
#     changing the Committer to the CI bot — confusing
#     `git log --format='%an %cn'` audits.
#
#   - DOWNSTREAM BREAKAGE: any cached SHA references
#     (cargo lock files using a specific revision, build
#     artifacts tagged with the commit SHA, deploy
#     manifests pinning the SHA) become invalid after the
#     amend rewrites the commit.
#
# Correct pattern: create a NEW commit:
#
#   git commit -m "Fix typo in previous commit"
#   git push
#
# Each CI-bot commit is independent and traceable.
# Reverters and bisects work normally.
#
# Detection: regex on `git commit ... --amend` (any
# argument order). Comments excluded.
#
# Pairs with iter-183 (no force-push). Both rewrite git
# history; --amend rewrites locally before push,
# --force-push rewrites remotely after push. SIXTEENTH
# security gate.
#
# 0/90 workflows use --amend at iter-187 add — pure
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
        if echo "$stripped" | grep -qE 'git commit.*--amend'; then
            echo "FAIL  $wf:$ln_num: git commit --amend rewrites previous SHA — create new commit instead. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'git commit' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky --amend uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
