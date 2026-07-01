#!/usr/bin/env bash
# For every .github/workflows/*.yml, pin that the `on:` trigger
# list contains at least one known GitHub Actions event type.
#
# Iter-68 pins YAML parseability and iter-69 pins top-level
# `name:`. This gate pins TRIGGER VALIDITY: the workflow must
# actually be reachable by some event, otherwise it's another
# silent-no-op pattern (workflow exists, has jobs, has steps,
# but nothing ever fires it).
#
# YAML parser quirk: `on` is a YAML 1.1 boolean keyword that
# parses as `True`. So `on: push` becomes `{True: "push"}` in
# Python's safe_load output (yaml.SafeLoader honors the YAML 1.1
# spec). The gate has to look up the trigger under BOTH the
# string `"on"` and the boolean `True` to find it.
#
# Known event types (the canonical GitHub Actions event list):
#   push, pull_request, pull_request_target, workflow_dispatch,
#   workflow_call, workflow_run, schedule, release,
#   repository_dispatch, issue_comment, issues, label, milestone,
#   page_build, project, project_card, project_column, public,
#   pull_request_review, pull_request_review_comment,
#   registry_package, status, watch, merge_group, deployment,
#   deployment_status, create, delete, discussion,
#   discussion_comment, fork, gollum, check_run, check_suite
#
# A workflow with `on:` referencing only unknown events
# (e.g. a typo like `on: poosh` which parses as `{poosh: null}`)
# will never fire — silent no-op. This gate catches the typo
# at lint time.
#
# 90/90 workflow files green at iter-84 add — pure regression
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
KNOWN = {
    "push", "pull_request", "pull_request_target", "workflow_dispatch",
    "workflow_call", "workflow_run", "schedule", "release",
    "repository_dispatch", "issue_comment", "issues", "label", "milestone",
    "page_build", "project", "project_card", "project_column", "public",
    "pull_request_review", "pull_request_review_comment",
    "registry_package", "status", "watch", "merge_group", "deployment",
    "deployment_status", "create", "delete", "discussion",
    "discussion_comment", "fork", "gollum", "check_run", "check_suite",
}
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("PARSE_FAIL")
        sys.exit()
    # YAML 1.1 parses bare `on` as boolean True
    on = d.get("on", d.get(True))
    if on is None:
        print("NO_ON")
        sys.exit()
    if isinstance(on, str):
        triggers = {on}
    elif isinstance(on, list):
        triggers = set(on)
    elif isinstance(on, dict):
        triggers = set(on.keys())
    else:
        triggers = set()
    if triggers & KNOWN:
        print("OK")
    else:
        print("BAD:" + ",".join(sorted(str(t) for t in triggers)))
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        NO_ON)
            echo "FAIL  $wf: no \`on:\` trigger (workflow never fires)"
            bad=$((bad + 1))
            ok=0
            ;;
        BAD:*)
            t="${output#BAD:}"
            echo "FAIL  $wf: \`on:\` triggers ($t) are none of the known GitHub event types — workflow never fires"
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
echo "Summary: $checked workflow files ($parse_fail delegated to iter-68), $bad with invalid/missing on:"

[[ $ok -eq 1 ]] && exit 0 || exit 1
