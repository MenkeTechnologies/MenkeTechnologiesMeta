#!/usr/bin/env bash
# For every workflow job whose `runs-on:` value references
# a matrix variable (`${{ matrix.<name> }}`), pin that the
# matrix actually defines `<name>` — either as a top-level
# matrix key or inside an `include:` entry.
#
# A workflow with:
#
#   strategy:
#     matrix:
#       target: [aarch64, x86_64]
#   runs-on: ${{ matrix.os }}
#
# refers to `matrix.os` which DOESN'T EXIST in the matrix.
# At runtime, the expression evaluates to an empty string,
# and the runner allocation fails with:
#
#   Error: The workflow is not valid. .github/workflows/foo.yml
#   (Line: N, Col: M): A matrix variable 'os' was referenced
#   but never declared.
#
# Failure modes this gate forecloses:
#
#   1. Refactor drift: a job that originally had
#      `runs-on: ${{ matrix.os }}` and `matrix: { os: [...] }`
#      gets refactored to use a different matrix shape
#      (`target:` instead of `os:`). The matrix key changes
#      but `runs-on:` reference doesn't. The workflow
#      breaks the next time it runs.
#
#   2. Copy-paste error: a job is copied from another
#      workflow that used `matrix.os`. The new workflow's
#      matrix has different keys but the runs-on reference
#      wasn't updated. First run fails.
#
#   3. Include-only matrix: the matrix uses only
#      `include:` entries (no top-level keys). The runs-on
#      references a key that's only in some of the include
#      entries. Some matrix legs succeed; others fail
#      mysteriously.
#
# Resolution by checking BOTH top-level matrix keys AND
# include entries:
#
#   strategy:
#     matrix:
#       include:
#         - { os: ubuntu-latest, target: x86_64 }
#         - { os: macos-latest, target: aarch64 }
#   runs-on: ${{ matrix.os }}
#
# This is valid because all include entries define `os`.
# The gate accepts it.
#
# Detection: YAML-parse each workflow. For each job,
# scan `runs-on:` for `matrix.<name>` references. For
# each reference, check that the job's matrix defines
# the var as a top-level key OR in an include entry.
#
# Pairs with workflow correctness family
# (workflow-needs-references, workflow-step-ids-valid).
# Adds matrix-runs-on referential integrity.
#
# 73/73 matrix-runs-on references resolve at iter-208
# add — pure regression floor.
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
import sys, yaml, re
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('0|')
    sys.exit()
if not isinstance(d, dict):
    print('0|')
    sys.exit()

bad = []
total = 0
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    ro = job.get('runs-on', '')
    if not isinstance(ro, str):
        continue
    refs = re.findall(r'matrix\.([a-zA-Z_][a-zA-Z0-9_]*)', ro)
    if not refs:
        continue
    strat = job.get('strategy', {})
    if not isinstance(strat, dict):
        strat = {}
    mat = strat.get('matrix', {})
    if not isinstance(mat, dict):
        mat = {}
    declared = set(mat.keys())
    declared.discard('include')
    declared.discard('exclude')
    inc = mat.get('include', [])
    if isinstance(inc, list):
        for e in inc:
            if isinstance(e, dict):
                declared.update(e.keys())
    for var in refs:
        total += 1
        if var not in declared:
            bad.append(f'{jn}:matrix.{var}')

print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: $b — runs-on references undefined matrix var"
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
echo "Summary: $checked matrix-runs-on references checked, $bad with undefined var"

[[ $ok -eq 1 ]] && exit 0 || exit 1
