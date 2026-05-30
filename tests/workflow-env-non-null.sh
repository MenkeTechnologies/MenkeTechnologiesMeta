#!/usr/bin/env bash
# For every workflow yml `env:` block entry (workflow,
# job, or step level), pin that the value is non-null.
#
# YAML's null scalar in env entries:
#
#   env:
#     RUST_BACKTRACE:        # WRONG — empty value
#     CARGO_TERM_COLOR: ~    # WRONG — null tilde
#     CC: null               # WRONG — explicit null
#     CXX: Null              # WRONG — capitalized
#                              still null
#
# All resolve to Python None in yaml.safe_load.
# GitHub Actions handles env values via toString
# coercion:
#
#   None → ""           (empty string)
#   ""   → ""           (empty string)
#   "0"  → "0"          (string)
#   True → "true"       (string boolean)
#
# So `RUST_BACKTRACE:` (null) becomes `RUST_BACKTRACE=""`
# in the runner — an EMPTY env var. The contributor's
# intent depends on context:
#
#   - For RUST_BACKTRACE: they probably meant "0" or
#     "1" but typed RUST_BACKTRACE: with no value
#     (typo / missing the value during edit). The
#     runner sees RUST_BACKTRACE="" which:
#       - cargo treats as "backtrace disabled" (same
#         as RUST_BACKTRACE=0)
#       - debug-experience contributor expected
#         doesn't materialize on test failures
#
#   - For PATH: env: PATH: with no value SETS PATH
#     TO EMPTY STRING. The runner then has no PATH;
#     every subsequent command fails "command not
#     found" (including bash itself in some
#     contexts). Catastrophic for the rest of the
#     job.
#
#   - For CC / CXX / LD_LIBRARY_PATH: empty value
#     resets the compiler/loader path; build
#     commands fail to find the toolchain or
#     resolve symbols.
#
#   - For TOKEN / SECRET vars: empty value blanks
#     the secret; downstream auth fails with
#     confusing errors.
#
# Failure mode: empty env values masquerade as
# configured values until the runtime parsing
# disagrees with the contributor's mental model.
#
# Likely sources of YAML null env entries:
#
#   - Partial edit: contributor typed `key:` and
#     planned to add the value but Ctrl+S'd before
#     completing
#
#   - Comment-out of value: edit-history `key: foo`
#     → `key: # foo` left the key visible with no
#     value
#
#   - Copy-paste from a template that had
#     placeholder values; the placeholders were
#     deleted but the keys kept
#
#   - YAML anchor / alias resolution failure
#
# Detection: YAML-parse each workflow. For env: at
# workflow, job, and step level, check each value
# for None.
#
# Pairs with workflow correctness family:
#   workflow-with-entries-non-null (iter-238)
#   workflow-env-non-null (this)
#
# Together: every value-bearing YAML scalar in
# workflows (with-block + env-block) must be
# non-null.
#
# 156/156 env entries non-null at iter-239 add —
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
total = 0
bad = []

def collect_env(e, where):
    out = []
    n = 0
    if not isinstance(e, dict):
        return 0, out
    for k, v in e.items():
        n += 1
        if v is None:
            out.append(f'{where}.{k}')
    return n, out

n, b = collect_env(d.get('env'), 'workflow')
total += n; bad.extend(b)
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    n, b = collect_env(job.get('env'), f'job/{jn}')
    total += n; bad.extend(b)
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        n, b = collect_env(step.get('env'), f'job/{jn}/{sn}')
        total += n; bad.extend(b)

print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: env $b → null — empty env var; PATH/CC/etc. become catastrophic, RUST_BACKTRACE-style vars silently disable feature"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked env entries checked, $bad with null values"

[[ $ok -eq 1 ]] && exit 0 || exit 1
