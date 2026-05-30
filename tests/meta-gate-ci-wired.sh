#!/usr/bin/env bash
# For every shell script in tests/, pin that
# `.github/workflows/ci.yml` invokes it as a step
# (`bash tests/<name>.sh` substring present).
#
# This catches the "ORPHAN GATE" failure mode: a gate
# is added to tests/, the gate's logic is correct, but
# the developer forgot to wire it into ci.yml. The
# orphan:
#
#   - Passes locally when run by hand (visible signal
#     of correctness)
#   - Never runs in CI (no signal that it's enforcing
#     anything)
#   - Slowly rots as the codebase drifts (gate logic
#     becomes stale, references files that no longer
#     exist, gets out-of-sync with the convention it
#     audits)
#   - Eventually fails to even start (broken state
#     references)
#
# An orphan gate is WORSE than no gate, because:
#
#   - It signals "this is audited" to future
#     reviewers via tests/ filename
#   - But provides ZERO actual enforcement
#   - Future contributors trust the filename, see no
#     CI failure, and assume the convention is met
#   - The codebase silently drifts past whatever
#     bound the gate was meant to enforce
#
# The CI catalog (ci.yml) is the source of truth for
# "what runs on every PR". A gate exists only when
# it's wired in.
#
# Detection: for every tests/*.sh file, grep ci.yml
# for the literal `tests/<filename>.sh` reference. The
# CI catalog is structured as `run: bash
# tests/<name>.sh` so the grep is unambiguous.
#
# Pairs with the meta-gate-* family:
#   meta-gate-canonical-set        — set -uo pipefail
#   meta-gate-exit-pattern         — exit 0/1 form
#   meta-gate-filename-kebab       — naming convention
#   meta-gate-header-comment       — line-2 docstring
#   meta-gate-size-bound           — ≤250 lines
#   meta-gate-ci-wired (this)      — orphan detection
#
# This is the LAST guard in the catalog-hygiene
# family: even if a gate satisfies all syntactic
# requirements, it's worthless if CI doesn't run it.
# This gate closes that loop.
#
# 192/192 gates wired at iter-200 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

ci="$root/.github/workflows/ci.yml"
if [[ ! -f "$ci" ]]; then
    echo "SKIP  $ci not found"
    exit 0
fi

checked=0
unwired=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))
    bn=$(basename "$f")
    if ! grep -qE "tests/$bn\b" "$ci"; then
        echo "FAIL  tests/$bn: not invoked from .github/workflows/ci.yml — orphan gate (never runs in CI)"
        unwired=$((unwired + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked gates checked, $unwired orphan (not wired into CI)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
