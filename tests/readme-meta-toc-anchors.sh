#!/usr/bin/env bash
# Pin that every in-page anchor link in the META repo's own README.md
# points at a header that GitHub's slug algorithm actually produces.
#
# readme-toc-anchors.sh already does this, but ONLY for a hardcoded list
# of Tier 1 submodules (strykelang, zshrs, fusevm, …). Every readme-*
# gate in this directory walks the submodule paths from .gitmodules, so
# the meta repo's own README — the most-read document here, and the one
# GitHub renders on the org's umbrella repo — is checked by none of them.
# This gate closes that hole; the submodule sweep stays where it is.
#
# The failure this catches is silent by construction. A section is
# renamed to carry a new count — `### Tier 1 — Core (74)` becomes
# `### Tier 1 — Core (75)` when a repo is added — and the ToC entry plus
# the header badge keep pointing at `#tier-1--core-74`. Markdown still
# renders a perfectly normal-looking link; GitHub just lands the reader
# at the top of the page instead of the section. Nothing errors, so the
# only way it is ever noticed is someone clicking that exact link.
# That is precisely what happened: the tier-1 anchor went stale when the
# tier grew to 75 and survived until a manual audit caught it.
#
# GitHub's slug algorithm, matching readme-toc-anchors.sh exactly so the
# two gates cannot disagree about what a valid anchor is:
#   1. Lowercase.
#   2. Drop backslashes (markdown escapes: `\[0x01\]` -> `[0x01]`).
#   3. Drop anything not alphanumeric, underscore, space, or hyphen.
#   4. Spaces -> hyphens, one at a time (NO collapsing: `A — B` keeps
#      both hyphens-from-spaces around the dropped em dash -> `a--b`).
#   5. No leading/trailing trim — GitHub preserves those.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

readme="README.md"
if [[ ! -f "$readme" ]]; then
    echo "SKIP  no $readme at the meta repo root"
    exit 0
fi

slugify() {
    printf '%s\n' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | tr -d '\\' \
        | sed 's/[^a-z0-9_ -]//g' \
        | tr ' ' '-'
}

# Every header in the file, slugified, as a newline-delimited blob.
# grep -Fxq against the blob keeps this working on bash 3.2 (macOS),
# which has no associative arrays.
header_slugs=$(
    grep -E '^#{1,6} ' "$readme" | while IFS= read -r line; do
        text="${line#*' '}"
        slugify "$text"
    done
)

checked=0
broken=0

# `](#anchor)` — the markdown inline-link form. Covers both the ToC
# entries and the header badges, which link to the same slugs.
while IFS= read -r anchor; do
    [[ -z "$anchor" ]] && continue
    anchor="${anchor#'#'}"
    [[ -z "$anchor" ]] && continue
    checked=$((checked + 1))
    if grep -Fxq -- "$anchor" <<< "$header_slugs"; then
        echo "PASS  #$anchor"
    else
        echo "FAIL  $readme: anchor '#$anchor' matches no header (GitHub renders it as a jump to the top of the page)"
        broken=$((broken + 1))
        ok=0
    fi
done < <(grep -oE '\]\(#[^)]+\)' "$readme" | sed 's/^](//; s/)$//')

echo "---"
echo "Summary: $checked meta README anchors checked, $broken broken (no matching header)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
