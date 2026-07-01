#!/usr/bin/env bash
# For every workflow yml, pin that all `jobs.<key>` identifiers
# are valid GitHub Actions context identifiers:
#
#   ^[A-Za-z_][A-Za-z0-9_-]*$
#
# Per GitHub Actions context-reference spec, job ids appear in:
#
#   - `needs: [job_id]`            inter-job dependency edges
#   - `${{ needs.<id>.result }}`   job outcome reference
#   - `${{ needs.<id>.outputs.X }}` job output reference
#   - `${{ jobs.<id>.result }}`    workflow-level job lookups
#   - `gh run download --job <id>`  CLI artifact download
#
# When a job id is INVALID (contains spaces, starts with a
# digit, has special chars):
#
#   - Some downstream references silently resolve to null or
#     fail at evaluation time with unhelpful "context property
#     not found" errors.
#   - `needs: ["bad id"]` may parse as a single bracketed
#     string, expand differently than intended, or fail at
#     dependency-graph construction (caught by GitHub at
#     upload time → workflow vanishes; iter-85 covers the
#     reference-side but not the id-side).
#   - CLI tools (gh, github-cli) that accept job ids fail or
#     get confused.
#
# Examples of invalid forms:
#
#   Bad:  build and test       (space)
#   Bad:  2-build-test          (digit-leading)
#   Bad:  build.test            (dot)
#   Bad:  build/test            (slash)
#   Good: build_and_test
#   Good: build-test
#   Good: BuildTest
#
# Pairs with iter-118 (step ids valid + unique per job).
# Iter-124 covers the OUTER level (job ids); iter-118 covers
# the INNER level (step ids within each job).
#
# 90/90 workflow files green at iter-124 add — pure regression
# floor.
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
invalid=0
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    output=$(python3 -c '
import sys, yaml, re
ID_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_-]*$")
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
    for jn in jobs.keys():
        if not isinstance(jn, str) or not ID_RE.match(jn):
            bad.append(repr(jn))
    print("OK" if not bad else "BAD:" + ",".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: invalid job ids — ${output#BAD:}"
            invalid=$((invalid + 1))
            ok=0
            ;;
    esac
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $invalid with invalid job ids"

[[ $ok -eq 1 ]] && exit 0 || exit 1
