#!/usr/bin/env bash
# For every workflow yml job, pin that the job's keys
# are canonical GitHub Actions job keys per the
# official schema.
#
# Canonical job keys (GitHub Actions spec):
#
#   name              Display name in Actions UI
#   permissions       Job-scoped GITHUB_TOKEN scope
#   needs             Inter-job dependencies
#   if                Conditional execution
#   runs-on           Runner image/label
#   environment       Deployment environment
#   concurrency       Job-scoped concurrency lane
#   outputs           Map of output values
#   env               Job-scoped env vars
#   defaults          Job-scoped default shell/wd
#   steps             Steps array
#   timeout-minutes   Per-job timeout
#   strategy          Matrix + fail-fast + max-parallel
#   continue-on-error Continue workflow on job failure
#   container         Container image for this job
#   services          Service containers
#   uses              Reusable workflow call
#   with              Inputs to reusable workflow
#   secrets           Secrets to reusable workflow
#
# A non-canonical key in a job:
#
#   jobs:
#     build:
#       name: Build
#       runs-on: ubuntu-latest
#       run-on: ubuntu-latest        # WRONG — singular
#       needed:                      # WRONG — past tense
#         - setup
#       timeout_minutes: 30          # WRONG — snake_case
#       continue_on_error: false     # WRONG — snake_case
#       use:                         # WRONG — singular
#         ./.github/workflows/reusable.yml
#
# GitHub Actions silently IGNORES unknown job keys:
#
#   - run-on (singular) → ignored; the job has no
#     runs-on; if runs-on is also missing entirely,
#     the workflow upload-validates with "runs-on is
#     required" — but with both run-on AND a
#     legitimate runs-on, run-on is silently dead
#     config
#
#   - needed → ignored; job runs IN PARALLEL with the
#     setup job instead of after; race conditions in
#     test infrastructure that the contributor
#     thought was dep-ordered
#
#   - timeout_minutes (snake) → ignored; timeout
#     stays at default 360 (6h); a job that should
#     time out at 30 min runs for 6h on hang;
#     burns runner-quota
#
#   - continue_on_error (snake) → ignored; the
#     default true behavior (fail the workflow) is
#     applied; the intended "tolerate this job's
#     failure" doesn't work
#
#   - use (singular) → ignored; reusable workflow
#     not invoked; job has no steps; workflow
#     completes with no work
#
# Common typo sources:
#
#   run-on             → runs-on          (singular)
#   runson             → runs-on          (no hyphen)
#   needed             → needs            (past tense)
#   need               → needs            (singular)
#   timeout_minutes    → timeout-minutes  (snake→kebab)
#   timeoutMinutes     → timeout-minutes  (camelCase)
#   continue_on_error  → continue-on-error (snake→kebab)
#   continueOnError    → continue-on-error (camelCase)
#   use                → uses             (singular)
#   inherit_secrets    → secrets: inherit (different
#                                          syntax)
#   matrix             → (at job level — but matrix
#                         lives under strategy)
#   matrix.*           → (must be inside strategy.
#                         matrix)
#
# Detection: YAML-parse each workflow. For every job
# (in any job dict), check each key against the
# canonical set.
#
# Pairs with workflow-canonical-keys family:
#   workflow-top-canonical-keys     — workflow root
#   workflow-job-canonical-keys (this) — job level
#
# Companion to iter-227 — extends canonical-key
# enforcement one level deeper.
#
# 274/274 job keys canonical at iter-228 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
bad=0

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
allowed = {
    'name', 'permissions', 'needs', 'if', 'runs-on',
    'environment', 'concurrency', 'outputs', 'env',
    'defaults', 'steps', 'timeout-minutes', 'strategy',
    'continue-on-error', 'container', 'services',
    'uses', 'with', 'secrets',
}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    total += 1
    for k in job.keys():
        if k not in allowed:
            bad.append(f'{jn}:{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: job $b — non-canonical key (GitHub Actions silently ignores; intended config NOT applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked jobs checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
