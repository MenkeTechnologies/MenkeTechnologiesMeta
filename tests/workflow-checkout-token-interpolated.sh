#!/usr/bin/env bash
# For every workflow yml step using `actions/checkout`
# that sets `with.token:`, pin that the value is a
# `${{ }}` interpolation (no bare token string).
#
# A bare token string in the workflow file:
#
#   - uses: actions/checkout@v4
#     with:
#       token: ghp_AbCdEf123...   # WRONG — literal PAT
#                                   committed to git
#       repository: org/private
#
# Failure mode is CATASTROPHIC:
#
#   - The PAT (Personal Access Token) is now in git
#     history forever. Even removing it in a future
#     commit doesn't help — the original commit's blob
#     is still in `git log --all` and any clone of the
#     repo's reflog.
#
#   - GitHub's secret-scanning push protection MAY
#     catch the obvious ghp_ / gho_ / ghs_ prefixes
#     and reject the push. But:
#       - Custom token formats (older PATs without
#         the gh prefix, OAuth bearer tokens from
#         third-party services, deploy keys) are NOT
#         caught
#       - Secret scanning can be DISABLED at org
#         level
#       - The check fires AT PUSH; by then the
#         contributor has already committed the
#         secret locally and may have it in their
#         git-credential cache
#
#   - Once the secret is in the public repo, anyone
#     with read access can extract it; for public
#     repos that means the entire internet
#
# The fix: ALWAYS use `${{ secrets.X }}` interpolation:
#
#   - uses: actions/checkout@v4
#     with:
#       token: ${{ secrets.PAT }}    # CORRECT
#       repository: org/private
#
# This:
#   - Keeps the secret in GitHub's secret-store (encrypted
#     at rest, audit-logged on access)
#   - Resolves to the secret value only at workflow runtime,
#     in the runner's memory — never in git history
#   - Allows secret rotation without changing the workflow
#     file
#
# Note: `${{ secrets.GITHUB_TOKEN }}` is the default token
# the runner provides; not explicitly setting `token:` uses
# it. Setting `token: ${{ secrets.GITHUB_TOKEN }}`
# explicitly is redundant but harmless.
#
# Detection: YAML-parse each workflow. For every step with
# `uses: actions/checkout@<v>` that has `with.token`, check
# the value contains `${{` (interpolation marker).
#
# Pairs with workflow security defense family:
#   workflow-no-secret-echo            — no echo $SECRET
#   workflow-no-workflow-level-secret-env — no workflow-
#                                            scope secrets
#   workflow-checkout-token-interpolated (this) — no bare
#                                                  token
#                                                  strings
#
# 10/10 checkout tokens use interpolation at iter-241 add
# — pure regression floor.
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
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        u = step.get('uses')
        if not isinstance(u, str) or 'actions/checkout' not in u:
            continue
        w = step.get('with', {})
        if not isinstance(w, dict):
            continue
        if 'token' not in w:
            continue
        total += 1
        v = w['token']
        sn = step.get('name', f'step #{i+1}')
        if isinstance(v, str) and '${{' not in v:
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
            echo "FAIL  $wf: actions/checkout $b → with.token has no \${{ }} interpolation — bare token committed to git, CATASTROPHIC secret leak"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked actions/checkout with.token uses checked, $bad without interpolation"

[[ $ok -eq 1 ]] && exit 0 || exit 1
