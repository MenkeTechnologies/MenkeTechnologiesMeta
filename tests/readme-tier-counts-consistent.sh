#!/usr/bin/env bash
# Pin that the meta README states ONE submodule count per tier, in all
# three places it is written, and that the tiers add up to .gitmodules.
#
# The same number is repeated four times over:
#
#   1. the header badge        `badge/tier_1-75_core`
#   2. the section heading     `### Tier 1 — Core (75)`
#   3. the rows in that tier's table (one per repo)
#   4. the total badge         `badge/submodules-190`, and .gitmodules
#
# Adding a submodule means touching all of them. Whichever is forgotten
# goes stale silently, because each is plausible on its own — a reader
# has no way to tell 74 from 75 without counting the table by hand.
# This is not hypothetical: the tier-1 badge sat at 74 while the heading
# and its 75 table rows had already moved on, and it took a manual audit
# to spot. The badge is the likeliest to rot, since it lives 60 lines
# above the table it describes.
#
# The tier tables are also the CI status board's source of truth —
# bin/gen-ci-board derives its tier grouping by parsing the [0x01]
# SUBMODULE MAP section — so a row missing here silently drops that repo
# from the published board as well.
#
# Checks, per tier: badge == heading == row count. Then across tiers:
# the sum == the submodules badge == the number of [submodule] blocks in
# .gitmodules. readme-submodule-map-complete.sh checks the row IDENTITIES
# against .gitmodules; this gate checks the COUNTS agree with each other.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

readme="README.md"
if [[ ! -f "$readme" || ! -f .gitmodules ]]; then
    echo "SKIP  need both $readme and .gitmodules at the repo root"
    exit 0
fi

checked=0
bad=0
sum=0

# The [0x01] SUBMODULE MAP section only — later sections repeat tier
# names (the [0x08] disk-footprint table) and must not be counted.
map=$(awk '/^## \[0x01\] SUBMODULE MAP/{on=1} on && /^## \[0x02\]/{exit} on' "$readme")

for tier in 1 2 3 4 5 6 7; do
    heading=$(printf '%s\n' "$map" | grep -E "^### Tier $tier —" | head -1)
    [[ -z "$heading" ]] && continue

    checked=$((checked + 1))

    # `### Tier 1 — Core (75)` -> 75 (last parenthesised number).
    h_count=$(printf '%s' "$heading" | grep -oE '\(([0-9]+)\)[[:space:]]*$' | grep -oE '[0-9]+')
    # `badge/tier_1-75_core` -> 75
    b_count=$(grep -oE "badge/tier_${tier}-[0-9]+" "$readme" | head -1 | grep -oE '[0-9]+$')
    # Repo rows inside this tier's table: `| [`name`](url) | description |`
    r_count=$(printf '%s\n' "$map" \
        | awk -v t="$tier" '
            $0 ~ "^### Tier " t " —" {on=1; next}
            on && /^### Tier /{exit}
            on && /^\|[[:space:]]*\[`/{n++}
            END{print n+0}')

    if [[ -z "$h_count" || -z "$b_count" ]]; then
        echo "FAIL  Tier $tier: could not read a count (heading='$h_count' badge='$b_count')"
        bad=$((bad + 1)); ok=0
        continue
    fi

    sum=$((sum + r_count))

    if [[ "$h_count" == "$b_count" && "$b_count" == "$r_count" ]]; then
        echo "PASS  Tier $tier: badge=$b_count heading=$h_count rows=$r_count"
    else
        echo "FAIL  Tier $tier: badge=$b_count heading=$h_count rows=$r_count — these must agree"
        bad=$((bad + 1)); ok=0
    fi
done

# ---------------------------------------------------------------- total
checked=$((checked + 1))
gm_count=$(git config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null | wc -l | tr -d ' ')
total_badge=$(grep -oE 'badge/submodules-[0-9]+' "$readme" | head -1 | grep -oE '[0-9]+$')

if [[ -z "$total_badge" ]]; then
    echo "FAIL  total: no \`badge/submodules-<n>\` badge found in $readme"
    bad=$((bad + 1)); ok=0
elif [[ "$sum" == "$total_badge" && "$total_badge" == "$gm_count" ]]; then
    echo "PASS  total: tier rows=$sum badge=$total_badge .gitmodules=$gm_count"
else
    echo "FAIL  total: tier rows=$sum badge=$total_badge .gitmodules=$gm_count — these must agree"
    bad=$((bad + 1)); ok=0
fi

echo "---"
echo "Summary: $checked tier counts checked, $bad disagreeing across badge/heading/table"

[[ $ok -eq 1 ]] && exit 0 || exit 1
