#!/usr/bin/env bash
# For every workflow yml step (in any job), pin that
# the step's keys are canonical GitHub Actions step
# keys per the official schema.
#
# Canonical step keys:
#
#   name              Step display name
#   id                Step identifier (for outputs/refs)
#   if                Conditional execution
#   uses              Action reference (use this OR run)
#   with              Action parameter inputs
#   run               Shell script to execute
#   env               Step-scoped env vars
#   shell             Shell selection (bash/pwsh/python/
#                     etc.)
#   working-directory Working dir for the step
#   continue-on-error Continue job on step failure
#   timeout-minutes   Per-step timeout
#
# A non-canonical key in a step:
#
#   steps:
#     - name: Build
#       use: actions/checkout@v4   # WRONG — singular
#       with: { ... }
#     - name: Test
#       runs: cargo test            # WRONG — plural
#       working_directory: ./crate  # WRONG — snake_case
#       continueOnError: true       # WRONG — camelCase
#       timeoutMinutes: 5           # WRONG — camelCase
#
# GitHub Actions silently IGNORES unknown step keys:
#
#   - use (singular) → step has no uses; if also no
#     run, the step does nothing (silent no-op);
#     workflow appears to skip the build step
#
#   - runs (plural) → step has no run; if also no
#     uses, step does nothing; workflow completes
#     "Test" step with no actual test
#
#   - working_directory (snake) → ignored; working
#     dir stays at default GITHUB_WORKSPACE root;
#     paths in run blocks like `./Cargo.toml` resolve
#     against repo root instead of crate subdir;
#     "could not find Cargo.toml" — blamed on
#     missing files, real cause is the typo
#
#   - continueOnError (camel) → ignored; default
#     fail-job behavior applies; step failure halts
#     the job; the intended "continue on test
#     failure" doesn't work
#
#   - timeoutMinutes (camel) → ignored; per-step
#     timeout stays inherited from job (default 360
#     for the job); a step that should time out at
#     5 min runs for the job's timeout instead
#
# Common typo sources:
#
#   use               → uses              (singular)
#   runs              → run               (plural)
#   working_directory → working-directory (snake→kebab)
#   workingDirectory  → working-directory (camelCase)
#   continue_on_error → continue-on-error (snake→kebab)
#   continueOnError   → continue-on-error (camelCase)
#   timeout_minutes   → timeout-minutes   (snake→kebab)
#   timeoutMinutes    → timeout-minutes   (camelCase)
#   step_id           → id                (suffix)
#   step-name         → name              (prefix)
#   condition         → if                (different word)
#   when              → if                (different word)
#   shell-name        → shell             (suffix)
#
# camelCase typos are particularly common because
# many YAML schemas in adjacent tools (Kubernetes,
# Helm, CircleCI) use camelCase, conditioning
# contributors to type that variant by reflex.
#
# Detection: YAML-parse each workflow. For every step
# in any job, check each key against the canonical
# set.
#
# Pairs with workflow canonical-keys family (third
# in the workflow trio):
#   workflow-top-canonical-keys      — workflow root
#   workflow-job-canonical-keys      — job level
#   workflow-step-canonical-keys (this) — step level
#
# Three-level workflow coverage; together with the
# seven cargo-table gates, the canonical-keys family
# now spans TEN tables across cargo manifest and
# GitHub Actions workflow schema.
#
# 1499/1499 step keys canonical at iter-229 add —
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
allowed = {
    'name', 'id', 'if', 'uses', 'with', 'run', 'env',
    'shell', 'working-directory', 'continue-on-error',
    'timeout-minutes',
}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        total += 1
        sn = step.get('name', f'step #{i+1}')
        for k in step.keys():
            if k not in allowed:
                bad.append(f'{jn}/{sn}:{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: step $b — non-canonical key (GitHub Actions silently ignores; intended config NOT applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked steps checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
