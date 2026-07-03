#!/usr/bin/env bash
# For every workflow yml, pin that step `id:` fields are:
#   1. Valid identifiers: ^[A-Za-z_][A-Za-z0-9_-]*$
#      (per GitHub Actions context-reference spec)
#   2. Unique within each job
#
# Why this matters:
#
# Step ids are the addressable handles for cross-step
# references inside a job:
#
#   - `${{ steps.<id>.outputs.X }}`         output reads
#   - `${{ steps.<id>.outcome }}`           per-step status
#   - `${{ steps.<id>.conclusion }}`        per-step result
#   - `if: steps.<id>.outputs.foo == 'bar'` conditional gates
#
# When an id is INVALID (contains spaces, starts with a digit,
# or has chars outside `[A-Za-z0-9_-]`):
#
#   - GitHub Actions silently ignores the id in some contexts
#     (the step still runs, but downstream `steps.<id>` lookups
#     resolve to null — without an error).
#   - The expression evaluator's parser treats invalid chars
#     as expression-syntax delimiters, producing parse errors
#     ONLY when the reference is evaluated.
#   - Result: a downstream step that gates on
#     `steps.bad id.outputs.X` evaluates to empty string,
#     which then compares as false in a boolean context — the
#     gate silently flips behavior without raising.
#
# When ids are DUPLICATE within a job:
#
#   - Last-write-wins for outputs/outcome/conclusion: the
#     final step with that id determines what
#     `${{ steps.<id>.* }}` resolves to. Earlier same-id
#     steps' outputs are inaccessible.
#   - A subtle correctness bug: an early "checkout" step's
#     `steps.checkout.outcome` is hidden by a later equally-
#     named step. Conditional logic that depends on the
#     earlier checkout silently uses the later one's
#     conclusion.
#
# Detection: walk every step's id field, validate against
# identifier regex AND check uniqueness within the job.
#
# 90/90 workflow files green at iter-118 add — pure regression
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
problems=0
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
    issues = []
    for jn, job in jobs.items():
        if not isinstance(job, dict) or "uses" in job:
            continue
        ids = []
        for step in job.get("steps", []) or []:
            if not isinstance(step, dict):
                continue
            sid = step.get("id")
            if sid is None:
                continue
            if not isinstance(sid, str) or not ID_RE.match(sid):
                issues.append(f"{jn}: invalid id \"{sid}\"")
            ids.append(sid)
        dups = sorted({n for n in ids if ids.count(n) > 1})
        if dups:
            issues.append(f"{jn}: duplicate ids " + ", ".join(repr(d) for d in dups))
    print("OK" if not issues else "BAD:" + " | ".join(issues))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: ${output#BAD:}"
            problems=$((problems + 1))
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $problems with invalid/duplicate step ids"

[[ $ok -eq 1 ]] && exit 0 || exit 1
