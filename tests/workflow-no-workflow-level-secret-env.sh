#!/usr/bin/env bash
# For every workflow yml top-level `env:` block, pin that
# no value references `${{ secrets.X }}`.
#
# GitHub Actions env-scoping cascade:
#
#   workflow.env  → applies to EVERY job and EVERY step
#   job.env       → applies to every step in that job
#   step.env      → applies to that step only
#
# A secret declared at workflow scope exposes it to:
#
#   - Every step's process environment, including
#     downstream actions whose source the org didn't
#     write (third-party actions read env-vars freely)
#   - Every step's command-history echo if logging
#     verbosity is bumped
#   - Every step's `env` dump if a debug script runs
#   - Every step's heap memory if a buggy action
#     reads `printenv`
#
# Step-level scoping is least-privilege:
#
#   - Only the specific step that needs the secret sees
#     it
#   - Actions in adjacent steps never have access
#   - Audit becomes trivial: grep for the secret name
#     finds exactly the steps that use it
#
# Per GitHub's own security hardening guide:
#
#   "When defining sensitive secrets ..., consider
#    using job-level or step-level env mappings
#    instead of workflow-level env mappings to limit
#    the scope of the secret."
#
# Workflow-level env is FINE for non-secret values
# (RUST_BACKTRACE: 1, CARGO_TERM_COLOR: always,
# CARGO_NET_RETRY: 10). It's only the secret-containing
# values that this gate flags.
#
# Failure modes without this gate:
#
#   1. Drift introduction: an early single-job workflow
#      had GH_TOKEN at workflow scope. The workflow
#      grew to 3 jobs, but the GH_TOKEN stayed at
#      workflow scope. Now the lint job, the test job,
#      and the docs job all inherit the token even
#      though only the release job needs it.
#
#   2. Reusable workflow inheritance: a reusable
#      workflow with workflow-level secret env is
#      called by other workflows. The secret's scope
#      grows to every caller's actions. Cascading
#      exposure.
#
#   3. Third-party action exposure: workflow uses
#      community action X at step 5. The action reads
#      env-vars in its setup phase. If GH_TOKEN is at
#      workflow scope, action X sees it even though
#      step 5 doesn't need to forward it. Future
#      versions of action X could exfiltrate.
#
# Detection: YAML-parse each workflow. For workflow-
# level env: only, check each value for `secrets.X`
# substring. Job-level and step-level env are allowed.
#
# Pairs with workflow security defense family:
#   workflow-no-debug-env-vars       — debug-leak
#                                      blockers
#   workflow-no-env-dump             — no `env`
#                                      command echo
#   workflow-no-secret-echo          — no `echo
#                                      $SECRET`
#   workflow-no-workflow-level-secret-env (this) —
#                                      scope hardening
#
# 0/90 workflows put secrets at workflow scope at
# iter-219 add — pure regression floor.
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
env = d.get('env', {})
if not isinstance(env, dict):
    print('0|')
    sys.exit()
total = 1 if env else 0
bad = []
for k, v in env.items():
    if isinstance(v, str) and 'secrets.' in v:
        bad.append(k)
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for k in "${ba[@]}"; do
            echo "FAIL  $wf: workflow-level env.$k references secrets.* — move to step-level for least-privilege scoping"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow-level env blocks checked, $bad with secret references"

[[ $ok -eq 1 ]] && exit 0 || exit 1
