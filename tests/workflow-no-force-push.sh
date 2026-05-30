#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# command uses `git push -f`, `--force`, or
# `--force-with-lease` to overwrite remote history.
#
# Per CLAUDE.md's git safety protocol: NEVER run force
# push to main/master, warn the user if they request it.
# In CI workflows, force-push is even more dangerous
# because:
#
#   - CI runs on EVERY workflow trigger. A force-push in a
#     workflow that fires on push, schedule, or
#     workflow_dispatch can repeat indefinitely without
#     human notice — each run rewrites the destination
#     branch's history.
#
#   - PR review of force-push-bearing workflows is harder
#     because the reviewer has to mentally simulate "what
#     happens if this runs N times" rather than evaluating
#     a single execution. The N-times semantics for
#     `git push --force` is "the destination always
#     matches the last CI run, regardless of what
#     contributors pushed in between."
#
#   - Branch protection rules may be bypassable by the CI
#     bot's token (depending on configuration). Force-push
#     from CI can silently undo protected-branch policies
#     that were intended for human pushes.
#
#   - The classic disaster: a force-push from CI that
#     happens to run during a release cycle wipes out
#     concurrent feature branches' merges. Recovery
#     requires the dropped commits' SHAs from the
#     reflog (recoverable but stressful).
#
# `--force-with-lease` is SAFER than `--force` (it
# refuses to overwrite if the remote ref has moved since
# the last fetch) but still falls into the "rewrites
# history" category that CI workflows shouldn't be doing.
# Force-push from CI is almost always wrong; if a
# specific use case (e.g., rebasing a release branch to
# squash CI-bot commits before tagging) needs it, the
# workflow should be explicitly designed for that single
# purpose with explicit branch-name allowlists, not
# generic `git push --force-with-lease HEAD:main`.
#
# Detection: regex on `git push` line containing `-f`,
# `--force`, or `--force-with-lease` flag. Comments
# excluded.
#
# Pairs with workflow security defense family. TWELFTH
# security gate.
#
# 0/90 workflows use force-push at iter-183 add — pure
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
        if echo "$stripped" | grep -qE 'git push.*(-f\b|--force\b|--force-with-lease\b)'; then
            echo "FAIL  $wf:$ln_num: force-push from CI rewrites remote history — design a specific bounded workflow instead. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'git push' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky force-push uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
