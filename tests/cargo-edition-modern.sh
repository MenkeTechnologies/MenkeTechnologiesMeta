#!/usr/bin/env bash
# For every Rust Cargo.toml, pin that the resolved `edition`
# field is "2021" or "2024" (the two modern editions still under
# active language-team development).
#
# Rust editions:
#   2015  — original, Box<dyn Trait> syntax wasn't standard
#   2018  — module path overhaul, ? operator, async/await
#   2021  — disjoint capture in closures, IntoIterator for arrays
#   2024  — let chains in stable, generic lifetimes, new edition
#           guard for try blocks, async closures
#
# Once an edition is two cycles old, the compiler still supports
# it but new lints, idiom suggestions, and standard library
# improvements stop applying. The clippy `rust_2018_idioms`
# group, for instance, has rules that don't fire on 2018 crates
# because the older idioms are still "current" by that edition's
# standard.
#
# Threshold: 2021 or later. 2018 was deprecated by the language
# team but still supported indefinitely; the gate forces an
# explicit `cargo fix --edition` migration before accepting a
# downgrade. Rejects 2015 outright.
#
# Workspace inheritance: handles `edition.workspace = true` by
# resolving to the workspace root's [workspace.package].edition
# value. For Tauri apps with src-tauri/Cargo.toml inheriting
# from the workspace root Cargo.toml, the gate walks both files.
#
# Coverage at iter-97 add:
#   - edition "2024":  5 crates  (zshrs, strykelang, fusevm, etc.)
#   - edition "2021": 21 crates  (most pre-2024 era)
#   - workspace-inherited: 1 case (traderview/src-tauri →
#                                  traderview/Cargo.toml = 2021)
#   Total 27/27 PASS. Pure regression floor.
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

# Extract edition from a single Cargo.toml's [package] section.
extract_pkg_edition() {
    awk '
        /^\[package\]/ { in_p = 1; next }
        /^\[/          { in_p = 0 }
        in_p && /^edition *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
        }
    ' "$1"
}

# Detect whether [package].edition is workspace-inherited.
extract_pkg_edition_workspace_flag() {
    awk '
        /^\[package\]/ { in_p = 1; next }
        /^\[/          { in_p = 0 }
        in_p && /^edition\.workspace *= *true/ { print "true"; exit }
    ' "$1"
}

# Extract edition from a workspace root's [workspace.package].
extract_workspace_edition() {
    awk '
        /^\[workspace\.package\]/ { in_w = 1; next }
        /^\[/                     { in_w = 0 }
        in_w && /^edition *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
        }
    ' "$1"
}

checked=0
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    pkg_dir=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"; pkg_dir="$p"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"; pkg_dir="$p/src-tauri"
    fi
    [[ -n "$cargo" ]] || continue

    edition=$(extract_pkg_edition "$cargo")

    if [[ -z "$edition" ]]; then
        # Check for workspace inheritance.
        ws_flag=$(extract_pkg_edition_workspace_flag "$cargo")
        if [[ "$ws_flag" == "true" ]]; then
            # Walk up to find workspace root.
            ws_root="$p/Cargo.toml"
            if [[ "$cargo" == "$p/src-tauri/Cargo.toml" ]]; then
                ws_root="$p/Cargo.toml"
            fi
            if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
                edition=$(extract_workspace_edition "$ws_root")
                source="inherited from $ws_root"
            fi
        fi
    else
        source="direct"
    fi

    if [[ -z "$edition" ]]; then
        echo "FAIL  $cargo: no edition field (and no workspace inheritance found)"
        bad=$((bad + 1))
        ok=0
        continue
    fi

    checked=$((checked + 1))

    case "$edition" in
        "2021"|"2024")
            echo "PASS  $cargo: edition=$edition ($source)"
            ;;
        *)
            echo "FAIL  $cargo: edition=$edition ($source) — must be 2021 or 2024"
            bad=$((bad + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked Cargo.toml editions checked, $bad on pre-2021 / unresolved"

[[ $ok -eq 1 ]] && exit 0 || exit 1
