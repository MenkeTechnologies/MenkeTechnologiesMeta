#!/usr/bin/env bash
# For every workflow yml `if:` condition (job-level or step-
# level), pin that the value is NOT the constant boolean
# `true` or `false`.
#
# Constant `if:` conditions are anti-patterns:
#
#   if: true   →  always-runs no-op. The `if:` field exists
#                 but has zero filtering effect. Either delete
#                 the `if:` field entirely (default behavior
#                 is to run) or replace with a real condition.
#                 Often a leftover from temporarily disabling
#                 a condition during debugging:
#
#                   if: ${{ github.event.pull_request }}
#                                       ↓ debug
#                   if: true
#                                       ↑ never reverted
#
#   if: false  →  always-skipped dead code. The step or job
#                 is permanently disabled. Either delete the
#                 step/job entirely or restore the real
#                 condition. Indicates abandoned in-progress
#                 work that someone meant to come back to:
#
#                   if: ${{ needs.test.outputs.deploy_ok }}
#                                       ↓ "skip for now"
#                   if: false
#                                       ↑ never re-enabled
#
# Both forms accept the YAML scalar `true`/`false` OR the
# string `"true"`/`"false"`. GitHub Actions normalizes both
# to the same evaluation result (the string form is a literal
# in expression context, the bare form is a YAML boolean).
#
# Detection: walk every job-level and step-level `if:` field,
# check value against the four literal forms.
#
# Pairs with iter-83 (steps have run or uses — actionless
# steps are a different "no-op" pattern), iter-118 (step ids
# unique). Together: workflow steps that ARE present do real
# work, and don't include silent skips.
#
# 0/90 workflows currently use constant if — pure regression
# floor against accidental debug-leftover introduction.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "SKIP  PyYAML not installed"
    exit 0
fi

checked=0
bad=0
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    output=$(python3 -c '
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("PARSE_FAIL")
        sys.exit()
    bad = []
    def check_if(obj, ctx):
        if not isinstance(obj, dict):
            return
        c = obj.get("if")
        if c is True or c == "true":
            bad.append(f"{ctx}: if=true (always-run, no-op — delete the if field or restore condition)")
        elif c is False or c == "false":
            bad.append(f"{ctx}: if=false (always-skip, dead code — delete the step/job or restore condition)")
    jobs = d.get("jobs", {}) or {}
    if isinstance(jobs, dict):
        for jn, job in jobs.items():
            if not isinstance(job, dict):
                continue
            check_if(job, f"job.{jn}")
            for i, step in enumerate(job.get("steps", []) or []):
                if isinstance(step, dict):
                    check_if(step, f"job.{jn}.step{i+1}")
    print("OK" if not bad else "BAD:" + "; ".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: ${output#BAD:}"
            bad=$((bad + 1))
            ok=0
            ;;
    esac
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $bad with constant true/false in if"

[[ $ok -eq 1 ]] && exit 0 || exit 1
