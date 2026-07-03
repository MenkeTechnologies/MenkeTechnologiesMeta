#!/usr/bin/env bash
# For every workflow yml, pin that each job's `needs:` entries
# reference a real job name in the same workflow.
#
# `needs:` declares inter-job dependencies (job B runs after
# job A succeeds). If an entry references a job that doesn't
# exist:
#
#   - GitHub Actions REJECTS the workflow at upload time with
#     "Job 'B' depends on unknown job 'X'."
#   - The workflow vanishes from the Actions tab — same silent
#     failure mode as iter-68 (parse) and iter-82 (no runs-on).
#
# How needs-references go stale:
#
#   - Rename a job (`build:` → `build_and_test:`) without
#     updating downstream `needs: [build]`
#   - Delete an upstream job that other jobs depended on
#   - Copy a workflow from another repo and forget to rename
#     references that point at jobs from the source repo
#   - Typo: `needs: [biuld]` (mis-typed "build")
#
# Per GitHub's spec, `needs:` accepts:
#   - A single job name: `needs: build`
#   - A list of job names: `needs: [build, test]`
#   - A YAML list: `needs:\n  - build\n  - test`
#
# All three forms are handled.
#
# 90/90 workflow files green at iter-85 add — pure regression
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
    names = set(jobs.keys())
    bad = []
    for jn, job in jobs.items():
        if not isinstance(job, dict):
            continue
        needs = job.get("needs")
        if needs is None:
            continue
        if isinstance(needs, str):
            needs = [needs]
        if not isinstance(needs, list):
            continue
        for n in needs:
            if n not in names:
                bad.append(f"{jn}->{n}")
    print("OK" if not bad else "BAD:" + " ".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: ${output#BAD:}"
            n=$(echo "${output#BAD:}" | tr ' ' '\n' | grep -c .)
            bad=$((bad + n))
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $bad stale needs references"

[[ $ok -eq 1 ]] && exit 0 || exit 1
