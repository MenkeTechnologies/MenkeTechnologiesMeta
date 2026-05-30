#!/usr/bin/env bash
# For every Rust binary submodule that ships man pages, pin that the
# version string in the `.TH` line of each man page matches Cargo.toml's
# version field.
#
# `.TH NAME 1 "DATE" "<name> <VERSION>" "User Commands"` is what
# `man <name>` prints at the very top of the page. When Cargo.toml
# bumps but the man page isn't refreshed, users get misleading version
# info from man — and any "report bugs against <version>" downstream
# automation reads a stale number.
#
# Caught 14 of 18 man pages with stale version strings 2026-05-30
# (iftoprs/lsofrs/awkrs/temprs/nmaprs/strykelang/zshrs all behind);
# bulk-fixed via sed-replace.
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
stale=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -d "$p/man/man1" ]] || continue
    # Locate Cargo.toml (top-level OR src-tauri/).
    cargo=""
    if [[ -f "$p/Cargo.toml" ]]; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]]; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue
    cargo_ver=$(grep -m1 -E '^version *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$cargo_ver" ]] || continue

    for m in "$p"/man/man1/*.1; do
        [[ -f "$m" ]] || continue
        checked=$((checked + 1))
        # Extract semver from .TH line. Pattern:
        #   .TH NAME 1 "DATE" "<name> X.Y.Z" "User Commands"
        th_ver=$(grep -m1 '^\.TH ' "$m" \
                 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
                 | head -1)
        if [[ -z "$th_ver" ]]; then
            echo "FAIL  $m: no semver in .TH header line"
            stale=$((stale + 1))
            ok=0
            continue
        fi
        if [[ "$cargo_ver" == "$th_ver" ]]; then
            echo "PASS  $m: .TH version $th_ver == Cargo $cargo_ver"
        else
            echo "FAIL  $m: .TH version $th_ver != Cargo $cargo_ver"
            stale=$((stale + 1))
            ok=0
        fi
    done
done

echo "---"
echo "Summary: $checked man pages checked, $stale with stale .TH version"

[[ $ok -eq 1 ]] && exit 0 || exit 1
