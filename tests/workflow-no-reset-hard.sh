#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# `git reset --hard` command is used.
#
# Per CLAUDE.md's git safety protocol: "Before running
# destructive operations (e.g., git reset --hard, git push
# --force, git checkout --), consider whether there is a
# safer alternative that achieves the same goal. Only use
# destructive operations when they are truly the best
# approach."
#
# In CI workflows, `git reset --hard` is almost always
# wrong:
#
#   - DESTROYS WORKING TREE CHANGES: any uncommitted
#     changes in the runner's working tree are lost.
#     For a fresh checkout this might seem harmless,
#     but workflows that build dependencies in earlier
#     steps and then `git reset --hard` lose those
#     build artifacts silently.
#
#   - DESTROYS LOCAL COMMITS: any commits made in
#     earlier steps (e.g., a release-workflow step
#     that auto-generates a CHANGELOG entry and commits
#     it) get wiped if a later step does
#     `git reset --hard HEAD~1` or similar. The recovery
#     path is the reflog, but CI runners' reflogs are
#     wiped between jobs — recovery is impossible.
#
#   - BYPASSES BRANCH STATE: `git reset --hard
#     origin/main` discards local divergence without
#     surfacing why the divergence exists. If the
#     workflow's previous step accidentally diverged
#     (e.g., a merge conflict resolution that was
#     incorrect), the reset hides the bug instead of
#     surfacing it.
#
#   - PAIRS WITH --force-push: a `git reset --hard <sha>`
#     followed by `git push --force` rewrites both
#     local and remote history. Iter-183 blocks the
#     force-push side; iter-188 blocks the reset-hard
#     side.
#
# Correct patterns for the common use cases:
#
#   - Want a clean working tree: use `git clean -fdx` (in
#     a fresh-checkout context only) or just rely on
#     actions/checkout's auto-clean behavior.
#   - Want to discard a bad merge: use `git reset
#     --merge` (preserves working-tree changes that
#     conflict).
#   - Want to switch branches without committing: use
#     `git stash` then `git checkout`.
#   - Want to reset author state: use `git commit
#     --amend` — wait, that's also forbidden by
#     iter-187. Use `git revert` for true history-
#     preserving rollback.
#
# Detection: regex on `git reset ... --hard` (any
# argument order). Comments excluded.
#
# Pairs with iter-183 (no force-push), iter-187 (no
# --amend). All three are members of the git-history-
# preservation family. SEVENTEENTH security gate.
#
# 0/90 workflows use reset --hard at iter-188 add —
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
            \#*|name:*|-\ name:*) continue ;;
        esac
        if echo "$stripped" | grep -qE 'git reset.*--hard'; then
            echo "FAIL  $wf:$ln_num: git reset --hard destroys local state — use git reset --merge, git revert, or git stash. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'git reset' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky reset --hard uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
