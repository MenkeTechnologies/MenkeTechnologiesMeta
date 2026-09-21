#!/usr/bin/env bash
# Pin that the [0x01] SUBMODULE MAP in the meta README names exactly the
# submodules in .gitmodules — every one listed, none invented, in both
# directions.
#
# readme-tier-counts-consistent.sh proves the COUNTS agree. Counts alone
# cannot catch a swap: delete one row and add another and every badge,
# heading and total still balances while the map describes a repo that
# does not exist and omits one that does. This gate checks IDENTITIES.
#
# Two failure directions, with different consequences:
#
#   MISSING (in .gitmodules, absent from the map)
#     A repo was added with `git submodule add` and never written into
#     the table. It is then invisible in the README, and — because
#     bin/gen-ci-board derives its tier grouping by parsing this exact
#     section — it silently never appears on the published CI status
#     board either. A repo whose CI is never shown is a repo whose CI
#     nobody watches.
#
#   PHANTOM (in the map, absent from .gitmodules)
#     A repo was renamed or removed and the row outlived it. Every link
#     in that row 404s, and gen-ci-board asks the GitHub API about a
#     repo that is not there.
#
# Rows are matched on the link target rather than the label, since the
# label is a display string while `github.com/MenkeTechnologies/<name>`
# is what a reader actually follows. The map is the only section parsed;
# the intro paragraph name-drops many of the same repos in prose and
# must not be read as table rows.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

readme="README.md"
if [[ ! -f "$readme" || ! -f .gitmodules ]]; then
    echo "SKIP  need both $readme and .gitmodules at the repo root"
    exit 0
fi

# Submodule paths as git itself reads them.
declared=$(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | awk '{print $2}' | sort -u)
if [[ -z "$declared" ]]; then
    echo "SKIP  .gitmodules declares no submodule paths"
    exit 0
fi

# Repo names from the map's table rows. A row opens with the linked repo
# name: `| [`zshrs`](https://github.com/MenkeTechnologies/zshrs) | ... |`
listed=$(awk '/^## \[0x01\] SUBMODULE MAP/{on=1} on && /^## \[0x02\]/{exit} on' "$readme" \
    | grep -oE '^\|[[:space:]]*\[`[^`]+`\]\(https://github\.com/MenkeTechnologies/[A-Za-z0-9._-]+' \
    | sed 's|.*/||' \
    | sort -u)

checked=0
missing=0
phantom=0

while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    checked=$((checked + 1))
    if grep -Fxq -- "$p" <<< "$listed"; then
        echo "PASS  $p"
    else
        echo "FAIL  $p: declared in .gitmodules but has no row in [0x01] SUBMODULE MAP (invisible in the README and on the CI board)"
        missing=$((missing + 1))
        ok=0
    fi
done <<< "$declared"

while IFS= read -r r; do
    [[ -z "$r" ]] && continue
    if ! grep -Fxq -- "$r" <<< "$declared"; then
        echo "FAIL  $r: has a row in [0x01] SUBMODULE MAP but is not a submodule in .gitmodules (its links 404)"
        phantom=$((phantom + 1))
        ok=0
    fi
done <<< "$listed"

echo "---"
echo "Summary: $checked submodules checked, $missing missing from the map, $phantom phantom rows"

[[ $ok -eq 1 ]] && exit 0 || exit 1
