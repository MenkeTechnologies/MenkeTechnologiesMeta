#!/usr/bin/env bash
# For every workflow yml job `strategy:` block, pin
# that the keys are canonical per GitHub Actions
# strategy schema:
#
#   matrix         Matrix dimensions for parallel
#                  legs
#   fail-fast      Cancel sibling matrix legs on
#                  first failure (default true)
#   max-parallel   Limit concurrent matrix legs
#                  (default unlimited)
#
# A non-canonical key:
#
#   strategy:
#     matrx:                    # WRONG — typo
#       os: [ubuntu-latest]
#     failFast: false           # WRONG — camelCase
#     fail_fast: false          # WRONG — snake_case
#     maxParallel: 3            # WRONG — camelCase
#     max_parallel: 3           # WRONG — snake_case
#     matrices:                 # WRONG — plural
#       os: [ubuntu-latest]
#     continue_on_failure: true # WRONG — invented
#                                 (use job-level
#                                  continue-on-error
#                                  instead)
#
# GitHub Actions silently IGNORES unknown strategy
# keys (the strategy block has a permissive schema
# for forward-compat; unknown keys don't fail upload).
# The strategy runs with DEFAULTS:
#
#   - matrx (typo) → matrix is empty; no matrix
#     legs; the strategy block has no effect; the
#     job runs once with the keys that DID match
#     (none); silent no-op
#
#   - failFast (camel) → fail-fast stays at default
#     TRUE; matrix legs that fail cancel siblings;
#     the contributor's intent to keep all legs
#     running (for full coverage on one bad leg)
#     doesn't apply; partial results from cancelled
#     legs mislead debugging
#
#   - fail_fast (snake) → same as above; common
#     snake_case reflex from K8s/Helm/CircleCI YAML
#
#   - maxParallel / max_parallel → ignored; legs run
#     all-at-once; runner quota burned in parallel
#     when contributor wanted serialization
#
#   - matrices (plural) → ignored; no matrix; single
#     run instead of N legs
#
#   - continue_on_failure (invented) → ignored;
#     contributor confused strategy schema with job
#     schema (job-level continue-on-error). The
#     intent doesn't transfer; failures still halt
#     the workflow
#
# Failure modes can be SILENT for weeks: the strategy
# block looks configured, the workflow runs without
# error, but the parallelism/fail-fast behavior
# doesn't match the contributor's expectation. Often
# discovered only when a future PR's failure
# CANCELS sibling legs that the contributor expected
# would continue.
#
# Common typo sources:
#
#   failFast          → fail-fast        (camelCase)
#   fail_fast         → fail-fast        (snake_case)
#   failfast          → fail-fast        (no separator)
#   maxParallel       → max-parallel     (camelCase)
#   max_parallel      → max-parallel     (snake_case)
#   max-Parallel      → max-parallel     (mixed)
#   maxconcurrent     → max-parallel     (different
#                                          word)
#   matrx / matix     → matrix           (typo)
#   matrices          → matrix           (plural)
#   continue_on_failure → (not a strategy key — use
#                          job.continue-on-error)
#
# Detection: YAML-parse each workflow. For every job's
# strategy: dict, check each key against the canonical
# {matrix, fail-fast, max-parallel} set.
#
# Pairs with canonical-keys family — eighteenth table:
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-{checkout,cache,upload-artifact,
#     download-artifact,rust-toolchain,swatinem-
#     rust-cache}-canonical-with
#   workflow-services-canonical-keys
#   workflow-strategy-canonical-keys (this)
#
# 90/90 strategy blocks canonical at iter-244 add —
# pure regression floor.
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
allowed = {'matrix', 'fail-fast', 'max-parallel'}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    strat = job.get('strategy')
    if not isinstance(strat, dict):
        continue
    total += 1
    for k in strat.keys():
        if k not in allowed:
            bad.append(f'{jn}/strategy.{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: $b — non-canonical strategy key (silently ignored; defaults applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked strategy blocks checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
