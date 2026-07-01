#!/usr/bin/env bash
# For every workflow yml with a `push:` trigger, pin that the
# trigger has at least one filter declared: `branches:`,
# `tags:`, `paths:`, `paths-ignore:`, or `branches-ignore:`.
#
# A bare `on: push` (or `on: { push: }` with no filter block)
# fires on EVERY push to EVERY ref in the repo: every feature
# branch, every personal fork branch pushed back, every dev
# branch a contributor doesn't realize triggers CI. Each push
# burns Actions minutes — and for org accounts with per-month
# limits, this drains the budget within days of a high-velocity
# week.
#
# The org pattern (visible across 90 workflow files) is:
#
#   on:
#     push:
#       branches: [main, master]
#     # OR
#     push:
#       tags: ['v*.*.*']
#     # OR (for docs-only push triggers)
#     push:
#       paths: ['docs/**']
#
# Each filter keeps CI bounded to the events that actually
# matter: main-branch validation, tag-triggered releases,
# docs deploy on docs changes.
#
# Detection: YAML parse the `on:` block (handling the YAML 1.1
# `on` → True quirk from iter-84). If `push:` is present:
#   - As a string scalar (`on: push`) → BARE, FAIL
#   - As an empty mapping (`on: { push: {} }`) → BARE, FAIL
#   - As a mapping with branches/tags/paths/*-ignore → OK
#
# 90/90 workflow files green at iter-103 add — pure regression
# floor against accidentally introducing an unfiltered push
# trigger that drains Actions minutes.
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
unfiltered=0
parse_fail=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    # Only lint workflows that actually run: GitHub runs a workflow only when
    # its `.github/workflows/` sits at a repository root. The meta root and every
    # submodule have a `.git` (dir or gitlink file); vendored/generated
    # third-party trees (tree-sitter `grammars/sources/*`, CMake `build/_deps/*`,
    # vendored CLAP libs, node_modules, …) had their `.git` stripped, so their
    # nested workflows never fire. Skip anything whose enclosing dir isn't a repo.
    repodir="${wf%/.github/workflows/*}"
    [[ -e "$repodir/.git" ]] || continue
    checked=$((checked + 1))

    output=$(python3 -c '
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
    if not isinstance(d, dict):
        print("PARSE_FAIL")
        sys.exit()
    on = d.get("on", d.get(True))
    if on is None:
        print("NO_PUSH")
        sys.exit()
    FILTERS = {"branches", "tags", "paths", "paths-ignore", "branches-ignore"}
    if isinstance(on, str):
        print("BARE" if on == "push" else "NO_PUSH")
    elif isinstance(on, list):
        print("BARE" if "push" in on else "NO_PUSH")
    elif isinstance(on, dict):
        push = on.get("push", "__NOT_PRESENT__")
        if push == "__NOT_PRESENT__":
            print("NO_PUSH")
        elif push is None:
            print("BARE")
        elif isinstance(push, dict):
            if any(k in push for k in FILTERS):
                print("OK")
            else:
                print("BARE")
        else:
            print("OK")
    else:
        print("OK")
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BARE)
            echo "FAIL  $wf: bare \`push\` trigger with no branches/tags/paths filter — fires on every push, drains Actions minutes"
            unfiltered=$((unfiltered + 1))
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
echo "Summary: $checked workflow files checked ($parse_fail delegated to iter-68), $unfiltered with unfiltered push trigger"

[[ $ok -eq 1 ]] && exit 0 || exit 1
