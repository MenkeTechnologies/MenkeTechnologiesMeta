#!/usr/bin/env bash
# For every Cargo.toml `repository` field, pin that the URL
# includes a path component beyond the host (not bare
# `https://github.com` or `https://github.com/`).
#
# Third member of the cargo URL path-component triad after
# iter-160 (homepage) and iter-161 (documentation). Same
# drift patterns apply:
#
#   1. PLACEHOLDER from cargo new template
#   2. ASPIRATIONAL ORG URL pointing at github.com homepage
#   3. URL TRUNCATION during refactor
#
# Canonical form (per iter-64 + iter-76):
#
#   repository = "https://github.com/MenkeTechnologies/<repo>"
#
# Which has `MenkeTechnologies/<repo>` (two-segment) path.
# Bare `https://github.com` would land users on github.com's
# homepage where they search-and-browse for any repo.
#
# Detection: strip `https?://` + host, check whether anything
# remains beyond a trailing `/`.
#
# Pairs with iter-64 (repository matches submodule dir),
# iter-108 (https://), iter-132 (no trailing slash).
# The repository URL discipline now spans FOUR gates:
#
#   iter-64:  matches submodule dir (canonical form)
#   iter-108: https:// scheme
#   iter-132: no trailing slash
#   iter-162: path component present (this gate)
#
# The cargo URL path-component triad (iter-160 + iter-161 +
# iter-162) now covers ALL THREE URL fields' bare-host
# regression floors.
#
# 26/26 crates with repository set green at iter-162 add —
# pure regression floor.
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
bare=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    repo=$(grep -m1 -E '^repository *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$repo" ]] || continue
    checked=$((checked + 1))

    path_part=$(echo "$repo" | sed -E 's|^https?://[^/]+||')
    if [[ -z "$path_part" || "$path_part" == "/" ]]; then
        echo "FAIL  $cargo: repository=$repo is bare-host (no path) — needs <org>/<repo> segments"
        bare=$((bare + 1))
        ok=0
    else
        echo "PASS  $cargo: repository=$repo"
    fi
done

echo "---"
echo "Summary: $checked repository URLs checked, $bare bare-host (no path)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
