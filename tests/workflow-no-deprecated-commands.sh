#!/usr/bin/env bash
# For every workflow yml step `run:` block, pin that no
# command uses the deprecated GitHub Actions echo-style
# workflow commands:
#
#   ::set-output name=X::value
#   ::save-state name=X::value
#   ::set-env name=X::value
#   ::add-path::value
#
# GitHub deprecated these in October 2022 in CVE
# response (GHSA-mfwh-5m23-j46w / arbitrary-command
# injection via untrusted echo input). The migration
# target is environment-file based:
#
#   set-output  → echo "name=value" >> "$GITHUB_OUTPUT"
#   save-state  → echo "name=value" >> "$GITHUB_STATE"
#   set-env     → echo "name=value" >> "$GITHUB_ENV"
#   add-path    → echo "value"      >> "$GITHUB_PATH"
#
# Why the deprecation:
#
#   - The echo-style commands let any string written to
#     stdout become a workflow directive. If a step's
#     output contains attacker-controlled text (e.g., a
#     PR title, a commit message, a file's contents,
#     git author name), that text can SET ENVIRONMENT
#     VARIABLES in subsequent steps. Untrusted input
#     becomes arbitrary writable state.
#
#   - The environment-file form (>> "$GITHUB_OUTPUT")
#     is protected: the file is appended at a
#     controlled path, the runner reads it after the
#     step completes, and the values can't be injected
#     by stdout content.
#
# Timeline:
#
#   2022-10-11: deprecation announced, warning emitted
#               on every workflow run using these
#               commands.
#   2023-06:    initial removal date (postponed after
#               community migration progress).
#   2023-11-01: hard removal; workflows using deprecated
#               commands now FAIL with:
#                 "Error: The `set-output` command is
#                  disabled."
#
# Any workflow still using these commands is currently
# broken. The gate catches the next accidental
# reintroduction (copy-paste from old documentation,
# AI-generated YAML trained on pre-2022 examples,
# vendored action's bundled scripts).
#
# Detection: regex on `::set-output::`, `::save-state`,
# `::set-env`, `::add-path` patterns. Comments excluded.
# Matches both `echo "::set-output name=foo::bar"` and
# `printf "::set-output name=foo::bar\n"` and any other
# command producing the directive string.
#
# Pairs with workflow security defense family. Adds
# the post-2022 deprecation hardening to the family.
#
# 0/90 workflows use deprecated commands at iter-196
# add — pure regression floor.
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
            \#*) continue ;;
        esac
        if echo "$stripped" | grep -qE '::set-output|::save-state|::set-env|::add-path'; then
            echo "FAIL  $wf:$ln_num: deprecated echo-style workflow command — use \$GITHUB_OUTPUT/\$GITHUB_ENV/\$GITHUB_PATH/\$GITHUB_STATE. Line: $text"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '::set-output|::save-state|::set-env|::add-path' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky deprecated-command uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
