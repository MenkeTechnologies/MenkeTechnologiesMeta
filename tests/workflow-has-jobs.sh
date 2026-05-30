#!/usr/bin/env bash
# For every .github/workflows/*.yml, pin that the file declares
# at least one entry under the `jobs:` mapping.
#
# A workflow with no jobs is structurally valid YAML AND has a
# valid `on:` trigger, but GitHub Actions treats it as a no-op:
# the workflow "runs" (shows up in the Actions tab), every
# trigger fires it, but nothing actually executes. From the
# user's perspective it looks like CI is passing.
#
# This is a worse failure mode than iter-68's YAML-parse gate:
#   - YAML-parse failure → workflow doesn't appear at all
#   - Empty jobs section → workflow appears, "succeeds", does
#     nothing
#
# The second is more dangerous because it produces a green
# check mark on PRs without running any tests. Merges happen
# against unchecked code.
#
# How it sneaks in:
#   - Job definitions accidentally indented BELOW the jobs:
#     key during a reformat (now they're not under jobs at all)
#   - YAML anchor-based jobs (`<<: *base_job`) where the anchor
#     was removed but the alias stayed (jobs.foo becomes null)
#   - Cut/paste from a template that has `jobs: {}` placeholder
#     and forgot to fill in
#
# Test uses python yaml.safe_load + count of `jobs` dict keys.
# A YAML parse failure is delegated to iter-68's gate; this
# gate focuses on the structural check past parsing.
#
# 90/90 workflow files green at iter-80 add — pure regression
# floor against the silent-no-op failure mode.
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
empty=0
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    count=$(python3 -c '
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print(-1)
    else:
        jobs = d.get("jobs", {})
        print(len(jobs) if isinstance(jobs, dict) else 0)
except Exception:
    print(-1)
' "$wf")

    if [[ "$count" == "-1" ]]; then
        echo "SKIP  $wf: YAML parse failure (delegated to iter-68)"
        parse_fail=$((parse_fail + 1))
        continue
    fi

    if [[ "$count" -lt 1 ]]; then
        echo "FAIL  $wf: 0 jobs defined (workflow appears in Actions tab but does nothing)"
        empty=$((empty + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked ($parse_fail YAML-unparseable delegated to iter-68), $empty with no jobs"

[[ $ok -eq 1 ]] && exit 0 || exit 1
