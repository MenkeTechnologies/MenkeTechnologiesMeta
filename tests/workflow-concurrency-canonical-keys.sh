#!/usr/bin/env bash
# For every workflow yml `concurrency:` block in mapping
# form (workflow or job level), pin that the block's keys
# are limited to the two canonical fields per the GitHub
# Actions spec:
#
#   group              (required) the serialization lane
#                       identifier
#   cancel-in-progress (optional) bool — whether new runs
#                       cancel in-flight runs in the same
#                       group
#
# Anything else is a typo or schema misunderstanding:
#
#   cancel_in_progress: true   # WRONG — snake_case
#   cancelInProgress: true     # WRONG — camelCase
#   cancel-in-flight: true     # WRONG — wrong key name
#   queue: true                # WRONG — invented field
#   serial: false              # WRONG — invented field
#
# GitHub Actions rejects unknown concurrency keys at
# workflow upload time with a schema error:
#
#   The workflow is not valid. .github/workflows/foo.yml
#   (Line: 5, Col: 3): Unexpected value 'cancel_in_progress'
#
# That message points at the BLOCK's start position, not
# the typo line. Diagnosing requires manual eyeballing.
#
# Common typos this gate catches:
#
#   cancel_in_progress  → cancel-in-progress  (snake→kebab)
#   cancelInProgress    → cancel-in-progress  (camel→kebab)
#   cancel-progress     → cancel-in-progress  (truncated)
#   cancel-in-flight    → cancel-in-progress  (wrong word)
#   cancel              → cancel-in-progress  (truncated)
#   queue               → cancel-in-progress  (wrong key
#                                              name, but
#                                              same intent)
#   serial / parallel   → group               (wrong concept;
#                                              GH uses
#                                              concurrency
#                                              groups not
#                                              parallel
#                                              flags)
#
# Detection: YAML-parse each workflow. For every
# concurrency block (workflow or job level) that's a dict,
# require every key to be in {group, cancel-in-progress}.
#
# Pairs with concurrency catalog:
#   workflow-concurrency-group         — requires group: key
#   workflow-concurrency-group-scoped  — group must reference
#                                        github.* context
#   workflow-concurrency-canonical-keys (this) — only known
#                                                keys allowed
#
# Completes the concurrency block hygiene triangle: key
# presence (group), key content (github context), and key
# set (canonical only).
#
# 59/59 concurrency blocks use only canonical keys at
# iter-216 add — pure regression floor.
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
allowed = {'group', 'cancel-in-progress'}
total = 0
bad = []

def collect(c, where):
    out = []
    if not isinstance(c, dict):
        return 0, out
    bad_keys = set(c.keys()) - allowed
    if bad_keys:
        for k in sorted(bad_keys):
            out.append(f'{where}:{k}')
    return 1, out

n, b = collect(d.get('concurrency'), 'workflow')
total += n; bad.extend(b)
for jn, job in (d.get('jobs', {}) or {}).items():
    if isinstance(job, dict):
        n, b = collect(job.get('concurrency'), f'job/{jn}')
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
            echo "FAIL  $wf: concurrency $b — unknown key (only group + cancel-in-progress allowed)"
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
echo "Summary: $checked concurrency blocks checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
