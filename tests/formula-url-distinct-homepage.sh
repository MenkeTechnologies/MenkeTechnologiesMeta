#!/usr/bin/env bash
# For every Homebrew formula, pin that the `url` and
# `homepage` fields point at DIFFERENT URLs.
#
# The two fields serve distinct purposes:
#
#   url:       the location of the download artifact —
#              typically a release tarball at
#              https://github.com/<org>/<repo>/releases/
#              download/<tag>/<asset>.tar.gz
#
#   homepage:  the canonical project URL — typically the
#              repository root at
#              https://github.com/<org>/<repo>
#
# When the two collapse to the same URL, three things go
# wrong on the user-facing display:
#
#   1. `brew info <name>` shows two lines that look almost
#      identical. The reader has to compare character-by-
#      character to confirm they're the same — visual noise.
#   2. The formulae.brew.sh card renders two clickable
#      links pointing at the same place. One of the two
#      links is wasted (the click on either lands on the
#      same destination).
#   3. The SEO meta on formulae.brew.sh treats homepage as
#      the canonical project link for crawler purposes; if
#      it points at a release tarball download instead, the
#      page's "project home" link returns a 30MB .tar.gz
#      file to anyone who clicks it (browsers may even
#      start downloading it automatically).
#
# Drift introduction:
#   - Auto-bump scripts that derive homepage from url
#     instead of from the source's homepage field
#   - Hand-edit copying url into homepage during a refactor
#     and forgetting to revert one
#   - Template formula generator that uses the same variable
#     for both fields by default
#
# Detection: extract both fields via the canonical grep + sed
# pattern, compare for equality.
#
# Pairs with iter-77 (canonical url under MenkeTechnologies),
# iter-123 (binary release path), iter-98 (version match).
# Together: each URL field is canonical AND distinct.
#
# 10/10 formulas green at iter-159 add — pure regression
# floor.
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
collapsed=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue

    url=$(grep -m1 -oE '^\s+url *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    home=$(grep -m1 -oE '^\s+homepage *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')

    [[ -n "$url" && -n "$home" ]] || continue
    checked=$((checked + 1))

    if [[ "$url" == "$home" ]]; then
        echo "FAIL  $f: url and homepage point at same URL — $url"
        collapsed=$((collapsed + 1))
        ok=0
    else
        echo "PASS  $f: url and homepage distinct"
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $collapsed with collapsed url/homepage"

[[ $ok -eq 1 ]] && exit 0 || exit 1
