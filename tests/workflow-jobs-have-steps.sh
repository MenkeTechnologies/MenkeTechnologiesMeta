#!/usr/bin/env bash
# For every job in every .github/workflows/*.yml, pin that the
# job declares at least one entry under `steps:`.
#
# A job with empty steps is structurally valid (GitHub doesn't
# reject the workflow at upload time) but runs as a no-op: the
# runner spins up, prints a banner, exits with success. Workflow
# completes green. PR check passes.
#
# This is the JOB-level analog of iter-80's WORKFLOW-level
# "has jobs" check. Same failure pattern (passing check on a
# unit that does nothing), one level deeper.
#
# How it sneaks in:
#   - Steps accidentally indented BELOW `steps:` during a
#     reformat (now at job-level sibling)
#   - Step list emptied to disable testing temporarily, never
#     restored
#   - YAML anchor for the steps array got dropped without
#     replacing it
#   - Cut/paste from a template with `steps: []` placeholder
#
# Exceptions HONORED (job passes through without step check):
#   - `uses:` at job level → reusable workflow caller, steps
#     not applicable
#   - non-dict jobs (rare, malformed) → caught separately by
#     iter-68's YAML-parse gate
#
# 90/90 workflow files (across all jobs) green at iter-81 add
# — pure regression floor.
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
empty_jobs=0
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
    jobs = d.get("jobs", {})
    if not isinstance(jobs, dict):
        print("PARSE_FAIL")
        sys.exit()
    bad = []
    for name, job in jobs.items():
        if not isinstance(job, dict):
            continue
        if "uses" in job:
            continue
        steps = job.get("steps", [])
        if not isinstance(steps, list) or len(steps) == 0:
            bad.append(name)
    print("OK" if not bad else "BAD:" + ",".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            jobs="${output#BAD:}"
            echo "FAIL  $wf: jobs with empty steps: $jobs"
            # count comma-separated jobs
            n=$(echo "$jobs" | tr ',' '\n' | wc -l | tr -d ' ')
            empty_jobs=$((empty_jobs + n))
            ok=0
            ;;
    esac
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflows checked ($parse_fail unparseable delegated to iter-68), $empty_jobs jobs with empty steps"

[[ $ok -eq 1 ]] && exit 0 || exit 1
