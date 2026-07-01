#!/usr/bin/env bash
# For every workflow yml step that declares a `with:`
# block, pin that the same step also declares `uses:`.
#
# `with:` is the parameter-block for invoking actions
# (`actions/checkout`, `actions/cache`, etc.). It's
# only meaningful in step definitions that reference
# an action via `uses:`. A step with `run:` and `with:`
# is a config error:
#
#   - name: Build
#     run: cargo build --release
#     with:                           # <-- silently ignored
#       target: x86_64-unknown-linux-gnu
#
# GitHub Actions silently drops the `with:` block in
# this case. No warning. No error. The step appears to
# work because `run:` executes correctly. But the
# parameters in `with:` never reach any code — they're
# dead config sitting in the workflow file.
#
# Failure modes:
#
#   1. Refactor drift: a step originally was
#      `uses: dtolnay/rust-toolchain` with
#      `with: { target: ... }`. Someone refactored it
#      to a manual `run: rustup target add ...` but
#      forgot to delete the `with:` block. The target
#      parameter is now ignored; build uses host
#      target instead.
#
#   2. Template misuse: a contributor copies a step
#      from another workflow that used an action with
#      parameters. They paste it into a new workflow,
#      change `uses:` to `run:` for some reason, but
#      keep the `with:`. CI runs but the parameters
#      vanish.
#
#   3. Conditional uses: someone tries to make a step
#      conditional by changing `uses:` to `run:` with
#      an if-shell-check, but keeps `with:` thinking
#      it parameterizes the run. The run block doesn't
#      receive the with values.
#
# All three are silent failures — CI shows green; the
# behavior is wrong but the symptom may not surface for
# days (until someone notices binaries built for the
# wrong target, or a flag that was supposed to be set
# isn't).
#
# Detection: YAML-parse each workflow. For every step
# (in any job), if `with:` is set, check `uses:` is
# also set. Fail otherwise.
#
# Pairs with workflow correctness family
# (workflow-needs-references, workflow-step-ids-valid,
# workflow-matrix-runs-on-defined). Adds the
# `with:`/`uses:` referential integrity.
#
# 0/249 steps with with-without-uses at iter-210 add —
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
orphans=0

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
        if 'with' not in step:
            continue
        total += 1
        if 'uses' not in step:
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
        for s in "${ba[@]}"; do
            echo "FAIL  $wf: step '$s' has 'with:' but no 'uses:' — with block silently ignored"
            orphans=$((orphans + 1))
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
echo "Summary: $checked with-using steps checked, $orphans without accompanying uses:"

[[ $ok -eq 1 ]] && exit 0 || exit 1
