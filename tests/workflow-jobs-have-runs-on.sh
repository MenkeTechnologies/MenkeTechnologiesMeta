#!/usr/bin/env bash
# For every job in every .github/workflows/*.yml, pin that the
# job declares a `runs-on:` field.
#
# `runs-on` tells GitHub which runner image (or self-hosted
# label) to dispatch the job to. Without it, GitHub Actions
# REJECTS the workflow at upload time with:
#
#   The workflow is not valid. .github/workflows/foo.yml
#   (Line: N, Col: M): Required property is missing.
#
# Failure mode: the workflow disappears from the Actions tab
# entirely (same as iter-68's parse failures). Slightly less
# silent than empty-steps (iter-81) because the upload error
# fires immediately, but still requires the author to be
# watching the Actions tab to notice.
#
# Reusable workflow callers (`uses:` at job level) are exempted
# — they inherit the called workflow's runs-on per GitHub's own
# rule, so a job-level runs-on would be ignored anyway.
#
# Test enforces presence only, not value validity (iter-67
# already gates against deprecated runner images). A job with
# `runs-on: macos-latest` is good; `runs-on:` with no value is
# caught by iter-68's YAML parser (empty scalar parses as null
# which fails the GitHub Actions schema).
#
# 90/90 workflow files (across all jobs) green at iter-82 add
# — pure regression floor.
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
missing=0
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
    jobs = d.get("jobs", {})
    if not isinstance(jobs, dict):
        print("PARSE_FAIL")
        sys.exit()
    bad = []
    for name, job in jobs.items():
        if not isinstance(job, dict):
            continue
        if "uses" in job:
            continue
        if "runs-on" not in job:
            bad.append(name)
    print("OK" if not bad else "BAD:" + ",".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            jobs="${output#BAD:}"
            echo "FAIL  $wf: jobs without runs-on: $jobs"
            n=$(echo "$jobs" | tr ',' '\n' | wc -l | tr -d ' ')
            missing=$((missing + n))
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
echo "Summary: $checked workflows checked ($parse_fail unparseable delegated to iter-68), $missing jobs without runs-on"

[[ $ok -eq 1 ]] && exit 0 || exit 1
