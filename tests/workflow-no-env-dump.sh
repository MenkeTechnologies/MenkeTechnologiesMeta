#!/usr/bin/env bash
# For every workflow `run:` step, pin that the step does NOT
# dump the environment to a place where its contents become
# observable.
#
# Forbidden patterns:
#
#   printenv                 # prints entire env
#   env > some.file          # captures env to file (may be
#                            # uploaded as artifact, committed,
#                            # or read later in the run)
#   env >> some.file         # append form
#   env | tee ...            # tees env into a logged stream
#
# Why this matters: GitHub Actions inlines repository secrets
# into the runner's process environment when the workflow
# declares `env: SECRET_NAME: ${{ secrets.SECRET_NAME }}` (or
# implicitly via job-level / step-level env blocks). Dumping
# the env means:
#
#   1. The secret values appear in CI LOGS verbatim. GitHub
#      auto-masks secret VALUES (substring match against
#      `${{ secrets.* }}` references) — but only for values
#      LITERALLY equal to the secret. A secret that contains
#      a substring of another secret, or one that's a
#      regenerated rotation, or a transformed form (base64-
#      decoded), bypasses the masking. The log artifact then
#      preserves the leaked secret indefinitely (90 days
#      retention by default, longer if pinned).
#   2. Uploaded artifacts (env > file → upload-artifact)
#      bypass log masking entirely — the file content is
#      not redacted. Anyone who can download the artifact
#      sees every secret in the env.
#   3. `env > $GITHUB_ENV` (which IS a legitimate pattern for
#      passing values between steps) gets caught by this gate
#      ONLY when the redirect target is a path other than
#      $GITHUB_ENV. Detection allowlists $GITHUB_ENV
#      explicitly.
#
# Common drift introductions:
#   - Debugging session: contributor adds `printenv` to
#     diagnose a CI issue, opens a PR with the change still
#     in place, gets merged before review notices.
#   - Generic "dump everything" step copied from a Stack
#     Overflow troubleshooting answer.
#   - Cargo-cult `env > /tmp/env.txt` to "save state" between
#     steps (use `$GITHUB_ENV` instead).
#
# Allowlist:
#   - `env > $GITHUB_ENV`     (canonical GitHub Actions
#                              env-passing pattern)
#   - `env >> $GITHUB_ENV`    (append form)
#   - lines starting with `#`  (comments)
#
# Detection: bare `printenv`, OR `env` followed by `>`/`>>`/`|`
# where the target isn't $GITHUB_ENV. Comments stripped before
# matching.
#
# 90/90 workflow files green at iter-114 add — security-
# critical regression floor against secret leakage.
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
        # Skip comments.
        case "$stripped" in
            \#*) continue ;;
        esac
        # Allowlist: env > $GITHUB_ENV or env >> $GITHUB_ENV.
        if echo "$stripped" | grep -qE 'env >>?\s*"?\$GITHUB_ENV|env >>?\s*"?\$\{GITHUB_ENV\}'; then
            continue
        fi
        if echo "$stripped" | grep -qE '\bprintenv\b|\benv >\s|\benv >>\s|\benv \| tee\b'; then
            echo "FAIL  $wf:$ln_num: env-dump pattern — secrets leak into logs/artifacts. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '\bprintenv\b|\benv (>>|>|\|)' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky env-dump patterns"

[[ $ok -eq 1 ]] && exit 0 || exit 1
