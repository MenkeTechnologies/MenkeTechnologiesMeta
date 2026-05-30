#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# command uses `git config --global` to modify CI's git
# configuration.
#
# Why this matters:
#
# GitHub Actions runners are EPHEMERAL but the runner's HOME
# directory persists across steps within the same job. A
# `git config --global` write lands in
# /home/runner/.gitconfig (or equivalent on Windows/macOS
# runners) and:
#
#   - Affects EVERY subsequent step's git operations in
#     the same job, not just the one that set it. The
#     interactions across steps are non-obvious; a later
#     `cargo build` that fetches git deps inherits the
#     global config.
#
#   - On self-hosted runners (which the org may use in the
#     future), persists ACROSS jobs and even across
#     workflows. State pollution from one workflow leaks
#     into others — the kind of bug that's hard to
#     reproduce in CI logs because the leaked state isn't
#     visible.
#
#   - Can override security-relevant settings. A workflow
#     that sets `git config --global core.sshCommand`,
#     `core.askPass`, or `credential.helper` can redirect
#     git's authentication to attacker-controlled
#     scripts. Forbid `--global` to keep the attack
#     surface scoped to the working tree.
#
# Correct pattern: use the LOCAL config (no --global flag)
# which is scoped to the current repo's .git/config:
#
#   git config user.email "ci@example.com"   # CORRECT
#   git config --global user.email "..."     # WRONG
#
# Local config is auto-discarded when the runner's
# checkout directory is wiped between jobs.
#
# Detection: regex on `git config --global`. Comments
# excluded.
#
# Pairs with iter-93 (no pull_request_target), iter-106
# (no curl-pipe-sh), iter-107 (no eval), iter-112 (no
# script-injectable github.event), iter-114 (no env-dump),
# iter-116 (no id-token:write), iter-126 (no
# permissions:write-all). EIGHTH security gate in the
# workflow injection / state-leak defense family.
#
# 0/90 workflows use git config --global at iter-179 add —
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
        echo "FAIL  $wf:$ln_num: git config --global modifies runner-persistent state — use local config (no --global flag). Line: $text"
        risky=$((risky + 1))
        ok=0
    done < <(grep -nE 'git config --global' "$wf" 2>/dev/null || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky git config --global uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
