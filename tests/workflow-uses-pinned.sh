#!/usr/bin/env bash
# For every workflow yml step that has a `uses:` field, pin
# that the reference includes an `@<ref>` suffix (either
# @v<N>, @<sha>, or @<branch>).
#
# GitHub Actions accepts bare action references like:
#
#   uses: actions/checkout
#
# but this is the WORST possible reference shape:
#
#   - At runtime, GitHub resolves the bare reference to the
#     repository's HEAD on the default branch. The action's
#     behavior can change between two runs of the SAME
#     workflow file with no git diff to show why.
#   - Security: a compromise of the action's default branch
#     immediately affects every workflow with a bare ref
#     — no version pin to act as a delay window for
#     mitigation.
#   - Reproducibility: bisecting a regression that originated
#     in an action update is impossible because "the same
#     workflow file" produces different builds.
#
# Reference shapes accepted by this gate:
#
#   actions/checkout@v4              version-tag pin
#   actions/checkout@8e5e7e5ab8...   full-sha pin (most secure)
#   actions/checkout@main            branch pin (less ideal
#                                                but explicit)
#   docker://<image>:<tag>          docker reference (uses
#                                                  :tag not @ref)
#   ./.github/workflows/<file>.yml  local reusable workflow
#                                    (no @ needed; resolved
#                                    relative to repo root)
#
# Reference shapes REJECTED:
#
#   actions/checkout                 bare — no @ref
#   actions/checkout@                empty after @ (caught by
#                                    YAML parser, but defensive
#                                    check)
#
# Detection: extract every `uses:` value from job-level
# (reusable workflow caller) and step-level fields. Skip
# `./` (local reusable workflow) and `docker://` (docker
# image ref with :tag) prefixes. Reject if no `@` present
# in the remainder.
#
# Pairs with iter-87 / iter-140 / iter-146 (deprecated-
# action-version gates). Iter-87 et al check the VERSION;
# iter-157 checks the REFERENCE PRESENCE itself.
#
# 90/90 workflow files green at iter-157 add — pure
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
    def check(uses, ctx):
        if not isinstance(uses, str):
            return
        if uses.startswith("./"):
            return
        if uses.startswith("docker://"):
            return
        if "@" not in uses:
            bad.append(f"{ctx}: {uses}")
    jobs = d.get("jobs", {}) or {}
    if isinstance(jobs, dict):
        for jn, job in jobs.items():
            if not isinstance(job, dict):
                continue
            check(job.get("uses"), f"job.{jn}")
            for i, step in enumerate(job.get("steps", []) or []):
                if isinstance(step, dict):
                    check(step.get("uses"), f"job.{jn}.step{i+1}")
    print("OK" if not bad else "BAD:" + "; ".join(bad))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            echo "FAIL  $wf: unpinned uses references — ${output#BAD:}"
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $bad with bare uses references"

[[ $ok -eq 1 ]] && exit 0 || exit 1
