#!/usr/bin/env bash
# For every workflow yml `env:` block (at workflow top, job
# level, or step level), pin that every key matches the
# canonical UPPER_SNAKE_CASE pattern:
#
#   ^[A-Z_][A-Z0-9_]*$
#
# Why this matters:
#
#   - POSIX env var convention: uppercase letters, underscores,
#     digits (not as first char). Mixed-case env vars like
#     `myVar` work in bash but break in dash, busybox sh, and
#     some Docker entrypoints that expect POSIX-strict
#     scanning.
#   - Reading downstream: a step `run: echo "$myVar"` works in
#     bash but `printf "%s" "$myVar"` in a POSIX-strict shell
#     fails — and the failure looks like "var is unset" rather
#     than "var name is malformed."
#   - Cross-platform consistency: GitHub Actions normalizes
#     env var names case-sensitively on Linux/macOS but
#     case-insensitively on Windows. `myVar` and `myvar` are
#     the same variable on Windows but different on Linux —
#     subtle bugs when matrix-tested across OSes.
#   - Reading discipline: a workflow reviewer scanning for
#     `RUST_BACKTRACE` doesn't expect `rust_backtrace` to
#     also affect the build. Forced uppercase eliminates the
#     reviewer's "is this the same var with different
#     casing?" cognitive load.
#
# Detection: walk every env block (workflow-level, job-level,
# step-level), check each key against ^[A-Z_][A-Z0-9_]*$.
#
# The 90/90 workflows green at iter-144 add demonstrate this
# convention is already followed consistently — the gate
# pins it against future drift (a contributor writing
# `gitToken: ${{ secrets.GH_TOKEN }}` would be caught at PR
# review).
#
# Pure regression floor.
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
import sys, yaml, re
PAT = re.compile(r"^[A-Z_][A-Z0-9_]*$")
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("PARSE_FAIL")
        sys.exit()
    bad = []
    def check(block, location):
        if not isinstance(block, dict):
            return
        for k in block.keys():
            if not isinstance(k, str):
                continue
            if not PAT.match(k):
                bad.append(f"{location}.{k}")
    check(d.get("env"), "workflow.env")
    jobs = d.get("jobs", {}) or {}
    if isinstance(jobs, dict):
        for jn, job in jobs.items():
            if not isinstance(job, dict):
                continue
            check(job.get("env"), f"job.{jn}.env")
            for i, step in enumerate(job.get("steps", []) or []):
                if not isinstance(step, dict):
                    continue
                check(step.get("env"), f"job.{jn}.step{i+1}.env")
    print("OK" if not bad else "BAD:" + "; ".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: non-UPPER_SNAKE env keys — ${output#BAD:}"
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $bad with non-uppercase env vars"

[[ $ok -eq 1 ]] && exit 0 || exit 1
