#!/usr/bin/env bash
# For every Rust submodule, pin that the package Cargo.toml has a
# `homepage` field. crates.io shows the homepage as the primary
# "visit project" link on the crate page — without it, the only
# resolvable link is the `repository` (also useful but duplicates
# the GitHub-page link). With it, users land on the GitHub Pages
# rendered docs first, which is the better entry point.
#
# Accepts:
#   - `homepage = "https://menketechnologies.github.io/<name>/"`
#     (preferred — GH Pages docs entry, where docs/index.html lives)
#   - `homepage = "https://github.com/MenkeTechnologies/<name>"`
#     (acceptable fallback when repo doesn't ship docs/)
#   - `homepage.workspace = true` (workspace inheritance)
#   - Any other valid https URL with MenkeTechnologies somewhere
#     (catches forks but doesn't enforce one canonical form)
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
missing=0
wrong=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    checked=$((checked + 1))

    homepage=""
    if grep -qE '^homepage\.workspace *= *true' "$cargo"; then
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            homepage=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^homepage *= *"/ {
                    match($0, /"[^"]*"/)
                    print substr($0, RSTART + 1, RLENGTH - 2)
                    exit
                }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$homepage" ]]; then
        homepage=$(grep -m1 -E '^homepage *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi

    if [[ -z "$homepage" ]]; then
        echo "FAIL  $cargo: no homepage field — crate page lacks the primary 'visit project' link"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    case "$homepage" in
        https://menketechnologies.github.io/*|https://github.com/MenkeTechnologies/*)
            echo "PASS  $cargo: homepage = $homepage"
            ;;
        https://*)
            # Accept other https URLs as long as MenkeTechnologies is in them.
            if [[ "$homepage" == *MenkeTechnologies* ]] || [[ "$homepage" == *menketechnologies* ]]; then
                echo "PASS  $cargo: homepage = $homepage"
            else
                echo "FAIL  $cargo: homepage = '$homepage' — doesn't look MenkeTechnologies-attributable"
                wrong=$((wrong + 1))
                ok=0
            fi
            ;;
        *)
            echo "FAIL  $cargo: homepage = '$homepage' — not an https URL"
            wrong=$((wrong + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked package Cargo.toml files checked, $missing without homepage, $wrong with non-canonical homepage"

[[ $ok -eq 1 ]] && exit 0 || exit 1
