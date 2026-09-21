#!/usr/bin/env bash
# Pin that each tier card on the docs/ landing page names every repo in
# that tier, so a card headlined "75" cannot list 54 repos.
#
# docs/index.html is the GitHub Pages front door, and unlike the pages
# beside it (inventions.html, inventory.html, the docs/<repo>/ mirrors)
# it has NO generator — nothing regenerates it and, until this gate,
# nothing checked it. It is hand-maintained, which is exactly why it
# rotted hardest: its Tier 1 card listed 54 of 75 repos with no ellipsis
# to say the list was partial, having silently stopped growing while
# thirteen language frontends, zdbview, zvcs and four engine pairs were
# added. Tier 6 named zpwr-license but not zpwr-account.
#
# The count in the card header comes from the same edit that should add
# the name, so a stale roster usually still shows the RIGHT total — the
# header said 75 while the body listed 54. Only comparing the names
# catches it.
#
# Tier membership is read from the README's [0x01] SUBMODULE MAP, which
# readme-submodule-map-complete.sh independently pins against
# .gitmodules; this gate therefore inherits a source already proven to
# match git.
#
# The rule is therefore: a card must either name every member OR say it
# is a sample, by ending its list with an ellipsis. That is the precise
# difference between the two shapes already on the page — the Tier 4
# card closes "…, revolver, gh_reveal, zsh-expand, …", which honestly
# advertises itself as a selection from 28, while the Tier 1 card
# presented 54 of 75 as if that were all of them. An ellipsis is the
# author's signal that the list is a sample; without one, the list reads
# as the roster and must be complete.
#
# One accommodation, deliberate: the Tier 2 card lists its per-service
# connectors by SERVICE rather than repo — "aws, azure, gcp, k8s" for
# stryke-aws, stryke-azure and so on — which is the more readable form
# for a 33-package family sharing one prefix. A `stryke-` member is
# therefore accepted when either the full repo name or its bare service
# suffix appears. Nothing else is prefix-stripped.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

page="docs/index.html"
readme="README.md"
if [[ ! -f "$page" || ! -f "$readme" ]]; then
    echo "SKIP  need both $page and $readme"
    exit 0
fi

checked=0
absent=0

map=$(awk '/^## \[0x01\] SUBMODULE MAP/{on=1} on && /^## \[0x02\]/{exit} on' "$readme")

for tier in 1 2 3 4 5 6 7; do
    # The card body: <h4><span class="n">N</span>Tier T — …</h4><p>BODY</p>
    body=$(perl -0777 -ne '
        if (/<h4><span class="n">[^<]*<\/span>\s*Tier '"$tier"'\s*[^<]*<\/h4>\s*<p>(.*?)<\/p>/s) {
            $b = $1; $b =~ s/<[^>]*>//g; print $b;
        }' "$page")

    if [[ -z "$body" ]]; then
        echo "FAIL  $page: no Tier $tier card found (or it has an empty body)"
        absent=$((absent + 1)); ok=0
        continue
    fi

    # An ellipsis declares the list a sample rather than a roster.
    if grep -qE '…|\.\.\.' <<< "$body"; then
        echo "SKIP  Tier $tier: card declares itself a partial list (ends in an ellipsis)"
        continue
    fi

    members=$(printf '%s\n' "$map" \
        | awk -v t="$tier" '
            $0 ~ "^### Tier " t " —" {on=1; next}
            on && /^### Tier /{exit}
            on && /^\|[[:space:]]*\[`/{
                if (match($0, /\[`[^`]+`\]/)) print substr($0, RSTART+2, RLENGTH-4)
            }')

    tier_missing=""
    for m in $members; do
        checked=$((checked + 1))
        if grep -qF -- "$m" <<< "$body"; then
            continue
        fi
        # Tier 2's connectors are written by service name, not repo name.
        if [[ "$m" == stryke-* ]] && grep -qE "(^|[^a-z-])${m#stryke-}([^a-z-]|$)" <<< "$body"; then
            continue
        fi
        tier_missing="$tier_missing $m"
        absent=$((absent + 1))
        ok=0
    done

    if [[ -z "$tier_missing" ]]; then
        echo "PASS  Tier $tier: card names every member"
    else
        echo "FAIL  Tier $tier: card omits:$tier_missing"
    fi
done

echo "---"
echo "Summary: $checked tier members checked, $absent unnamed on the docs/ landing page"

[[ $ok -eq 1 ]] && exit 0 || exit 1
