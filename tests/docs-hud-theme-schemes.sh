#!/usr/bin/env bash
# Every hud-theme.js shipped in a docs/ dir must expose the FULL
# canonical color-scheme catalog and keep its scheme table
# internally consistent.
#
# Why this gate exists: docs-static-deps-exist.sh proves the
# referenced CSS/JS assets *exist*, but nothing validated the
# *contents* of hud-theme.js. A docs/ copied from an older sibling
# repo that only defined 5 of the 8 schemes (missing crimson /
# toxic / vapor) published "successfully" — the page loaded, the
# asset resolved — but the scheme picker rendered a short menu with
# the newer schemes silently absent. That drift shipped undetected
# across ~200 doc pages. This gate closes that hole.
#
# Two invariants pinned:
#
#   1. Completeness. The canonical scheme set is DERIVED from the
#      fleet (the union of every SCHEME_ORDER across all shipped
#      hud-theme.js), not hardcoded. A file missing any canonical
#      scheme is flagged. This self-adjusts when a scheme is added
#      — as long as it is added everywhere. Add it to only one file
#      and every other file is (correctly) flagged as stale.
#
#   2. Internal consistency. SCHEME_ORDER (the array that drives the
#      picker) must match the keys COLOR_SCHEMES actually defines. A
#      scheme defined but not ordered never renders; one ordered but
#      not defined throws at runtime when the picker dereferences it.
#
# Scope mirrors docs-static-deps-exist.sh: each submodule's
# top-level docs/ plus the meta repo's own docs/. Nested/vendored
# copies regenerate from their source repo and are out of scope
# here. MenkeTechnologiesPublications is a private book repo, not a
# GH Pages site — skipped, same as the sibling gate.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# perl (never sed): pull the quoted names out of the SCHEME_ORDER array.
order_names() {
    perl -0777 -ne '
        if (/SCHEME_ORDER\s*=\s*\[(.*?)\]/s) {
            my $l = $1;
            while ($l =~ /'\''([^'\'']+)'\''/g) { print "$1\n" }
        }
    ' "$1"
}

# Gather the hud-theme.js files in scope.
paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

files=()
[[ -f "./docs/hud-theme.js" ]] && files+=("./docs/hud-theme.js")
for p in "${paths[@]}"; do
    [[ "$p" == MenkeTechnologiesPublications* ]] && continue
    [[ -f "$p/docs/hud-theme.js" ]] && files+=("$p/docs/hud-theme.js")
done

if [[ ${#files[@]} -eq 0 ]]; then
    echo "SKIP  no docs/hud-theme.js found (need git submodule update --init)"
    exit 0
fi

# Pass 1: derive the canonical scheme catalog = union of every SCHEME_ORDER.
declare -A canon=()
for f in "${files[@]}"; do
    while IFS= read -r name; do
        [[ -n "$name" ]] && canon["$name"]=1
    done < <(order_names "$f")
done
canon_n=${#canon[@]}
if [[ $canon_n -eq 0 ]]; then
    echo "FAIL  could not derive any scheme names from SCHEME_ORDER across ${#files[@]} files"
    exit 1
fi
canon_sorted=$(printf '%s\n' "${!canon[@]}" | sort | tr '\n' ' ')
echo "Canonical scheme catalog ($canon_n): $canon_sorted"
echo "---"

# Pass 2: check each file for completeness + internal consistency.
checked=0
bad=0
for f in "${files[@]}"; do
    checked=$((checked + 1))

    # Names listed in SCHEME_ORDER.
    declare -A ord=()
    ord_n=0
    while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        ord["$name"]=1
        ord_n=$((ord_n + 1))
    done < <(order_names "$f")

    # Number of scheme definitions (one `label:` per scheme block).
    def_n=$(grep -c '[[:space:]]label:' "$f")

    file_bad=0

    # (1) completeness: every canonical scheme present in this file.
    for c in "${!canon[@]}"; do
        if [[ -z "${ord[$c]:-}" ]]; then
            echo "FAIL  $f: missing canonical scheme '$c'"
            file_bad=1
        fi
    done

    # (2) definitions match order count (nothing defined-but-unordered
    #     or ordered-but-undefined by count).
    if [[ "$def_n" -ne "$ord_n" ]]; then
        echo "FAIL  $f: SCHEME_ORDER lists $ord_n schemes but COLOR_SCHEMES defines $def_n"
        file_bad=1
    fi

    # (3) each ordered scheme actually has a definition block.
    for o in "${!ord[@]}"; do
        if ! grep -qE "^[[:space:]]+${o}:[[:space:]]*\{" "$f"; then
            echo "FAIL  $f: '$o' is in SCHEME_ORDER but has no COLOR_SCHEMES definition"
            file_bad=1
        fi
    done

    if [[ $file_bad -eq 1 ]]; then
        bad=$((bad + 1))
        ok=0
    fi
    unset ord
done

echo "---"
echo "Summary: $checked hud-theme.js checked, $bad with scheme drift (canonical catalog = $canon_n schemes)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
