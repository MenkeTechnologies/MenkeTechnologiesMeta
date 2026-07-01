#!/usr/bin/env bash
# For every workflow job that declares `timeout-minutes:`, pin
# that the value is an integer in the range [1, 360].
#
# GitHub Actions' timeout-minutes default is 360 (6 hours) —
# that's also the hard ceiling for hosted runners. Below 1
# minute is meaningless (the runner spin-up alone takes ~30s).
# Above 360 is rejected by GitHub Actions at runtime:
#
#   Error: The timeout setting must be less than or equal to 360.
#
# Why this matters even though GitHub catches the upper bound
# at runtime:
#
#   - PR-time error (lint) is faster feedback than runtime
#     error (workflow attempt). The runtime error fires after
#     workflow dispatch; the contributor has to push, wait for
#     the workflow to start, then see the failure. Lint-time
#     surfaces it at PR review.
#   - Zero or negative timeouts indicate a hand-edit typo
#     (deleted a digit) or a misunderstanding of the units
#     (seconds vs minutes confusion). The default if the
#     field is parsed as an empty value depends on the YAML
#     loader; sometimes it's 360 (default), sometimes 0
#     (immediate timeout).
#   - Values like `timeout-minutes: "30"` (string instead of
#     int) parse cleanly in YAML but GitHub Actions rejects
#     at runtime. Lint-time type check catches the form.
#
# Reasonable range: 1 to 360 inclusive. The 1-minute lower
# bound rejects 0 and negatives; the 360 upper matches
# GitHub's own ceiling.
#
# Detection: integer type + value bounds. Non-integer types
# (strings, lists, mappings) FAIL with a typed error.
#
# 121/121 jobs with timeout-minutes set at iter-135 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "SKIP  PyYAML not installed"
    exit 0
fi

checked=0
bad=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue

    output=$(python3 -c '
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("PARSE_FAIL")
        sys.exit()
    jobs = d.get("jobs", {}) or {}
    if not isinstance(jobs, dict):
        print("PARSE_FAIL")
        sys.exit()
    results = []
    for jn, job in jobs.items():
        if not isinstance(job, dict):
            continue
        tm = job.get("timeout-minutes")
        if tm is None:
            continue
        if not isinstance(tm, int) or isinstance(tm, bool):
            results.append(f"BAD:{jn}:{tm!r} (type {type(tm).__name__})")
        elif tm <= 0 or tm > 360:
            results.append(f"BAD:{jn}:{tm} (must be 1..360)")
        else:
            results.append(f"OK:{jn}:{tm}")
    print("\n".join(results) if results else "NO_TIMEOUTS")
except Exception:
    print("PARSE_FAIL")
' "$wf")

    [[ "$output" == "NO_TIMEOUTS" || "$output" == "PARSE_FAIL" ]] && continue

    while IFS=: read -r status jn rest; do
        [[ -z "$status" ]] && continue
        checked=$((checked + 1))
        if [[ "$status" == "OK" ]]; then
            : # silent pass
        else
            echo "FAIL  $wf $jn: $rest"
            bad=$((bad + 1))
            ok=0
        fi
    done <<< "$output"
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
echo "Summary: $checked jobs with timeout-minutes checked, $bad out-of-range or non-int"

[[ $ok -eq 1 ]] && exit 0 || exit 1
