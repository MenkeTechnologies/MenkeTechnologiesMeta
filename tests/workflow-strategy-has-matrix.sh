#!/usr/bin/env bash
# For every workflow yml job that declares a `strategy:`
# block, pin that the block contains a `matrix:` field.
#
# A strategy block without matrix is a silent no-op:
#
#   jobs:
#     build:
#       strategy:
#         fail-fast: false
#       runs-on: ubuntu-latest
#       steps:
#         - run: cargo build
#
# What the author probably intended: parallel matrix
# builds with fail-fast disabled. What actually happens:
# the strategy block does NOTHING because there's no
# matrix to apply fail-fast to. The job runs once,
# linearly, and the strategy config is dead config.
#
# The strategy schema in GitHub Actions:
#
#   strategy:
#     matrix: { ... }           # required for parallelism
#     fail-fast: true/false     # optional (default true)
#     max-parallel: N           # optional (default unlimited)
#
# All three keys are MEANT to be applied to matrix legs.
# Without matrix, fail-fast and max-parallel have nothing
# to operate on:
#
#   - fail-fast: false on a non-matrix job has no effect.
#     A single job either succeeds or fails. There's
#     nothing to fail-fast.
#   - max-parallel: N on a non-matrix job is meaningless.
#     There's one execution.
#
# Failure modes:
#
#   1. Refactor drift: a job originally had matrix with
#      fail-fast: false. Matrix was removed during a
#      simplification (e.g., dropping multi-platform
#      build to single-platform). fail-fast stayed
#      behind. Config now meaningless; reviewer reading
#      the workflow thinks the job is multi-leg when
#      it's actually single-leg.
#
#   2. Template misuse: author copies a strategy block
#      from another workflow and removes the matrix
#      "to simplify" but keeps fail-fast/max-parallel.
#      Behaves as no-op; author thinks parallelism is
#      configured.
#
#   3. Half-finished migration: someone is in the
#      middle of converting a non-matrix job to matrix.
#      They added the strategy block first, planning to
#      add matrix in a follow-up. The follow-up never
#      happened; the strategy block is dormant.
#
# All three are silent misconfigurations. GitHub
# Actions doesn't warn about strategy-without-matrix.
# CI runs green; behavior is wrong; symptoms only
# surface if someone notices the job isn't parallel.
#
# Detection: YAML-parse each workflow. For every job
# whose strategy: is a dict, require `matrix:` key.
#
# Pairs with workflow correctness family:
#   workflow-matrix-include-mappings   — include entries
#                                        are dicts
#   workflow-matrix-runs-on-defined    — matrix.<var>
#                                        references resolve
#   workflow-strategy-has-matrix (this) — strategy has
#                                         matrix
#
# Completes matrix correctness triangle: shape (include),
# referent (runs-on), purpose (strategy needs matrix).
#
# 0/90 strategy blocks lack matrix at iter-217 add — pure
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
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    strat = job.get('strategy')
    if strat is None:
        continue
    total += 1
    if not isinstance(strat, dict):
        bad.append(f'{jn}:strategy-not-dict')
        continue
    if 'matrix' not in strat:
        bad.append(jn)
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: job $b has strategy: block without matrix: — fail-fast/max-parallel are silent no-ops"
            bad=$((bad + 1))
            ok=0
        done
    fi
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
echo "Summary: $checked strategy blocks checked, $bad without matrix"

[[ $ok -eq 1 ]] && exit 0 || exit 1
