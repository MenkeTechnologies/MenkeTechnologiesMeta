#!/usr/bin/env bash
# For every Cargo.toml, pin that the `description` field does
# NOT contain an `http://` or `https://` URL.
#
# crates.io renders the description as the crate's one-line
# tagline on the card view, in search results, and in IDE
# tooltips (e.g., rust-analyzer hovers on `extern crate foo`).
# A URL in the description fights for space with the actual
# content:
#
#   Bad:  "Statusline plugin — see https://example.com/docs"
#         (60 chars, URL crowds the meaningful prefix)
#
#   Good: "Statusline plugin with theme support"
#         (URL belongs in `documentation` / `repository` /
#         `homepage` fields, which crates.io already renders as
#         separate clickable links)
#
# The `description` field is the ONLY place crates.io renders
# raw prose. The three URL fields (homepage, repository,
# documentation) cover every URL surface — see iter-26
# (homepage convention), iter-63 (documentation = docs.rs/<name>),
# iter-64 (repository matches dir), iter-57 (URL triangle
# distinctness). A URL in `description` duplicates one of
# those slots in a less-clickable form (crates.io doesn't
# auto-linkify description text past the first 100 chars).
#
# Also catches descriptions accidentally containing markdown
# syntax (`[text](url)`) — the URL pattern matches inside the
# parens.
#
# 27/27 crates green at iter-94 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    desc=$(grep -m1 -E '^description *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$desc" ]] || continue
    checked=$((checked + 1))

    if echo "$desc" | grep -qE 'https?://'; then
        echo "FAIL  $cargo: description contains URL — \"$desc\""
        bad=$((bad + 1))
        ok=0
    else
        echo "PASS  $cargo: \"$desc\""
    fi
done

echo "---"
echo "Summary: $checked descriptions checked, $bad containing URLs"

[[ $ok -eq 1 ]] && exit 0 || exit 1
