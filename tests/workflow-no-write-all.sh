#!/usr/bin/env bash
# For every workflow yml, pin that no `permissions:` block
# uses the catch-all `write-all` value.
#
# GitHub Actions' `permissions` directive accepts three forms:
#
#   permissions: read-all    # all scopes read access only
#   permissions: write-all   # all scopes WRITE access — DANGER
#   permissions:             # fine-grained scoped permissions
#     contents: write
#     pull-requests: read
#
# `write-all` grants every permission scope simultaneously:
# contents:write, deployments:write, issues:write, packages:write,
# pull-requests:write, repository-projects:write, security-events:
# write, statuses:write, actions:write, checks:write, id-token:
# write (iter-116), and more.
#
# Any compromised step in a write-all workflow can:
#   - Push to any branch (including main)
#   - Open / close / merge pull requests
#   - Publish packages
#   - Create / modify deployments
#   - Issue OIDC tokens for cloud federation
#   - Approve checks bypassing branch protection rules
#
# The catch-all form was the LEGACY default before GitHub
# tightened defaults in late 2023 (when iter-104's read-only
# default came in). Modern workflows should declare only the
# permissions actually needed:
#
#   permissions:
#     contents: write       # for release-tag creation
#     # everything else inherits the read-only default
#
# Even when a workflow legitimately needs many permissions
# (e.g., a multi-tap-update orchestrator), each should be
# enumerated explicitly so a reviewer can verify each grant
# against the workflow's actual operations.
#
# Detection: `permissions: write-all` at workflow-top level
# OR at job-level (`permissions: write-all` indented under a
# job). Both forms grant the same dangerous scope.
#
# 90/90 workflow files green at iter-126 add — pure regression
# floor against accidental over-privilege grant.
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
        line="${match#*:}"
        echo "FAIL  $wf:$ln_num: permissions: write-all is the catch-all over-privilege grant — enumerate scoped permissions instead. Line: $line"
        risky=$((risky + 1))
        ok=0
    done < <(grep -nE '^\s*permissions:\s*write-all\s*$' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky permissions: write-all declarations"

[[ $ok -eq 1 ]] && exit 0 || exit 1
