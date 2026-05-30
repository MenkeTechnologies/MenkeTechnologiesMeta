#!/usr/bin/env bash
# For every submodule's docs/ directory that ships BOTH index.html
# AND report.html, pin that each cross-links the other.
#
# Catches the UX gap where a sibling doc exists but isn't reachable
# from its sibling — users on docs/index.html have no way to navigate
# to docs/report.html (the engineering report) without typing the
# URL. Real iter-44 case: strykelang/docs/index.html had links to
# reference.html / GitHub / crates.io / docs.rs in its breadcrumb
# but NOT to report.html (even though report.html itself linked back
# to index.html and reference.html). Asymmetric navigation = bad UX.
#
# Test enforces bidirectional pairing: if both files exist, each
# must contain a `href="<sibling>.html"` reference somewhere.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

# Include meta repo's own docs/
candidates=("./docs")
for p in "${paths[@]}"; do
    [[ -d "$p/docs" ]] && candidates+=("$p/docs")
done

init_count=${#candidates[@]}
if [[ $init_count -le 1 ]]; then
    echo "SKIP  no docs/ dirs initialized"
    exit 0
fi

checked=0
missing=0

for d in "${candidates[@]}"; do
    idx="$d/index.html"
    rpt="$d/report.html"
    # Only enforce pairing when BOTH siblings exist. A docs/ that ships
    # only one of the two doesn't need cross-linking enforcement.
    [[ -f "$idx" && -f "$rpt" ]] || continue
    checked=$((checked + 1))

    if ! grep -qE 'href="report\.html"' "$idx"; then
        echo "FAIL  $idx: no link to sibling report.html"
        missing=$((missing + 1))
        ok=0
    fi
    if ! grep -qE 'href="index\.html"' "$rpt"; then
        echo "FAIL  $rpt: no link to sibling index.html"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked docs/ pairs (index.html + report.html) checked, $missing missing a sibling link"

[[ $ok -eq 1 ]] && exit 0 || exit 1
