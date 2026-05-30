#!/usr/bin/env bash
# For every submodule docs/*.html (and the meta repo's own docs/),
# pin that each `<link rel="stylesheet" href="...">` and
# `<script src="...">` with a relative URL resolves to a file that
# actually exists next to the doc.
#
# Catches the failure mode where a doc references a CSS/JS file
# that was removed (e.g., `hud-static.css` → `hud-shared.css`
# rename without updating consumers), or a developer copy-pastes
# a docs/index.html from a sibling repo without copying its
# co-located CSS/JS dependencies.
#
# When the missing file is requested by a browser, GitHub Pages
# returns 404 for the asset and the page renders unstyled — the
# `docs/` is published "successfully" but visually broken.
#
# External (https://) URLs are skipped — those are CDN-hosted
# (Google Fonts, etc.) and not the meta repo's responsibility to
# validate.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

# Add the meta repo's own docs/ — it ships docs/index.html and
# docs/report.html that reference hud-static.css + hud-theme.js.
candidates=()
candidates+=("./docs")
for p in "${paths[@]}"; do
    [[ -d "$p/docs" ]] && candidates+=("$p/docs")
done

init_count=${#candidates[@]}
if [[ $init_count -le 1 ]]; then
    echo "SKIP  no docs/ directories initialized (need git submodule update --init)"
    exit 0
fi

checked=0
missing=0

for d in "${candidates[@]}"; do
    for doc in "$d"/*.html; do
        [[ -f "$doc" ]] || continue
        checked=$((checked + 1))
        # Extract stylesheet hrefs.
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            case "$ref" in https://*|http://*|//*) continue ;; esac
            if [[ ! -f "$d/$ref" ]]; then
                echo "FAIL  $doc: stylesheet href='$ref' missing in $d/"
                missing=$((missing + 1))
                ok=0
            fi
        done < <(grep -oE 'rel="stylesheet"[^>]*href="[^"]+"' "$doc" | sed -E 's/.*href="([^"]+)".*/\1/')
        # Extract script srcs.
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            case "$ref" in https://*|http://*|//*) continue ;; esac
            if [[ ! -f "$d/$ref" ]]; then
                echo "FAIL  $doc: script src='$ref' missing in $d/"
                missing=$((missing + 1))
                ok=0
            fi
        done < <(grep -oE 'script[^>]+src="[^"]+"' "$doc" | sed -E 's/.*src="([^"]+)".*/\1/')
    done
done

echo "---"
echo "Summary: $checked HTML docs checked across $((init_count)) directories, $missing with broken static dependencies"

[[ $ok -eq 1 ]] && exit 0 || exit 1
