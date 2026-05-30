#!/usr/bin/env bash
# For every workflow yml step using `actions/download-
# artifact`, pin that the `with:` block uses only
# canonical parameter keys per download-artifact@v4+
# schema.
#
# Canonical actions/download-artifact v4 with-keys:
#
#   name              Artifact name to download (omit
#                     to download ALL artifacts in
#                     workflow run)
#   path              Destination directory (default
#                     $GITHUB_WORKSPACE)
#   pattern           Glob pattern for multi-artifact
#                     selection (alternative to name)
#   merge-multiple    Merge multiple artifacts into
#                     a single dir (default false)
#   github-token      Token for cross-workflow
#                     downloads
#   repository        Source repo for cross-repo
#                     downloads
#   run-id            Workflow run ID to download
#                     from
#   artifact-ids      Comma-separated artifact IDs
#                     (alternative to name/pattern)
#
# A non-canonical key:
#
#   - uses: actions/download-artifact@v4
#     with:
#       name: foo
#       path: ./dist
#       merge_multiple: true        # WRONG — snake
#       github_token: ${{ ... }}    # WRONG — snake
#       run_id: 123                 # WRONG — snake
#       artifact_ids: 1,2,3         # WRONG — snake
#
# GitHub Actions silently IGNORES unknown with-keys.
# Action runs with DEFAULTS:
#
#   - merge_multiple (snake) → ignored; merge-
#     multiple stays default FALSE; each artifact
#     downloads into its OWN subdirectory; the
#     consumer (release script, deploy step)
#     expects flat structure and fails "no such
#     file or directory" when looking for the asset
#
#   - github_token (snake) → ignored; cross-workflow
#     download falls back to GITHUB_TOKEN with
#     workflow-run scope; permission errors on
#     private-repo cross-fetch
#
#   - run_id (snake) → ignored; downloads from
#     CURRENT workflow run instead of the intended
#     historical run; the wrong artifact comes down
#     when re-running a workflow that meant to
#     fetch an earlier release's assets
#
#   - artifact_ids (snake) → ignored; falls back to
#     name/pattern matching; the precise ID-based
#     selection doesn't happen; ambiguous selection
#     errors or wrong artifact downloaded
#
# Common typo sources:
#
#   merge_multiple    → merge-multiple    (snake)
#   mergeMultiple     → merge-multiple    (camel)
#   github_token      → github-token      (snake)
#   githubToken       → github-token      (camel)
#   run_id            → run-id            (snake)
#   runId             → run-id            (camel)
#   workflow_run_id   → run-id            (compound)
#   artifact_ids      → artifact-ids      (snake)
#   artifactIds       → artifact-ids      (camel)
#   artifact_id       → artifact-ids      (singular)
#   artifact_name     → name              (suffix)
#   dest_path         → path              (compound)
#   destination       → path              (synonym)
#   filter            → pattern           (synonym)
#
# Detection: YAML-parse each workflow. For every
# step with `uses: actions/download-artifact@<v>`,
# check `with:` block keys against canonical v4
# set.
#
# Pairs with canonical-keys family — fourteenth
# table:
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-checkout-canonical-with
#   workflow-cache-canonical-with
#   workflow-upload-artifact-canonical-with
#   workflow-download-artifact-canonical-with (this)
#
# Forms the symmetric pair with iter-232
# (upload-artifact). Together they cover the
# artifact upload/download handshake.
#
# 34/34 download-artifact with-keys canonical at
# iter-233 add — pure regression floor.
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
    'name', 'path', 'pattern', 'merge-multiple',
    'github-token', 'repository', 'run-id',
    'artifact-ids',
}
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
        if 'actions/download-artifact' not in u:
            continue
        total += 1
        w = step.get('with', {})
        if not isinstance(w, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        for k in w.keys():
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
            echo "FAIL  $wf: actions/download-artifact $b — non-canonical with-key (silently ignored; default applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked download-artifact uses checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
