#!/usr/bin/env bash
# For every workflow yml step using `actions/upload-
# artifact`, pin that the step has a `name:` parameter
# in its `with:` block.
#
# `actions/upload-artifact@v4`'s `name` parameter defaults
# to `artifact` when omitted. This default works fine for
# a workflow that uploads ONE artifact total. But:
#
#   - actions/upload-artifact@v4 REQUIRES unique artifact
#     names within a single workflow run. Per the v4
#     docs:
#       "Each artifact name must be unique within a run."
#
#   - With two upload steps both defaulting to `artifact`,
#     the second upload fails:
#       Error: Failed to CreateArtifact: Received
#       non-retryable error: Failed request: (409)
#       Conflict: an artifact with this name already
#       exists on the workflow run
#
#   - The error is FATAL — the second upload step fails,
#     and depending on the workflow's continue-on-error
#     posture, the whole job may fail.
#
# This is a v3-to-v4 breaking change. v3 allowed default-
# named uploads to merge (last upload wins); v4 rejects.
#
# Failure modes:
#
#   1. Multi-platform build matrix: each leg uploads a
#      different binary, both default to `artifact`. The
#      first leg uploads; subsequent legs fail with the
#      409 conflict. Release pipeline broken for all but
#      one platform.
#
#   2. Refactor drift: a workflow originally had one
#      upload step. A second was added (e.g., for test
#      reports) without setting `name:` on either. First
#      run after the change fails with collision.
#
#   3. Workflow inheritance / reusable workflow: a
#      reusable workflow uploads `artifact`. A second
#      reusable workflow called in the same run also
#      uploads `artifact`. Conflict at runtime; the
#      author of the calling workflow can't debug
#      because the upload steps live in a different
#      file.
#
# Setting explicit `name:` per upload makes:
#   - Collisions impossible
#   - download-artifact references unambiguous
#   - workflow logs grep-able for specific artifacts
#
# Detection: YAML-parse each workflow. For every step
# with `uses: actions/upload-artifact@<v>`, check `with:`
# has a `name:` key.
#
# Pairs with:
#   workflow-upload-artifact-v4-floor — v4+ version pin
#   workflow-upload-artifact-name (this) — name uniqueness
#                                          contract
#
# 52/52 upload-artifact steps set name at iter-218 add —
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
missing=0

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
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        u = step.get('uses')
        if not isinstance(u, str):
            continue
        if 'actions/upload-artifact' not in u:
            continue
        total += 1
        w = step.get('with', {})
        if not isinstance(w, dict) or 'name' not in w:
            sn = step.get('name', f'step #{i+1}')
            bad.append(f'{jn}/{sn}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: $b — upload-artifact without name: → defaults to 'artifact' → 409 collision on multi-upload workflows"
            missing=$((missing + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked upload-artifact steps checked, $missing without name parameter"

[[ $ok -eq 1 ]] && exit 0 || exit 1
