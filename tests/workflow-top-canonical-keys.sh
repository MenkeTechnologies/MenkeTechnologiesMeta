#!/usr/bin/env bash
# For every workflow yml file, pin that the top-level
# keys are canonical GitHub Actions workflow keys per
# the official schema.
#
# Canonical workflow top-level keys:
#
#   name           Workflow display name
#   run-name       Per-run name template
#   on             Trigger configuration (becomes True
#                  under YAML 1.1 — accepted)
#   permissions    GITHUB_TOKEN scope
#   env            Workflow-wide env vars
#   defaults       Default shell/working-dir
#   concurrency    Serialization-lane config
#   jobs           Jobs map (required)
#
# A non-canonical top-level key:
#
#   name: CI
#   on: { push: { ... } }
#   runs-name: "PR-${{ ... }}"  # WRONG — should be
#                                run-name
#   Jobs:                       # WRONG — capitalized
#     build: ...
#   permission:                 # WRONG — singular
#     contents: read
#
# GitHub Actions silently IGNORES unknown top-level
# keys (no schema rejection at the keys layer for
# minor schema mismatches):
#
#   - runs-name → ignored; per-run names stay at
#     default ("workflow_name #N"); the intended
#     dynamic naming never appears in the Actions
#     UI; contributor sees no error but the feature
#     they thought they configured doesn't work
#
#   - Jobs (capitalized) → ignored; the workflow has
#     NO jobs from the parser's view; workflow run
#     completes immediately with no work done; CI
#     check goes green; contributor sees the
#     workflow ran but the actual job code never
#     executed — they may not notice until a release
#     bug surfaces in production
#
#   - permission (singular) → ignored; permissions
#     stay at default (read for contents, no others);
#     workflow tries to push, fails with "Permission
#     to ... denied to github-actions[bot]"; the
#     manifest LOOKS like it grants write
#
# Common typo sources:
#
#   runs-name      → run-name        (plural prefix)
#   run_name       → run-name        (snake→kebab)
#   permission     → permissions     (singular)
#   permissions:   → permissions     (correct, just
#                                     showing case
#                                     varies)
#   Jobs / JOBS    → jobs            (case)
#   Env            → env             (case)
#   default        → defaults        (singular)
#   trigger / triggers → on          (wrong word
#                                     entirely)
#   concurency     → concurrency     (typo)
#   workflow_call  → (this is an `on:` trigger, not
#                     a top-level key)
#
# Detection: YAML-parse each workflow. Check
# top-level keys against canonical set. Skip the
# YAML-True quirk (Python's yaml loader converts
# bare `on:` to True boolean key).
#
# Pairs with cargo manifest hygiene catalog (extends
# the canonical-keys principle from cargo to
# workflow):
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-permissions-canonical-keys (iter-211)
#   workflow-concurrency-canonical-keys (iter-216)
#   workflow-top-canonical-keys (this) — workflow
#                                        root keys
#
# 0/90 workflows use non-canonical top-level keys at
# iter-227 add — pure regression floor.
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
    checked=$((checked + 1))
    result=$(python3 - "$wf" <<'PY'
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('')
    sys.exit()
if not isinstance(d, dict):
    print('')
    sys.exit()
allowed = {
    'name', 'run-name', 'on', 'permissions', 'env',
    'defaults', 'concurrency', 'jobs',
}
bad = []
for k in d.keys():
    # YAML 1.1: bare `on:` becomes True boolean — skip
    if k is True:
        continue
    if k not in allowed:
        bad.append(str(k))
print(';'.join(bad))
PY
)
    if [[ -n "$result" ]]; then
        IFS=';' read -ra ba <<< "$result"
        for k in "${ba[@]}"; do
            echo "FAIL  $wf: top-level key '$k' is non-canonical — GitHub Actions silently ignores; intended config NOT applied"
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
echo "Summary: $checked workflows checked, $bad non-canonical top-level keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
