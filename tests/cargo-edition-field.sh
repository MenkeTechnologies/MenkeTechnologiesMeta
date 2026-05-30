#!/usr/bin/env bash
# For every Rust submodule, pin that the package Cargo.toml has an
# explicit `edition` field set to 2021 or 2024. Missing edition
# silently defaults to 2015 — a 10-year-old edition with `extern
# crate` requirements, trait-object syntax differences, and pre-NLL
# borrow-checker behavior. A repo missing the field that was working
# on a newer-edition toolchain will silently regress when the
# default kicks in (e.g., a fresh checkout on a different machine).
#
# Accepts `edition = "2021"`, `edition = "2024"`, and the workspace
# inheritance pattern `edition.workspace = true` (resolved through
# the workspace root's `[workspace.package]`).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
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
old=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    # Locate the package Cargo.toml (the one with a [package] section).
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    checked=$((checked + 1))

    # Look for explicit `edition = "..."` or `edition.workspace = true` →
    # resolved through workspace root's [workspace.package].
    edition=""
    if grep -qE '^edition\.workspace *= *true' "$cargo"; then
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            edition=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^edition *= *"/ {
                    match($0, /"[^"]*"/)
                    print substr($0, RSTART + 1, RLENGTH - 2)
                    exit
                }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$edition" ]]; then
        edition=$(grep -m1 -E '^edition *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi

    if [[ -z "$edition" ]]; then
        echo "FAIL  $cargo: no edition field — defaults to 2015 (extern crate, pre-NLL)"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    case "$edition" in
        2021|2024)
            echo "PASS  $cargo: edition = \"$edition\""
            ;;
        2018)
            echo "WARN  $cargo: edition = \"2018\" — still supported but 2021 is the org default"
            ;;
        2015)
            echo "FAIL  $cargo: edition = \"2015\" — legacy default, port to 2021"
            old=$((old + 1))
            ok=0
            ;;
        *)
            echo "FAIL  $cargo: edition = \"$edition\" — not a known Rust edition"
            old=$((old + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked package Cargo.toml files checked, $missing without edition, $old on legacy edition"

[[ $ok -eq 1 ]] && exit 0 || exit 1
