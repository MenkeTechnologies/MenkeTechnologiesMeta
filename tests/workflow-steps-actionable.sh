#!/usr/bin/env bash
# For every step in every .github/workflows/*.yml job, pin that
# the step declares EITHER a `run:` OR a `uses:` field.
#
# A step with neither field is GitHub's "no-op step" — it has
# `name:` (and optionally `if:`, `with:`, `env:`) but nothing to
# execute. GitHub Actions doesn't reject it at upload time; the
# step appears in the job's step list with a checkmark and zero
# duration, and execution continues to the next step.
#
# This is the FINEST-grained silent-no-op failure mode in the
# workflow gate stack:
#   - iter-80: workflow with no jobs (no-op workflow)
#   - iter-81: job with no steps (no-op job)
#   - iter-83: step with no run/uses (no-op step)
#
# Each level adds a degree of granularity. A workflow with 10
# steps where 1 silently no-ops still shows GREEN even though
# 10% of the testing didn't happen.
#
# How a step ends up actionless:
#   - Removed the `run:` block but kept `name:` for "later"
#     restoration that never happened
#   - YAML-anchor reuse (`<<: *base_step`) where the anchor was
#     removed but the alias kept; merge resolves to a partial
#     step
#   - Commented out every line under `run: |` but left the `run:`
#     key — actually that parses as `run: null` which IS a
#     run field (caught by GitHub at runtime, not this gate);
#     the steps without run/uses are even more degenerate
#   - Cut/paste from a checklist where `name:` was a comment
#     placeholder
#
# Reusable workflow callers (`uses:` at JOB level, not step
# level) have no steps array so this gate is a no-op for them.
#
# 90/90 workflow files green at iter-83 add — pure regression
# floor.
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

checked_files=0
total_steps=0
no_action=0
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked_files=$((checked_files + 1))

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
    total = 0
    bad = []
    for jn, job in jobs.items():
        if not isinstance(job, dict) or "uses" in job:
            continue
        steps = job.get("steps", []) or []
        for i, step in enumerate(steps):
            total += 1
            if not isinstance(step, dict):
                bad.append(f"{jn}.step{i+1}(non-dict)")
                continue
            if "run" not in step and "uses" not in step:
                name = step.get("name", f"step{i+1}")
                bad.append(f"{jn}.{name}")
    print(f"COUNT {total} {len(bad)} :: " + " ".join(bad[:5]))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        COUNT*)
            tot=$(echo "$output" | awk '{print $2}')
            bad=$(echo "$output" | awk '{print $3}')
            total_steps=$((total_steps + tot))
            if [[ "$bad" -gt 0 ]]; then
                detail=$(echo "$output" | sed 's/.*:: //')
                echo "FAIL  $wf: $bad of $tot steps lack run/uses — examples: $detail"
                no_action=$((no_action + bad))
                ok=0
            fi
            ;;
    esac
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked_files workflow files ($parse_fail delegated to iter-68), $total_steps steps checked, $no_action lacking run/uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
