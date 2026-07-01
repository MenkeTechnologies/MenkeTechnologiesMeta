#!/usr/bin/env bash
# For every workflow yml that declares a `concurrency:` block
# (either at the workflow top level or inside a job), pin that
# the block contains a `group:` field.
#
# GitHub Actions' concurrency block schema requires the
# `group:` key. Without it, GitHub Actions REJECTS the
# workflow at upload time with:
#
#   The workflow is not valid. .github/workflows/foo.yml
#   (Line: N, Col: M): The 'group' property is required.
#
# Same failure mode as iter-82 (missing runs-on): workflow
# vanishes from the Actions tab entirely. PR checks missing
# without annotation.
#
# The other concurrency keys are OPTIONAL:
#   - cancel-in-progress: false (default)
#
# But `group:` is the IDENTIFIER for the concurrency lane.
# Without it, GitHub can't determine which runs to serialize
# against which others. The schema reflects that requirement.
#
# Drift introduction:
#   - Hand-edit deleting the group line during a
#     concurrency-tweak (e.g., flipping cancel-in-progress
#     and accidentally deleting the line above)
#   - Copy-paste from a template that had `concurrency:
#     ${{ github.workflow }}` as a SHORT-FORM (string, not
#     mapping) and then converting to mapping form without
#     restoring the group key
#   - YAML anchor expansion that drops the group field
#
# Detection: walk both workflow-top-level `concurrency` and
# every job's `concurrency`. When the value is a mapping (vs
# a bare string short-form, which IS the group identifier
# directly), check for the `group` key.
#
# 0/90 workflows currently declare concurrency at all (the
# umbrella convention is to NOT use concurrency blocks). But
# any future addition will be schema-checked at lint time
# before the workflow vanishes from Actions tab.
#
# 90/90 workflow files green at iter-139 add — pure regression
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
    bad = []
    # Top-level concurrency.
    c = d.get("concurrency")
    if isinstance(c, dict) and "group" not in c:
        bad.append("top-level concurrency missing `group` key")
    # Job-level concurrency.
    jobs = d.get("jobs", {}) or {}
    if isinstance(jobs, dict):
        for jn, job in jobs.items():
            if not isinstance(job, dict):
                continue
            jc = job.get("concurrency")
            if isinstance(jc, dict) and "group" not in jc:
                bad.append(f"job `{jn}` concurrency missing `group` key")
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
    -o -path '*/build/_deps/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $bad with concurrency block lacking group key"

[[ $ok -eq 1 ]] && exit 0 || exit 1
