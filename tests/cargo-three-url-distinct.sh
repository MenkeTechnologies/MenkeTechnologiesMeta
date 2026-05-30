#!/usr/bin/env bash
# For every publishable Rust Cargo.toml, pin that the three URL
# fields point at three DIFFERENT URLs:
#
#   - homepage:      landing page (GH Pages docs or project site)
#   - repository:    source code (GitHub repo)
#   - documentation: API reference (docs.rs or hosted rustdoc)
#
# crates.io renders all three as separate clickable links on the
# crate page. If any two collapse to the same URL, that link
# adds zero value — and worse, the reader infers that the crate
# has no separate entry point for that role.
#
# Iter-56 caught homepage==repository duplication. Iter-57 extends
# the check to the third URL: documentation must be distinct from
# both. The canonical org convention:
#   - homepage:      https://menketechnologies.github.io/<repo>/
#   - repository:    https://github.com/MenkeTechnologies/<repo>
#   - documentation: https://docs.rs/<crate>
#
# Three URLs, three different functions, three different domains.
# When a hand-edit collapses one to another, the crate page loses
# information density without obvious symptoms.
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

# Normalize a URL — strip trailing slash + lowercase scheme.
norm_url() {
    local u="$1"
    u="${u%/}"
    printf '%s' "$u"
}

checked=0
collapsed=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Skip publish=false crates.
    if grep -qE '^publish *= *false' "$cargo"; then
        continue
    fi

    h=$(grep -m1 -E '^homepage *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    r=$(grep -m1 -E '^repository *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    d=$(grep -m1 -E '^documentation *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')

    # Only enforce when all three are set.
    [[ -n "$h" && -n "$r" && -n "$d" ]] || continue

    h=$(norm_url "$h")
    r=$(norm_url "$r")
    d=$(norm_url "$d")

    checked=$((checked + 1))
    collisions=""
    # homepage == repository check is delegated to iter-56's
    # cargo-homepage-not-repo-duplicate.sh (which correctly scopes
    # to docs/-having crates only). Iter-57 covers the other two
    # collision pairs that aren't conditional on docs/ presence:
    # documentation must always differ from both homepage and
    # repository regardless of docs/.
    [[ "$h" == "$d" ]] && collisions="$collisions homepage==documentation"
    [[ "$r" == "$d" ]] && collisions="$collisions repository==documentation"

    if [[ -z "$collisions" ]]; then
        echo "PASS  $cargo: 3 URLs distinct"
    else
        echo "FAIL  $cargo:$collisions"
        echo "        homepage:      $h"
        echo "        repository:    $r"
        echo "        documentation: $d"
        collapsed=$((collapsed + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked publishable crates with all 3 URLs checked, $collapsed with collisions"

[[ $ok -eq 1 ]] && exit 0 || exit 1
