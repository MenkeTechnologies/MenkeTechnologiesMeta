#!/usr/bin/env bash
# For every workflow yml `permissions:` block (workflow
# or job level, when in mapping form), pin that each key
# is a CANONICAL GitHub Actions permission name.
#
# GitHub Actions' `permissions:` schema accepts ONLY a
# fixed set of permission names. Per the official docs:
#
#   actions               Workflow / Actions API access
#   attestations          Attestation creation/verification
#   checks                Check-runs API access
#   contents              Repository contents (push/pull)
#   deployments           Deployment API + environments
#   discussions           Discussion API access
#   id-token              OIDC JWT minting (privileged)
#   issues                Issue API + comments
#   models                GitHub Models API access
#   packages              Package registry (read/write)
#   pages                 GitHub Pages deploy
#   pull-requests         PR API + reviews + comments
#   repository-projects   Repository project board
#   security-events       Code scanning alerts API
#   statuses              Commit status checks
#
# When a workflow declares an UNKNOWN key in permissions:
#
#   permissions:
#     pull_request: write   # WRONG — snake_case
#     issue: read           # WRONG — singular
#     packages: read        # OK
#
# GitHub Actions rejects the workflow at upload time with
# a validation error. But the error message uses YAML-
# pathing notation that obscures which key is bad:
#
#   The workflow is not valid. .github/workflows/ci.yml
#   (Line: 5, Col: 5): Required property is missing.
#
# That message points at the permissions block start, NOT
# the typo line. Diagnosing requires manual eyeballing
# against the docs. Each new contributor learning the
# schema hits the same friction.
#
# Common typos this gate catches:
#
#   pull_request → pull-requests      (snake-case → kebab)
#   pull-request → pull-requests      (singular)
#   issue → issues                    (singular)
#   action → actions                  (singular)
#   security-event → security-events  (singular)
#   id_token → id-token               (snake-case → kebab)
#   repository_projects → repository-projects
#                                     (snake-case → kebab)
#   page → pages                      (singular)
#   discussion → discussions          (singular)
#   deploy → deployments              (truncation)
#   check → checks                    (singular)
#   status → statuses                 (singular)
#   container → packages              (wrong field for
#                                     container registry)
#
# The gate only checks MAPPING form (`permissions: { ...
# }`). String form (`permissions: read-all` /
# `write-all` / `none`) is accepted as-is — those are
# the three valid string values per the spec.
#
# Detection: YAML-parse each workflow. For every
# permissions: block in mapping form (workflow or job
# level), check each key against the canonical set.
# Fail on any unknown key.
#
# Pairs with workflow security defense family
# (no-write-all, no-id-token-write) — adds the
# typo-prevention layer for permission names.
#
# 88/88 permission keys are canonical at iter-211 add —
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
canonical = {
    'actions', 'attestations', 'checks', 'contents',
    'deployments', 'discussions', 'id-token', 'issues',
    'models', 'packages', 'pages', 'pull-requests',
    'repository-projects', 'security-events', 'statuses',
}
total = 0
bad = []

def collect(perms, where):
    out = []
    if not isinstance(perms, dict):
        return 0, out
    cnt = 0
    for k in perms.keys():
        cnt += 1
        if k not in canonical:
            out.append(f'{where}:{k}')
    return cnt, out

n, b = collect(d.get('permissions'), 'workflow')
total += n; bad.extend(b)
for jn, job in (d.get('jobs', {}) or {}).items():
    if isinstance(job, dict):
        n, b = collect(job.get('permissions'), f'job/{jn}')
        total += n; bad.extend(b)

print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for k in "${ba[@]}"; do
            echo "FAIL  $wf: $k — unknown permission key (typo? check kebab-case + plural)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked permission keys checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
