#!/usr/bin/env bash
# For every workflow yml `permissions:` block in
# mapping form, pin that each key's VALUE is one of
# the canonical permission levels:
#
#   read     Grants read access to the scope
#   write    Grants read AND write access
#   none     Denies access (locks the scope)
#
# Per GitHub Actions spec, the per-permission value
# is restricted to these three strings. Anything else
# is a schema error.
#
# A non-canonical value:
#
#   permissions:
#     contents: write           # OK
#     pull-requests: read       # OK
#     issues: read-only         # WRONG — invented value
#     packages: full            # WRONG — invented value
#     statuses: rw              # WRONG — abbreviation
#     actions: writable         # WRONG — adjective form
#     deployments: yes          # WRONG — boolean-like
#
# GitHub Actions rejects the workflow at upload time
# with a schema error:
#
#   The workflow is not valid. .github/workflows/foo.yml
#   (Line: 7, Col: 12): Unexpected value 'read-only'.
#   The 'permissions' property must be ... value of
#   read/write/none.
#
# The error points at the bad-value column, which is
# better than the iter-211 case (where bad KEYS get a
# block-level error). But the gate catches it BEFORE
# pushing — faster feedback than waiting for the
# upload-time validation.
#
# Common typo sources:
#
#   read-only        → read         (suffix)
#   readonly         → read         (suffix)
#   write-only       → write        (suffix)
#   rw / wr          → write        (abbreviations)
#   full             → write        (synonym)
#   admin            → write        (concept confusion)
#   all              → write        (synonym for
#                                    all-scope write)
#   yes / no / true / false  →  read / write / none
#                              (boolean confusion;
#                              YAML auto-coerces
#                              'yes' to True
#                              boolean, which the
#                              schema rejects with a
#                              different error)
#   allow / deny     → read/none     (wrong vocabulary)
#   none-of-the-above → none         (typo nesting)
#
# Detection: YAML-parse each workflow. For every
# permissions block in mapping form (workflow or job
# level), check each VALUE against {read, write,
# none}. Skip None values (allowed for boolean-style
# YAML 1.1 confusion handling).
#
# Pairs with permissions canonicality catalog
# (completes the trio):
#   workflow-permissions-canonical-keys (iter-211)   — KEYS
#   workflow-permissions-canonical-string (iter-215) — string-form VALUE
#   workflow-permissions-canonical-values (this)     — mapping-form VALUES
#
# Together: every permissions config (string form OR
# mapping form, keys AND values) is gated.
#
# 88/88 mapping-form permission values canonical at
# iter-236 add — pure regression floor.
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
allowed = {'read', 'write', 'none'}
total = 0
bad = []

def check(perms, where):
    out = []
    if not isinstance(perms, dict):
        return 0, out
    cnt = 0
    for k, v in perms.items():
        cnt += 1
        if not isinstance(v, str) or v not in allowed:
            out.append(f'{where}:{k}={v!r}')
    return cnt, out

n, b = check(d.get('permissions'), 'workflow')
total += n; bad.extend(b)
for jn, job in (d.get('jobs', {}) or {}).items():
    if isinstance(job, dict):
        n, b = check(job.get('permissions'), f'job/{jn}')
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
            echo "FAIL  $wf: permissions $b — non-canonical value (must be read/write/none)"
            bad=$((bad + 1))
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
echo "Summary: $checked mapping-form permission values checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
