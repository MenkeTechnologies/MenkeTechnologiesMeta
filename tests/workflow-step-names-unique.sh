#!/usr/bin/env bash
# For every workflow yml, pin that within each job's `steps:`
# array, all step `name:` values are unique.
#
# Why this matters for CI usability:
#
#   - GitHub Actions UI renders each step's name as the
#     expandable section in the job log. Duplicate names cause
#     the UI to render `Step name (1)`, `Step name (2)`, etc. —
#     readable, but the LOG SEARCH function inside the Actions
#     UI matches all instances on a name query, so jumping to
#     "the step that failed" requires reading both. Worse, when
#     a workflow has 30 steps named "Build" (cargo-cult
#     template) and one fails, the failure-summary email says
#     `Step "Build" failed` — but doesn't say WHICH "Build."
#   - Step outputs are addressable by `${{ steps.<id>.outputs.X }}`
#     where <id> is the step's `id:` (NOT name). When `id:` is
#     omitted (most steps), the step is unaddressable from
#     downstream steps. If you do add an id and then add a name,
#     and the name is duplicated elsewhere, reading the workflow
#     becomes ambiguous: which step does the output reference?
#   - Re-run from a specific failed step: GitHub's "Re-run jobs"
#     UI uses step names + ids to identify the failure point.
#     Duplicate names degrade this UX to "which one of the
#     three identically-named steps were you trying to re-run?"
#
# Detection: within each job's steps array, collect step names,
# check for duplicates. Steps without a name field are skipped
# (their auto-generated names from the run/uses content can
# collide but that's a separate UX issue handled at the GitHub
# UI level).
#
# 90/90 workflow files green at iter-117 add — pure regression
# floor against accidental name duplication during template
# expansion.
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
dup_jobs=0
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
        if not isinstance(job, dict) or "uses" in job:
            continue
        names = []
        for step in job.get("steps", []) or []:
            if not isinstance(step, dict):
                continue
            nm = step.get("name")
            if nm:
                names.append(nm)
        dups = sorted({n for n in names if names.count(n) > 1})
        if dups:
            bad.append(f"{jn}: " + ", ".join(repr(d) for d in dups))
    print("OK" if not bad else "BAD:" + "; ".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: jobs with duplicate step names — ${output#BAD:}"
            dup_jobs=$((dup_jobs + 1))
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $dup_jobs files with duplicate step names"

[[ $ok -eq 1 ]] && exit 0 || exit 1
