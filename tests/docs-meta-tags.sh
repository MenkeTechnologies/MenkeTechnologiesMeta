#!/usr/bin/env bash
# For every docs/index.html and docs/report.html across the umbrella
# (meta repo + submodules), pin that the required HTML meta tags
# are present and non-empty:
#
#   - <meta name="description" content="..."> — SEO + social previews
#   - <meta name="viewport" content="width=device-width, ..."> —
#     mobile rendering (without it, mobile browsers default to a
#     980px-wide viewport and zoom-out by ~3x, looking broken)
#
# A doc without `description` shows the URL slug in Google search
# results and Twitter/Slack/Discord card previews. A doc without
# `viewport` looks like a desktop page rendered at 33% zoom on
# every phone.
#
# Test verifies BOTH presence AND non-emptyness (a `<meta name=
# "description" content="">` empty-string form passes a naive grep
# but is functionally equivalent to absence).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

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

# Verifies a tag's content attribute is non-empty.
has_nonempty_meta() {
    local doc="$1" name="$2"
    # Match the meta tag, extract content="...". If the content is
    # empty or absent, return 1.
    local val
    val=$(grep -oE "<meta[^>]+name=\"$name\"[^>]+content=\"[^\"]+\"" "$doc" 2>/dev/null | head -1)
    [[ -n "$val" ]]
}

for d in "${candidates[@]}"; do
    for doc in "$d/index.html" "$d/report.html"; do
        [[ -f "$doc" ]] || continue
        checked=$((checked + 1))
        issues=""
        if ! has_nonempty_meta "$doc" "description"; then
            issues="$issues description"
        fi
        if ! has_nonempty_meta "$doc" "viewport"; then
            issues="$issues viewport"
        fi

        if [[ -z "$issues" ]]; then
            echo "PASS  $doc"
        else
            echo "FAIL  $doc: missing or empty meta tag(s):$issues"
            missing=$((missing + 1))
            ok=0
        fi
    done
done

echo "---"
echo "Summary: $checked docs/{index,report}.html files checked, $missing missing required meta tags"

[[ $ok -eq 1 ]] && exit 0 || exit 1
