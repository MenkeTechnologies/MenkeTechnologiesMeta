#!/usr/bin/env bash
# For every workflow yml `permissions:` value declared as a
# STRING (not a mapping), pin that the value is one of the
# three canonical strings per GitHub Actions spec:
#
#   permissions: read-all     # grants read access to all scopes
#   permissions: write-all    # grants write access to all scopes
#   permissions: none         # grants no access (zero scopes)
#
# Workflow examples (all valid):
#
#   permissions: read-all
#
#   permissions:
#     contents: write
#     pull-requests: write
#
#   permissions: {}          # equivalent to read-all (default)
#
# When the string form is used with a non-canonical value:
#
#   permissions: read         # WRONG — not a permission
#                               keyword, ambiguous
#
#   permissions: readonly     # WRONG — not canonical
#                               (likely typo of read-all)
#
#   permissions: all-read     # WRONG — wrong order
#
#   permissions: r-a          # WRONG — abbreviation
#
# GitHub Actions REJECTS the workflow at upload time with a
# schema error. The message points at the permissions line:
#
#   The workflow is not valid. .github/workflows/foo.yml
#   (Line: 5, Col: 14): The 'permissions' property is
#   incorrect: value of 'permissions' must be a mapping or
#   one of the following values: 'read-all', 'write-all',
#   'none'.
#
# Local CI gating catches this BEFORE pushing, faster
# feedback. Cost: zero (the regex is tiny). Benefit:
# eliminates a class of typo errors that produce non-obvious
# YAML schema rejections.
#
# Companion to iter-211 (workflow-permissions-canonical-
# keys.sh) which covers the MAPPING form. Together they
# enforce: every permissions value is either a canonical
# string or a mapping with canonical keys.
#
# The mapping form (covered by iter-211) is the
# fine-grained least-privilege configuration; the string
# form is a coarse-grained shortcut used in workflows that
# need either "everything read" (read-all) or "everything
# locked" (none).
#
# Detection: YAML-parse each workflow. For every
# permissions: value (workflow or job level), if it's a
# string, check that it's one of {read-all, write-all,
# none}.
#
# Pairs with workflow security defense family:
#   workflow-no-write-all              — flags 'write-all'
#                                        as too permissive
#   workflow-permissions-canonical-keys — mapping form
#   workflow-permissions-canonical-string (this) — string
#                                                 form
#
# 0/90 workflows use permission-string form at iter-215
# add (all use mapping form covered by iter-211). Gate
# is a forward-looking regression floor against future
# introduction of non-canonical string values.
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
canonical = {'read-all', 'write-all', 'none'}
total = 0
bad = []

def check(perms, where):
    if not isinstance(perms, str):
        return 0, []
    if perms in canonical:
        return 1, []
    return 1, [f'{where}:{perms!r}']

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
            echo "FAIL  $wf: permissions $b — not canonical (read-all / write-all / none)"
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
echo "Summary: $checked permission-string values checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
