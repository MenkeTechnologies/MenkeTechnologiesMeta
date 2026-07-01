#!/usr/bin/env bash
# For every workflow yml job, pin that
# `continue-on-error: true` is NOT set at the job level.
#
# GitHub Actions' `continue-on-error: true` causes the
# job (or step) to count as PASSED in workflow status
# even when it actually fails. At the JOB level, this
# is almost always a footgun:
#
#   - The workflow's green checkmark on a PR or branch
#     conceals a job that exited non-zero. Reviewers
#     and merge bots see "all checks passing" while
#     the underlying tests, lint, or build failed.
#
#   - Branch protection rules that require "all checks
#     pass" are satisfied even when a continue-on-error
#     job failed. The protection becomes decorative.
#
#   - Status badge rendering on README.md shows green
#     for a workflow that's actually broken. The badge
#     becomes a lie.
#
#   - Downstream workflow runs (workflow_run trigger)
#     fire on "success" of the parent workflow,
#     including continue-on-error successes. A broken
#     parent triggers a release/deploy workflow with
#     bad artifacts.
#
# Step-level `continue-on-error: true` is sometimes
# legitimate (e.g., uploading test results when the
# test step itself fails — the upload step must run
# regardless). The job-level form is almost never
# right — if a job's failure shouldn't block, the
# workflow should be split, not pretended-passed.
#
# Matrix legitimate use: matrix.fail-fast = false +
# continue-on-error on individual matrix legs. But the
# job-level form (applied to the whole job, all legs)
# silently masks every matrix leg's failure. The
# matrix value pattern (`continue-on-error: ${{
# matrix.experimental }}`) is also acceptable because
# it's per-leg.
#
# This gate detects only the LITERAL TRUE form at the
# job level. Expression forms like `${{ matrix.foo }}`
# or `${{ github.event_name == 'pull_request' }}` are
# allowed (they parametrize the behavior; a reviewer
# can audit them in context).
#
# Detection: YAML-parse each workflow; for each job,
# check `continue-on-error` field. Flag only the
# boolean True value.
#
# Pairs with workflow security defense family (no
# write-all, no pull_request_target, no curl|sh, etc.)
# — adds anti-silent-failure to the family.
#
# 0/274 jobs use job-level continue-on-error: true at
# iter-195 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
masked=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    result=$(python3 - "$wf" <<'PY'
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('0|')
    sys.exit()
if not isinstance(d, dict):
    print('0|')
    sys.exit()
jobs = d.get('jobs', {}) or {}
total = 0
bad = []
for jn, job in jobs.items():
    if not isinstance(job, dict):
        continue
    total += 1
    coe = job.get('continue-on-error')
    # Only flag literal True (boolean). Expression strings (${{...}}) are allowed.
    if coe is True:
        bad.append(jn)
print(f"{total}|{','.join(bad)}")
PY
)
    job_count="${result%%|*}"
    bad_jobs="${result#*|}"
    checked=$((checked + job_count))
    if [[ -n "$bad_jobs" ]]; then
        IFS=',' read -ra ja <<< "$bad_jobs"
        for j in "${ja[@]}"; do
            echo "FAIL  $wf: job '$j' has continue-on-error: true — masks failure, breaks branch protection"
            masked=$((masked + 1))
            ok=0
        done
    fi
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
echo "Summary: $checked jobs checked, $masked with continue-on-error: true"

[[ $ok -eq 1 ]] && exit 0 || exit 1
