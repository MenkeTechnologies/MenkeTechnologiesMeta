#!/usr/bin/env bash
# For every Rust submodule, pin that the package Cargo.toml has an
# `authors` field with at least one MenkeTechnologies-attributable
# identifier. Without this, crates.io shows "no authors" on the crate
# page, downstream advisory DBs can't resolve maintainer, and
# attribution is lost when the crate is mirrored or republished.
#
# Accepts:
#   - `authors = ["MenkeTechnologies"]` (canonical org-as-author, 20 uses)
#   - `authors = ["MenkeTechnologies <email>"]` (with explicit contact)
#   - `authors = ["Jacob Menke", ...]` (real name; first contributor)
#   - `authors.workspace = true` resolved through `[workspace.package]`
#     with the workspace-root value matching one of the above
#
# Catches:
#   - Missing `authors` field entirely (crates.io publish proceeds but
#     attribution is silently dropped from the crate page)
#   - `authors = ["someone-else"]` after fork without re-attribution
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

# Returns 0 if the given authors line includes a MenkeTechnologies
# identifier or "Jacob Menke" (the human name, per CLAUDE.md user
# context).
attributable() {
    local line="$1"
    if [[ "$line" == *MenkeTechnologies* ]] || [[ "$line" == *"Jacob Menke"* ]]; then
        return 0
    fi
    return 1
}

checked=0
missing=0
wrong=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    # Locate the package Cargo.toml.
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    checked=$((checked + 1))

    # Resolve via workspace inheritance if needed.
    authors_line=""
    if grep -qE '^authors\.workspace *= *true' "$cargo"; then
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            authors_line=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^authors *=/    { print; exit }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$authors_line" ]]; then
        authors_line=$(grep -m1 -E '^authors *=' "$cargo" 2>/dev/null)
    fi

    if [[ -z "$authors_line" ]]; then
        echo "FAIL  $cargo: no authors field — crates.io publish drops attribution silently"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    if attributable "$authors_line"; then
        echo "PASS  $cargo: $authors_line"
    else
        echo "FAIL  $cargo: authors field doesn't include MenkeTechnologies or Jacob Menke: $authors_line"
        wrong=$((wrong + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked package Cargo.toml files checked, $missing without authors, $wrong without MenkeTechnologies/Jacob Menke"

[[ $ok -eq 1 ]] && exit 0 || exit 1
