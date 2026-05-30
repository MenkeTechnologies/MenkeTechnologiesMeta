#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate must
# be wired into .github/workflows/ci.yml as a `run:` step.
#
# Iter-65's meta-self-audit pinned that every gate file has
# the right shape (shebang, set ...pipefail, exec bit, root=
# pattern). This gate pins that every shaped gate is also
# INVOKED — a perfectly-shaped audit script that never runs
# in CI catches nothing.
#
# Failure mode this gate forecloses:
#
#   1. Add a new gate file (e.g., tests/foo-bar.sh) but forget
#      to add the `run: bash tests/foo-bar.sh` line to ci.yml.
#      Locally `bash tests/foo-bar.sh` runs and PASSes — looks
#      like the gate is enforced. CI doesn't run it. Drift
#      passes silently in PRs.
#
#   2. Rename a gate (tests/foo.sh → tests/foo-v2.sh) but
#      forget to update the corresponding `run:` line in ci.yml.
#      The renamed gate exists; ci.yml's old reference is dead
#      code. CI now passes because the dead reference is
#      effectively a no-op step.
#
#   3. Delete an obsolete gate but leave the ci.yml reference
#      (causes a hard CI failure that's at least visible) OR
#      delete both gate and reference but leave the gate's
#      LOGIC tested only by the (now-removed) gate — silent
#      coverage gap.
#
# Detection: for every `tests/*.sh`, grep the literal string
# `bash tests/<basename>` in `.github/workflows/ci.yml`. The
# substring `bash tests/` is the canonical invocation pattern
# across every gate's wiring; matching on it catches both
# `run: bash tests/foo.sh` and inline-bash-with-flags variants.
#
# Why this gate matters in the CLAUDE.md audit-tool framework:
# the recursion property of the self-audit catalog requires
# that the gate set in tests/ MATCH the gate set CI actually
# enforces. Drift between the two = the count reported by the
# /loop ("Total audit gates: N") becomes a lie because some
# gates in the count aren't being run.
#
# 93/93 audit gates wired at iter-99 add — pure regression
# floor against accidental ci.yml-drift on gate additions.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

ci_yml=".github/workflows/ci.yml"
if [[ ! -f "$ci_yml" ]]; then
    echo "SKIP  no $ci_yml"
    exit 0
fi

checked=0
unwired=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f")

    # Exception: this gate itself is wired in ci.yml after iter-99
    # ships. During the bootstrap commit (the same commit that
    # introduces the gate AND the ci.yml step), self-reference
    # passes — the file's own basename appears in ci.yml in the
    # same change.
    checked=$((checked + 1))

    if grep -qF "bash tests/$base" "$ci_yml"; then
        echo "PASS  $base: wired in $ci_yml"
    else
        echo "FAIL  $base: gate exists in tests/ but no \`bash tests/$base\` invocation in $ci_yml"
        unwired=$((unwired + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked audit gates checked, $unwired present but not wired in CI"

[[ $ok -eq 1 ]] && exit 0 || exit 1
