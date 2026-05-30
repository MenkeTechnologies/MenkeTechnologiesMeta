#!/usr/bin/env bash
# For every Homebrew formula's `url` and `homepage` fields,
# pin that the URL includes a path component beyond the
# host (not bare `https://host` or `https://host/`).
#
# Brew-side mirror of the cargo URL path-component triad
# (iter-160 homepage, iter-161 documentation, iter-162
# repository).
#
# Same drift patterns apply to brew formulas:
#
#   1. PLACEHOLDER from a `brew create` template that wasn't
#      updated. The template may emit bare-host URLs as
#      "fill in here" hints.
#   2. ASPIRATIONAL ORG URL — homepage pointing at the
#      project's general site instead of the specific
#      release-or-repo page.
#   3. URL TRUNCATION during refactor.
#
# Canonical forms (per iter-77 + iter-123):
#
#   url      = "https://github.com/MenkeTechnologies/<repo>/
#               releases/download/<tag>/<asset>.tar.gz"
#   homepage = "https://github.com/MenkeTechnologies/<repo>"
#
# Both have paths beyond the host. Bare `https://github.com`
# would land users on github.com's homepage where they
# search for any project — not specifically the formula's
# target.
#
# Detection: strip `https?://` + host via sed, check whether
# anything remains beyond trailing `/`.
#
# Pairs with iter-77 (canonical url), iter-123 (binary
# release path), iter-159 (url ≠ homepage). The brew URL
# discipline now spans:
#
#   iter-77:  canonical github.com/MenkeTechnologies/ url
#   iter-123: url uses /releases/download/ path shape
#   iter-159: url ≠ homepage (distinct fields)
#   iter-163: url and homepage both have path component
#
# 20/20 url+homepage URLs green at iter-163 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
bare=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue

    url=$(grep -m1 -oE '^\s+url *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    home=$(grep -m1 -oE '^\s+homepage *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')

    for label in "url:$url" "homepage:$home"; do
        field="${label%%:*}"
        val="${label#*:}"
        [[ -n "$val" ]] || continue
        checked=$((checked + 1))

        path_part=$(echo "$val" | sed -E 's|^https?://[^/]+||')
        if [[ -z "$path_part" || "$path_part" == "/" ]]; then
            echo "FAIL  $f: $field=$val is bare-host (no path)"
            bare=$((bare + 1))
            ok=0
        else
            echo "PASS  $f: $field has path"
        fi
    done
done

echo "---"
echo "Summary: $checked URL fields checked, $bare bare-host (no path)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
