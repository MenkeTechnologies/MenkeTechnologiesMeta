#!/usr/bin/env bash
# For every .github/workflows/*.yml, pin that the workflow does
# NOT trigger on `pull_request_target`.
#
# `pull_request_target` is GitHub's most dangerous workflow
# trigger — it runs in the context of the BASE branch (the
# target of the PR, typically `main`) but checks out the HEAD
# branch (the PR's content) by default. That combination means:
#
#   - The workflow has access to repository secrets (because
#     it runs as `main`)
#   - It executes potentially untrusted code from a contributor's
#     PR (because the checkout pulls the PR branch)
#
# This is the exact recipe for the most common GitHub Actions
# supply-chain attack: a contributor opens a PR with a malicious
# `setup.sh` or test script; the workflow runs it with secret
# access; the secrets are exfiltrated. The class is so common
# that GitHub's own security guidance has a dedicated warning
# page.
#
# Legitimate uses exist (commenting on PRs from forks, applying
# labels, running pre-flight checks that don't touch PR code)
# but they require careful scoping: explicit `ref: ${{ github.
# event.pull_request.base.sha }}` or similar to avoid checking
# out the untrusted HEAD. Getting that scoping right is hard;
# getting it wrong is catastrophic.
#
# Default-safe policy for this org: NO workflow uses
# pull_request_target. If a workflow genuinely needs the
# elevated context (e.g., to comment on the PR from a fork), add
# an explicit comment + per-step `if:` gating + an issue PR for
# review. The hard rejection at lint time is the right default.
#
# 90/90 workflow files green at iter-93 add — pure regression
# floor against accidental introduction.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))
    if grep -qE '^\s*pull_request_target:|^\s*pull_request_target\s*:' "$wf" 2>/dev/null; then
        line=$(grep -nE 'pull_request_target' "$wf" | head -1)
        echo "FAIL  $wf: uses pull_request_target — SUPPLY-CHAIN ATTACK SURFACE: $line"
        risky=$((risky + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky using pull_request_target"

[[ $ok -eq 1 ]] && exit 0 || exit 1
