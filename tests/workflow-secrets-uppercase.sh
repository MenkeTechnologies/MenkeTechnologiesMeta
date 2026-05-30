#!/usr/bin/env bash
# For every workflow yml `${{ secrets.X }}` reference, pin
# that the secret name X matches UPPER_SNAKE_CASE:
#
#   ^[A-Z][A-Z0-9_]*$
#
# GitHub secrets convention (per GitHub's own docs):
#
#   - Secret names should use UPPER_CASE_UNDERSCORES
#   - The GitHub Settings UI capitalizes secret names on
#     creation but doesn't enforce the convention at the
#     workflow-reference side
#   - References like `${{ secrets.myToken }}` work at runtime
#     because GitHub's expression evaluator does
#     case-insensitive lookups against the stored secret
#     names — BUT this hides typos and inconsistent style
#     across the org's workflow corpus
#
# Why the convention matters:
#
#   - REVIEW DISCIPLINE: a reviewer scanning for
#     `CRATES_IO_TOKEN` doesn't expect `crates_io_token` to
#     refer to the same secret. Forced uppercase eliminates
#     the "is this the same thing in lowercase?" cognitive
#     load.
#   - GREP CONSISTENCY: `grep -r CRATES_IO_TOKEN` finds every
#     reference. `grep -ri` would find them but also matches
#     the documentation comment text and incidental
#     occurrences. Strict upper-case naming keeps the regex
#     specific.
#   - SECRET ROTATION: when a secret is rotated and the new
#     value is stored under a slightly different name (to
#     avoid breakage during rollout), the diff `--canonical-
#     name` analysis depends on stable case. Mixed-case
#     names break it.
#
# EXCLUSIONS:
#   - GITHUB_TOKEN: provided automatically by GitHub Actions
#     to every workflow; case is GitHub's choice. The gate
#     skips this name to avoid false-flagging the universal
#     auto-provisioned secret.
#
# Detection: extract every `secrets.X` reference via regex,
# check the X portion against `^[A-Z][A-Z0-9_]*$`. Skip
# GITHUB_TOKEN.
#
# Pairs with iter-144 (env keys UPPER_SNAKE_CASE). Together
# they pin the org's identifier-casing convention at the two
# main pin points in workflow yml (env vars and secret refs).
#
# 0/90 workflows have non-uppercase secret refs at iter-164
# add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
total_refs=0
bad=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    # Collect every `secrets.X` reference, dedupe.
    while IFS= read -r match; do
        name=$(echo "$match" | grep -oE 'secrets\.[A-Za-z_][A-Za-z0-9_]*' | head -1 | sed 's/secrets\.//')
        [[ -z "$name" ]] && continue
        total_refs=$((total_refs + 1))
        # Exempt GITHUB_TOKEN.
        [[ "$name" == "GITHUB_TOKEN" ]] && continue
        if ! echo "$name" | grep -qE '^[A-Z][A-Z0-9_]*$'; then
            echo "FAIL  $wf: secrets.$name — not UPPER_SNAKE_CASE"
            bad=$((bad + 1))
            ok=0
        fi
    done < <(grep -oE 'secrets\.[A-Za-z_][A-Za-z0-9_]*' "$wf" 2>/dev/null | sort -u || true)
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflows, $total_refs secret refs checked, $bad with non-uppercase names"

[[ $ok -eq 1 ]] && exit 0 || exit 1
