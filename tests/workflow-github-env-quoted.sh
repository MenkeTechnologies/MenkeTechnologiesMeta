#!/usr/bin/env bash
# For every workflow yml step `run:` block that references
# `$GITHUB_OUTPUT`, `$GITHUB_ENV`, `$GITHUB_PATH`, or
# `$GITHUB_STATE`, pin that the variable is DOUBLE-
# QUOTED:
#
#   echo "X=Y" >> "$GITHUB_OUTPUT"     # CORRECT
#   echo "X=Y" >>  $GITHUB_OUTPUT      # WRONG (unquoted)
#
# Why the quoting matters:
#
#   1. ShellCheck SC2086 (the most common shell-quality
#      finding): unquoted variable expansion. CI lint
#      flags this on every run. Quieting the noise
#      makes real findings stand out.
#
#   2. Defensive hygiene: $GITHUB_OUTPUT et al. resolve
#      to filesystem paths set by the runner. On GitHub-
#      hosted runners, the paths don't contain spaces
#      or glob characters today. But:
#        - Self-hosted runner deployments sometimes use
#          custom workspace paths that DO contain
#          spaces (admin error, but it happens).
#        - GitHub has occasionally rotated the path
#          shape (e.g., adding extra subdirectories).
#          Future paths may contain characters the
#          shell would word-split.
#        - Runners in alternative implementations
#          (act-cli, internal forks, etc.) set the
#          paths from environment with no guarantee.
#
#   3. Word-splitting bugs: unquoted `>> $GITHUB_OUTPUT`
#      when the value is `/runner/_temp/_github_output_
#      abc 123` (with embedded space) becomes
#      `>> /runner/_temp/_github_output_abc 123` —
#      the redirect goes to the wrong file AND `123`
#      becomes an unintended command argument. Silent
#      corruption.
#
#   4. Glob expansion: unquoted `$GITHUB_PATH` containing
#      a literal `*` would expand against the CWD. Even
#      more silent corruption.
#
# The fix is trivial — wrap every reference in double
# quotes. The cost is zero. The benefit is robustness
# against current AND future runner configurations.
#
# Detection: grep for `$GITHUB_OUTPUT` / `$GITHUB_ENV` /
# `$GITHUB_PATH` / `$GITHUB_STATE` in workflow yml.
# Skip comment lines, name: lines, and `- name:` lines
# (the patterns can appear in step names as
# documentation). For each remaining match, require
# the reference to be inside double quotes (i.e.,
# preceded by `"`).
#
# Pairs with workflow security defense + correctness
# family:
#   workflow-no-deprecated-commands (no ::set-output::)
#   workflow-no-debug-env-vars      (no leaky vars)
#   workflow-github-env-quoted (this) — defensive
#                                       quoting
#
# 168/168 GITHUB_X references are quoted at iter-214
# add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
unquoted=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        text="${match#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*|name:*|-\ name:*) continue ;;
        esac
        checked=$((checked + 1))
        # Require the variable to appear inside double quotes.
        # Look for "<...>$GITHUB_X<...>" pattern — variable
        # surrounded by " on both sides somewhere in the line.
        # Acceptable: "$GITHUB_OUTPUT", "...$GITHUB_OUTPUT...",
        # "$GITHUB_OUTPUT" (alone). Each requires `"$GITHUB_X`
        # somewhere.
        if ! echo "$stripped" | grep -qE '"\$GITHUB_(OUTPUT|ENV|PATH|STATE)'; then
            echo "FAIL  $wf:$ln_num: unquoted \$GITHUB_X reference — shell-hygiene + future-runner-config defense. Line: $text"
            unquoted=$((unquoted + 1))
            ok=0
        fi
    done < <(grep -nE '\$GITHUB_(OUTPUT|ENV|PATH|STATE)' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked GITHUB_X references checked, $unquoted unquoted"

[[ $ok -eq 1 ]] && exit 0 || exit 1
