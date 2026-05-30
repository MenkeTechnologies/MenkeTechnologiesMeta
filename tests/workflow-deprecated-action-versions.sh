#!/usr/bin/env bash
# For every .github/workflows/*.yml, pin that the first-party
# GitHub `actions/*` references use a major version that's
# still supported by GitHub. Catches:
#
#   actions/checkout@v1 / v2 / v3        — v3 deprecated 2024
#   actions/upload-artifact@v1 / v2 / v3   — v3 EOL Nov 2024
#   actions/download-artifact@v1 / v2 / v3 — v3 EOL Nov 2024
#   actions/cache@v1 / v2 / v3             — v3 deprecated 2024
#
# All three were retired because v3 relies on Node 16, which
# reached EOL in 2023. Once the runtime is dropped from the
# runner image, every workflow using a v3 reference fails at
# step time:
#
#   Error: This request has been automatically failed because
#   it uses a deprecated version of `actions/upload-artifact: v3`.
#
# Failure mode: workflows that haven't been touched for months
# suddenly start failing on the deprecation cutoff date.
# Without an early-warning gate, the breakage hits everyone
# simultaneously and creates a coordinated firefight.
#
# Required minimum versions (current as of 2026-05-30):
#   actions/checkout            >= v4
#   actions/upload-artifact     >= v4
#   actions/download-artifact   >= v4
#   actions/cache               >= v4   (added iter-140)
#
# Pinned-by-SHA references (no `@v...` tag, just a 40-char hex
# SHA) are PASSED — those are the most reproducible reference
# form per GitHub's security guidance. SHA pins can't be
# version-checked from the workflow alone; they're handled by
# workflow-actions-versions.sh (informational inventory).
#
# 360 first-party action references checked, 0 on deprecated
# major at iter-87 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Action → minimum supported major version.
declare -A MIN_VER=(
    [actions/checkout]=4
    [actions/upload-artifact]=4
    [actions/download-artifact]=4
    # actions/cache@v3 was deprecated alongside the other first-
    # party v3s (Node 16 EOL). v4 is the supported minimum since
    # 2024. Added at iter-140.
    [actions/cache]=4
)

checked_files=0
checked_uses=0
deprecated=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked_files=$((checked_files + 1))

    for action in "${!MIN_VER[@]}"; do
        min="${MIN_VER[$action]}"
        while IFS= read -r line; do
            checked_uses=$((checked_uses + 1))
            # Extract major version from `@vN` reference.
            ver=$(echo "$line" | grep -oE "$action@v[0-9]+" | head -1 | grep -oE '[0-9]+$')
            [[ -n "$ver" ]] || continue
            if [[ "$ver" -lt "$min" ]]; then
                echo "FAIL  $wf: $action@v$ver (deprecated; min supported is v$min)"
                deprecated=$((deprecated + 1))
                ok=0
            fi
        done < <(grep -E "$action@v[0-9]+" "$wf" 2>/dev/null || true)
    done
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked_files workflow files, $checked_uses first-party action references checked, $deprecated on deprecated major version"

[[ $ok -eq 1 ]] && exit 0 || exit 1
