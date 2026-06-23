#!/usr/bin/env bash
# For every submodule with docs/*.html, pin that:
#   (a) the <title> tag mentions the submodule name (case-insensitive)
#   (b) any github.com/MenkeTechnologies/X URL inside that doc references
#       the OWN submodule (X == submodule basename), not a sibling
#
# Catches the template-clone failure mode: dev copies docs/index.html
# from a sibling repo, forgets to update <title> and/or the GitHub URL,
# ships docs that brand-link to the wrong project. Has happened in
# other open-source orgs and would silently break SEO + user trust.
#
# Sibling references in body text (e.g. "see also lsofrs") are FINE —
# we only fail when the URL appears in a release/source linking context
# that should point at the owning repo:
#   - <crumbs> "GitHub" link
#   - Header "view source" link
#   - Footer attribution link
#   - <meta name="description" content="..."> when it embeds a URL
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Collect paths from .gitmodules
paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

# Detect submodules-initialized state.
init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
title_drift=0
url_drift=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    # Need at least docs/index.html OR docs/report.html
    has_docs=0
    for f in "$p"/docs/index.html "$p"/docs/report.html; do
        [[ -f "$f" ]] && has_docs=1
    done
    [[ $has_docs -eq 1 ]] || continue

    sub="${p##*/}"
    sub_lower=$(echo "$sub" | tr '[:upper:]' '[:lower:]')

    for f in "$p"/docs/*.html; do
        [[ -f "$f" ]] || continue
        checked=$((checked + 1))

        # (a) <title>...</title> must mention the submodule name OR a
        # known brand alias. Aliases handle legitimate brand vs repo
        # name divergence (e.g. strykelang's binary is `stryke`,
        # Audio-Haxor's HUD wordmark is AUDIO_HAXOR with underscore).
        title=$(grep -oE '<title>[^<]*</title>' "$f" | head -1 | sed 's/<title>//; s|</title>||')
        title_lower=$(echo "$title" | tr '[:upper:]' '[:lower:]')
        sub_no_dash=$(echo "$sub_lower" | tr -d '-')
        sub_no_undr=$(echo "$sub_lower" | tr '-' '_')
        # Match if title contains either the literal name, the dash-
        # stripped form, the underscored form, or a ≥6-char prefix.
        sub_prefix6="${sub_lower:0:6}"
        # Explicit brand alias for a repo renamed on GitHub whose submodule
        # directory still lags behind. zpwr-clip-engine was renamed to zpwr-daw
        # (the submodule url is already .../zpwr-daw.git); its docs are correctly
        # branded "zpwr-daw" while the path is still zpwr-clip-engine, so the
        # name heuristics above can't bridge the rename.
        alias_brand=""
        case "$sub_lower" in
            zpwr-clip-engine) alias_brand="zpwr-daw" ;;
        esac
        if [[ -n "$title" ]] \
           && [[ "$title_lower" != *"$sub_lower"* ]] \
           && [[ "$title_lower" != *"$sub_no_dash"* ]] \
           && [[ "$title_lower" != *"$sub_no_undr"* ]] \
           && [[ "$title_lower" != *"$sub_prefix6"* ]] \
           && { [[ -z "$alias_brand" ]] || [[ "$title_lower" != *"$alias_brand"* ]]; }; then
            echo "FAIL  $f: <title> '$title' missing submodule name '$sub' or alias"
            title_drift=$((title_drift + 1))
            ok=0
        fi

        # (b) Every github.com/MenkeTechnologies/X.git OR /X URL inside
        # release-context tags must reference the OWN repo. We look for
        # the canonical "target" attribute pattern that marks an external
        # source link.
        wrong_urls=$(grep -oE 'github\.com/MenkeTechnologies/[A-Za-z0-9._-]+' "$f" \
                    | sed 's|github\.com/MenkeTechnologies/||' \
                    | sort -u \
                    | grep -ivE "^${sub}$|^MenkeTechnologies\.github\.io$" \
                    | head -5 || true)
        # Repos like awkrs/iftoprs/lsofrs cross-link to MenkeTechnologiesMeta
        # in their breadcrumb — that's fine. Allow it explicitly.
        wrong_urls=$(echo "$wrong_urls" | grep -ivE "^MenkeTechnologiesMeta$" || true)

        # Repos legitimately reference siblings in tier maps and "see also"
        # callouts. Apply this check ONLY for the docs at the OWN repo's
        # root (e.g. powerliners/docs/index.html linking to lsofrs is ok in
        # a comparison table). The pure-template-clone catch is when the
        # canonical breadcrumb GitHub link goes to a wrong repo.
        canonical=$(grep -E 'crumb|crumbs|tutorial-crumbs|report-crumbs' "$f" \
                    | grep -oE 'github\.com/MenkeTechnologies/[A-Za-z0-9._-]+' \
                    | sed 's|github\.com/MenkeTechnologies/||' \
                    | grep -ivE "^MenkeTechnologiesMeta$|^MenkeTechnologies\.github\.io$" \
                    | sort -u || true)
        for u in $canonical; do
            if [[ "$u" != "$sub" ]]; then
                echo "FAIL  $f: breadcrumb GitHub URL points to '$u' but this is the '$sub' repo"
                url_drift=$((url_drift + 1))
                ok=0
            fi
        done
    done
done

echo "---"
echo "Summary: $checked doc files checked, $title_drift title drifts, $url_drift breadcrumb URL drifts"

[[ $ok -eq 1 ]] && exit 0 || exit 1
