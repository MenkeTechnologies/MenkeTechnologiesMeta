#!/usr/bin/env bash
# For every Cargo.toml `homepage` field, pin that the URL
# includes a path component (not bare `https://host` or
# `https://host/`).
#
# crates.io renders homepage as a clickable link on the crate
# card. A bare-host URL like `https://example.com` lands the
# user on a generic landing page that has NO relationship to
# the specific crate. Three classes of drift produce this:
#
#   1. Placeholder URL from a cargo new template that wasn't
#      updated. The template emits `https://example.com` as
#      a "fill in your URL here" hint; the user publishes
#      without changing it.
#
#   2. Aspirational org URL — the crate author intended to
#      eventually have a project page but pointed homepage
#      at the org's general site as a placeholder. The
#      crates.io card now shows the org page where users
#      expected the crate's specific page.
#
#   3. URL truncation during refactor — someone removed the
#      path portion intending to add a better one, then
#      forgot. The resulting bare-host URL has no
#      relationship to the crate.
#
# The org convention (iter-26): homepage points at either:
#
#   - https://menketechnologies.github.io/<repo>/  (GH Pages
#                                                   docs site)
#   - https://github.com/MenkeTechnologies/<repo>  (GitHub
#                                                   repo, for
#                                                   crates
#                                                   without
#                                                   docs/)
#
# Both forms include a path component (`<repo>` segment).
# Bare `https://github.com` or `https://menketechnologies.
# github.io/` (org-root) would be wrong — every crate's
# homepage points at the same place, defeating the purpose
# of a per-crate homepage.
#
# Detection: strip `https?://` + host, check whether anything
# remains. Trailing `/` alone counts as "no path" because
# `https://example.com/` and `https://example.com` are
# semantically equivalent.
#
# 26/26 crates with homepage set green at iter-160 add —
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

    home=$(grep -m1 -E '^homepage *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$home" ]] || continue
    checked=$((checked + 1))

    path_part=$(echo "$home" | sed -E 's|^https?://[^/]+||')
    if [[ -z "$path_part" || "$path_part" == "/" ]]; then
        echo "FAIL  $cargo: homepage=$home is bare-host (no path) — crate-specific URL required"
        bare=$((bare + 1))
        ok=0
    else
        echo "PASS  $cargo: homepage=$home"
    fi
done

echo "---"
echo "Summary: $checked homepage URLs checked, $bare bare-host (no path)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
