#!/usr/bin/env bash
# For every workflow yml top-level `name:` field, pin that
# the value is ≤ 80 characters.
#
# Why 80 chars:
#
#   - Actions tab sidebar (the workflow list shown on every
#     run summary): GitHub renders workflow names in a
#     fixed-width column. Names beyond ~80 chars truncate
#     with ellipsis — the distinguishing tail is hidden.
#   - PR check-run names: each check is "$workflow_name /
#     $job_name". When the workflow name eats 80+ of the
#     available char budget, the job name's column gets
#     truncated.
#   - Notification emails / Slack: failure-summary lines
#     embed the workflow name. Past 80 chars they wrap
#     awkwardly mid-name.
#   - Status badges: shields.io and GitHub's own badge
#     renderer use the workflow name as alt-text. Long
#     names produce wide badges that wrap or push other
#     README badges off-row.
#
# 80 chars matches the brew formula `desc` limit (iter-136)
# and the conventional terminal width. The two limits land
# together by coincidence but the underlying reason (fixed
# columns + readability) is the same.
#
# Detection: yaml.safe_load + len(name). Non-string names
# (rare YAML-shape issue) are silently passed.
#
# Pairs with iter-69 (workflow name presence). Iter-69 pins
# the field exists; iter-168 pins it doesn't overflow
# downstream display contexts.
#
# 90/90 workflow files green at iter-168 add — pure
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
long=0
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
    name = d.get("name", "")
    if not isinstance(name, str):
        print("OK")
        sys.exit()
    n = len(name)
    if n > 80:
        print(f"BAD:{n}:{name[:100]}")
    else:
        print("OK")
except Exception:
    print("PARSE_FAIL")
' "$wf")

    case "$output" in
        PARSE_FAIL)
            parse_fail=$((parse_fail + 1))
            ;;
        BAD:*)
            rest="${output#BAD:}"
            n="${rest%%:*}"
            name="${rest#*:}"
            echo "FAIL  $wf: name is $n chars (max 80) — \"$name\""
            long=$((long + 1))
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
echo "Summary: $checked workflows checked ($parse_fail delegated to iter-68), $long with name > 80 chars"

[[ $ok -eq 1 ]] && exit 0 || exit 1
