#!/usr/bin/env bash
# Meta self-audit extension: every NEW audit gate must print a
# canonical `Summary:` line at the end of its output.
#
# Convention emerged from iter-1 onwards: gates print per-target
# PASS / FAIL lines as they walk the input, then end with:
#
#   ---
#   Summary: <N> <thing>s checked, <K> with <issue>
#
# (Plus exit 0 / exit 1.)
#
# Why this matters for CI integration:
#
#   1. PR check-output is truncated past N lines in GitHub's
#      Actions UI. The Summary line is the only guaranteed-
#      visible line — it's the last thing printed, always
#      shows in the truncated tail.
#   2. Aggregate dashboards parse the Summary line to extract
#      counts (current passing rate per gate across iterations).
#      Without a uniform Summary format, the dashboard breaks.
#   3. Single-line audit reports (e.g., a Slack notification
#      summarizing nightly CI) extract the Summary line as the
#      gate's whole signal.
#
# Detection: gate file's source contains `echo "Summary:` or
# `printf...Summary:` somewhere. The format of the Summary line
# itself is intentionally not constrained — count + scope
# description is left to per-gate judgment.
#
# Bootstrap allowlist: 5 gates predate the convention
# (bootstrap-era, before iter-1):
#   - bin-scripts.sh             (pre-loop original)
#   - homebrew-formulas.sh       (pre-loop original)
#   - shellcheck-tests.sh        (pre-loop original)
#   - submodule-integrity.sh     (pre-loop original)
#   - workflow-actions-versions.sh (informational, no PASS/FAIL
#                                   tally to summarize)
#
# These five are grandfathered. They've been working fine
# without Summary lines for the entire history of this catalog.
# The gate enforces the convention for every gate added FROM
# iter-1 ONWARDS — accidental Summary omission in a new gate
# is the regression this catches.
#
# 96/96 gates conform at iter-102 add (91 with Summary, 5
# grandfathered). Pure regression floor against future drift.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Bootstrap allowlist — gates added before the Summary
# convention emerged from iter-1.
declare -A GRANDFATHERED=(
    [bin-scripts.sh]=1
    [homebrew-formulas.sh]=1
    [shellcheck-tests.sh]=1
    [submodule-integrity.sh]=1
    [workflow-actions-versions.sh]=1
)

checked=0
missing=0
grandfathered=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"

    # Skip this gate's own self-reference (it documents the
    # Summary pattern in its description).
    [[ "$base" == "meta-summary-line.sh" ]] && continue

    if [[ -n "${GRANDFATHERED[$base]:-}" ]]; then
        grandfathered=$((grandfathered + 1))
        continue
    fi

    checked=$((checked + 1))
    if grep -qE 'echo +"Summary:|echo "Summary:|printf .*Summary:' "$f"; then
        echo "PASS  $base: prints Summary line"
    else
        echo "FAIL  $base: no Summary line in gate output — CI dashboards / truncation will lose the gate's signal"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked post-bootstrap gates checked, $missing without Summary line ($grandfathered grandfathered)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
