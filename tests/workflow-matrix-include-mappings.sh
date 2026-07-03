#!/usr/bin/env bash
# For every workflow job with a `strategy.matrix.include` array,
# pin that every entry in the array is a mapping (dictionary)
# rather than a string, scalar, or list.
#
# GitHub Actions' matrix-include format is:
#
#   strategy:
#     matrix:
#       include:
#         - os: ubuntu-latest
#           target: x86_64-unknown-linux-gnu
#         - os: macos-latest
#           target: aarch64-apple-darwin
#
# Each entry is a MAPPING of dimension-name → value. The
# generated jobs run with those mapping entries as `matrix.X`
# context references.
#
# When an entry is malformed (string, list, scalar):
#
#   - A bare string like `- "ubuntu-latest"` is parsed as a
#     mapping value where the key is implicit — the job
#     generates ONCE with no `matrix.os` accessible because
#     no dimension name was declared.
#   - A list like `- [ubuntu-latest, x86_64]` produces a
#     matrix.X resolving to the list as a single value;
#     downstream `${{ matrix.0 }}` references don't work as
#     intended.
#   - A YAML-anchor merge that's broken can produce a null
#     entry, which silently expands to zero matrix rows.
#
# All three cases produce matrix expansion that doesn't match
# the developer's intent. The workflow runs (maybe with one
# job, maybe with zero) but the parameter sweep is broken.
#
# Detection: walk every job's strategy.matrix.include array,
# verify each entry's Python type is `dict`. Non-dict entries
# fail the gate.
#
# 90/90 workflow files green at iter-131 add — pure regression
# floor against malformed matrix expansion.
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
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

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
    bad = []
    for jn, job in jobs.items():
        if not isinstance(job, dict):
            continue
        strategy = job.get("strategy")
        if not isinstance(strategy, dict):
            continue
        matrix = strategy.get("matrix")
        if not isinstance(matrix, dict):
            continue
        include = matrix.get("include")
        if include is None:
            continue
        if not isinstance(include, list):
            bad.append(f"{jn}: include is not a list (got {type(include).__name__})")
            continue
        for i, entry in enumerate(include):
            if not isinstance(entry, dict):
                bad.append(f"{jn}: include[{i}] is {type(entry).__name__}, expected mapping")
    print("OK" if not bad else "BAD:" + "; ".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: ${output#BAD:}"
            bad=$((bad + 1))
            ok=0
            ;;
    esac
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $bad with malformed matrix.include entries"

[[ $ok -eq 1 ]] && exit 0 || exit 1
