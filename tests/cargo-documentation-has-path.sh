#!/usr/bin/env bash
# For every Cargo.toml `documentation` field, pin that the URL
# includes a path component beyond the host (not bare
# `https://docs.rs` or `https://docs.rs/`).
#
# Cargo-side mirror of iter-160 (homepage path). Same drift
# patterns apply to the documentation field:
#
#   - Placeholder URL from `cargo new` template
#   - Aspirational org URL pointing at docs.rs's homepage
#     instead of the specific crate's page
#   - URL truncation during refactor
#
# The canonical form (per iter-63) is:
#
#   documentation = "https://docs.rs/<crate-name>"
#
# Which has a `<crate-name>` path segment. A bare
# `https://docs.rs/` (org-root) would land users on docs.rs's
# homepage — search-and-browse for any crate, not specifically
# this one.
#
# Detection: strip `https?://` + host, check whether anything
# remains beyond a trailing `/`.
#
# Pairs with iter-63 (documentation == docs.rs/<name>),
# iter-108 (https://), iter-132 (no trailing slash),
# iter-160 (homepage path component). The documentation
# URL discipline now spans:
#
#   iter-63:  exact pattern docs.rs/<name>
#   iter-108: https:// scheme
#   iter-132: no trailing slash (vs homepage which HAS one)
#   iter-161: path component present (this gate)
#
# 11/11 crates with documentation set green at iter-161 add —
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

    doc=$(grep -m1 -E '^documentation *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$doc" ]] || continue
    checked=$((checked + 1))

    path_part=$(echo "$doc" | sed -E 's|^https?://[^/]+||')
    if [[ -z "$path_part" || "$path_part" == "/" ]]; then
        echo "FAIL  $cargo: documentation=$doc is bare-host (no crate path) — needs <crate-name> segment"
        bare=$((bare + 1))
        ok=0
    else
        echo "PASS  $cargo: documentation=$doc"
    fi
done

echo "---"
echo "Summary: $checked documentation URLs checked, $bare bare-host (no path)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
