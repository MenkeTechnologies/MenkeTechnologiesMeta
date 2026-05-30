#!/usr/bin/env bash
# For every Rust submodule README that displays a shields.io
# crates.io badge, pin that the badge URL's crate-name path component
# matches the Cargo.toml package name.
#
# Catches the failure mode where a crate is renamed (or a README is
# copy-pasted from a sibling crate without retargeting the badge URL).
# The badge image still renders — shields.io returns "crate not
# found" with the same SVG shape — but it now displays the wrong
# crate's data. Users clicking the badge are sent to the WRONG
# crates.io page. Hard to spot visually since the badge looks valid.
#
# Badge URL shapes covered:
#   https://img.shields.io/crates/v/<name>          (version)
#   https://img.shields.io/crates/d/<name>          (downloads)
#   https://img.shields.io/crates/l/<name>          (license)
#   https://img.shields.io/crates/dr/<name>/<ver>   (download for ver)
#   img.shields.io/crates/...                       (no-scheme form)
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
mismatched=0
no_badge=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -f "$p/README.md" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    pkg=$(awk '/^\[package\]/{in_p=1} in_p && /^name *= *"/{match($0,/"[^"]*"/); print substr($0,RSTART+1,RLENGTH-2); exit}' "$cargo")
    [[ -n "$pkg" ]] || continue

    # Extract every distinct crate name referenced in shields.io
    # crates/ badge URLs in the README.
    badge_names=$(grep -oE 'img\.shields\.io/crates/[a-z]+/[A-Za-z0-9_-]+' "$p/README.md" 2>/dev/null \
                  | awk -F/ '{print $NF}' \
                  | sort -u)

    if [[ -z "$badge_names" ]]; then
        # crates.io badge is optional — many README styles omit it.
        no_badge=$((no_badge + 1))
        continue
    fi

    checked=$((checked + 1))
    wrong=""
    for n in $badge_names; do
        if [[ "$n" != "$pkg" ]]; then
            wrong="$wrong $n"
        fi
    done
    if [[ -z "$wrong" ]]; then
        echo "PASS  $p/README.md: crates.io badge name(s) match Cargo package $pkg"
    else
        echo "FAIL  $p/README.md: crates.io badge name(s) [$wrong] don't match Cargo package $pkg — silent wrong-crate page link"
        mismatched=$((mismatched + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked READMEs checked (with crates.io badges), $no_badge with no badge (optional), $mismatched with wrong-crate badge URL"

[[ $ok -eq 1 ]] && exit 0 || exit 1
