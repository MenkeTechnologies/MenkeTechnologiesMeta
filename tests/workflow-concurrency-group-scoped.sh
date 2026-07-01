#!/usr/bin/env bash
# For every workflow yml `concurrency.group` value, pin
# that the string references at least one `github.*`
# context expression (e.g., `${{ github.workflow }}`,
# `${{ github.ref }}`, `${{ github.event.number }}`).
#
# A `concurrency.group` value is the IDENTIFIER for the
# serialization lane. All runs that share a group string
# are serialized: only one runs at a time, and
# `cancel-in-progress: true` cancels in-flight runs in
# the same group when a new one starts.
#
# Without a github-context expression, the group string
# is STATIC. Every workflow run uses the same lane,
# producing one of these failure modes:
#
#   1. group: "ci"
#      - Every PR, every push, every workflow_dispatch
#        across the entire repo shares the same lane.
#      - Push to branch A blocks push to branch B
#        (different feature branches serialize).
#      - PR #100 blocks PR #200 (unrelated reviews
#        serialize).
#      - With cancel-in-progress: true, the latest run
#        cancels ALL prior in-flight runs across
#        unrelated branches — losing work.
#
#   2. group: "build-and-test"
#      - Same as above plus: if the workflow file is
#        renamed to "build-deploy.yml", the
#        concurrency lane stays "build-and-test" until
#        someone updates the string. Drift between
#        workflow identity and lane identity.
#
#   3. group: ""
#      - GitHub treats empty as the workflow filename
#        (implicit). Behaves the same as #1, but with
#        an even more confusing config.
#
# The canonical patterns (all reference github.*):
#
#   group: ${{ github.workflow }}-${{ github.ref }}
#     - Per-workflow per-ref lane. PRs and pushes to
#       different branches don't serialize. Different
#       workflows on the same branch don't serialize.
#     - Most common pattern; the "default sensible"
#       choice.
#
#   group: ${{ github.workflow }}-${{
#          github.event.number || github.sha }}
#     - Per-workflow per-PR-or-commit lane. Handles
#       both PR and push triggers cleanly.
#
#   group: ${{ github.workflow }}
#     - Per-workflow lane (cross-branch serialization).
#       Right choice for release workflows where you
#       want only ONE release running at a time across
#       all branches.
#
# All three reference `github.*` — the gate just
# requires at least one such reference. The specific
# choice of expression is up to the workflow's
# intent.
#
# Detection: YAML-parse each workflow. For every
# concurrency.group string (workflow or job level),
# require substring `github.` in the value. Skip
# workflows without concurrency blocks.
#
# Pairs with workflow-concurrency-group (existing —
# requires group: presence). This gate is the
# content-shape complement.
#
# 59/59 workflows with concurrency reference github
# context at iter-206 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
unscoped=0

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

def check_concurrency(c, where):
    if c is None:
        return None
    if isinstance(c, str):
        # short-form: the string IS the group
        return ('STATIC', c) if 'github.' not in c else None
    if isinstance(c, dict):
        g = c.get('group')
        if isinstance(g, str) and 'github.' not in g:
            return ('STATIC', g)
    return None

bad = []
total = 0
# Workflow-level concurrency
wf_c = d.get('concurrency')
if wf_c is not None:
    total += 1
    res = check_concurrency(wf_c, 'workflow')
    if res:
        bad.append(f'workflow:{res[1]}')
# Job-level concurrency
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    j_c = job.get('concurrency')
    if j_c is not None:
        total += 1
        res = check_concurrency(j_c, jn)
        if res:
            bad.append(f'{jn}:{res[1]}')

print(f"{total}|{';'.join(bad)}")
PY
)
    c_count="${result%%|*}"
    bad_groups="${result#*|}"
    checked=$((checked + c_count))
    if [[ -n "$bad_groups" ]]; then
        IFS=';' read -ra ga <<< "$bad_groups"
        for g in "${ga[@]}"; do
            echo "FAIL  $wf: concurrency group '$g' has no github.* expression — lane is static, serializes unrelated runs"
            unscoped=$((unscoped + 1))
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
echo "Summary: $checked concurrency blocks checked, $unscoped with static group string"

[[ $ok -eq 1 ]] && exit 0 || exit 1
