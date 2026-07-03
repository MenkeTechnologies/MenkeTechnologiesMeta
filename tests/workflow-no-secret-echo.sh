#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# echo / export / printf line directly interpolates a
# `${{ secrets.X }}` expression.
#
# Why this matters:
#
# GitHub Actions' `${{ secrets.X }}` substitution runs BEFORE
# bash sees the script. A line like:
#
#   echo "Token: ${{ secrets.CRATES_IO_TOKEN }}"
#
# becomes, after substitution:
#
#   echo "Token: <actual_token_value>"
#
# When bash executes this, the literal token value goes to
# stdout. GitHub's log-masking does intercept exact-match
# secret values (the literal string is replaced with `***`),
# BUT THE MASKING BYPASSES ON:
#
#   - Substrings: a secret containing a substring of another
#     secret (rare but possible during rotation)
#   - Transforms: base64-decoded, URL-encoded,
#     JWT-component-extracted forms
#   - Logging tools that capture stdout BEFORE GitHub's
#     masking pass (e.g., a tool that uploads logs to an
#     external aggregator)
#   - Artifact uploads (upload-artifact bypasses log
#     masking entirely)
#
# The CORRECT PATTERN is to pass the secret via `env:`:
#
#   env:
#     TOKEN: ${{ secrets.CRATES_IO_TOKEN }}
#   run: |
#     echo "Token: $TOKEN"   # bash expands at runtime;
#                            # GitHub masking sees the
#                            # literal value and redacts it
#
# Direct interpolation into echo/export/printf substitutes
# the secret BEFORE bash sees the line, so the value lands
# in command-line arguments where masking is less reliable
# (especially for export, which sets the variable in the
# shell environment and may leak through `env > file`
# operations or `set -x` traces).
#
# Detection: regex on echo/export/printf lines containing
# `${{ secrets.X }}` interpolation. Comments excluded.
#
# Pairs with iter-112 (no script-injectable github.event)
# and iter-114 (no env-dump). All three protect against
# secret leakage through different vectors:
#
#   iter-112: github.event injection vector
#   iter-114: env > file dump vector
#   iter-185: direct-interpolation-into-stdout vector
#
# Together they form the secret-leakage prevention triad.
# FOURTEENTH security gate.
#
# 0/90 workflows directly interpolate secrets into echo/
# export/printf at iter-185 add — pure regression floor.
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
        # Look for `echo`, `export`, `printf` followed by
        # `${{ secrets.X }}` interpolation.
        if echo "$text" | grep -qE '^[[:space:]]+(echo|export|printf)[^|]*\$\{\{[[:space:]]*secrets\.'; then
            echo "FAIL  $wf:$ln_num: direct secret interpolation into echo/export/printf — use env: block instead. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'secrets\.' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky direct-secret-echo lines"

[[ $ok -eq 1 ]] && exit 0 || exit 1
