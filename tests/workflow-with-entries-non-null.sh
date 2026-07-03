#!/usr/bin/env bash
# For every workflow yml step `with:` block entry,
# pin that the value is non-null (not YAML's null
# scalar).
#
# YAML's null scalar can sneak into with-blocks via
# several forms:
#
#   with:
#     fetch-depth:          # WRONG — no value, null
#     ref: main
#     submodules: ~         # WRONG — ~ is null
#     persist-credentials: null  # WRONG — explicit
#                                  null
#     token: Null           # WRONG — capitalized null
#                            still null
#
# All four resolve to Python None in yaml.safe_load.
# The action's input parsing then sees a missing
# value and uses the DEFAULT for that parameter.
#
# The contributor's intent was probably to:
#
#   a) Comment out the parameter for debugging — but
#      the partial deletion left `key:` behind with
#      no value; the line LOOKS like configuration
#      but is silent no-op
#
#   b) Explicit "use default" — but actions don't
#      treat null as "use default"; they treat it as
#      "value is unspecified" which is the same as
#      omitting the key entirely. The intent to
#      EXPLICITLY default the value is moot —
#      omitting works the same way.
#
#   c) YAML alias / anchor that resolved to null —
#      &foo / *foo expansion that didn't produce a
#      value; symptom is confusing because the YAML
#      LOOKS structured
#
# Failure modes:
#
#   - actions/checkout `fetch-depth:` (null) →
#     fetch-depth stays default 1 (shallow); the
#     contributor THOUGHT they set 0 (full); git
#     describe fails downstream
#
#   - actions/cache `restore-keys:` (null) →
#     restore-keys empty; cache miss has no
#     fallback; full rebuild every PR
#
#   - actions/upload-artifact `name:` (null) → name
#     defaults to 'artifact'; multi-upload collisions
#     (iter-218 covers the artifact name case)
#
# False positive risk: YAML's empty string vs null.
# In yaml.safe_load:
#
#   key: ''        →  '' (empty string)
#   key: ""        →  '' (empty string)
#   key:           →  None (null)
#   key: ~         →  None (null)
#
# Empty string IS distinct from null. Both are
# probably bugs in workflow context, but this gate
# only flags null — the unambiguous "missing value"
# case.
#
# Detection: YAML-parse each workflow. For every
# step's with: dict, check each value for None.
#
# Pairs with workflow correctness family:
#   workflow-with-needs-uses          — with: needs
#                                       accompanying
#                                       uses:
#   workflow-with-entries-non-null (this) — values
#                                            are
#                                            non-null
#
# 0/403 with-entries are null at iter-238 add — pure
# regression floor.
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
        w = step.get('with')
        if not isinstance(w, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        for k, v in w.items():
            total += 1
            if v is None:
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
            echo "FAIL  $wf: with $b → null — value missing; action uses DEFAULT instead of intended config"
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
echo "Summary: $checked with-entries checked, $bad with null values"

[[ $ok -eq 1 ]] && exit 0 || exit 1
