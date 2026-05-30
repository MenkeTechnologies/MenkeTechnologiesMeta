#!/usr/bin/env bash
# For every Rust submodule, pin that Cargo.toml's `repository` field
# is set AND points at `https://github.com/MenkeTechnologies/<name>`.
#
# Catches the failure modes:
#   - Missing `repository` field → crates.io publish warning, no
#     repository link on the published crate page, broken navigation
#     from `cargo metadata` consumers
#   - Field pointing at a fork / wrong org → broken bug-report links,
#     downstream tools (dependabot, advisory DBs) can't resolve the
#     repo correctly
#
# For Tauri-pattern workspaces (Audio-Haxor / traderview), the field
# is checked in src-tauri/Cargo.toml since that's the package crate
# (the workspace-root Cargo.toml has no [package] section).
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
    # Locate the package Cargo.toml (the one with a [package] section).
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    checked=$((checked + 1))
    submodule_name="${p##*/}"
    expected="https://github.com/MenkeTechnologies/${submodule_name}"

    # Look for repository field directly OR `repository.workspace = true`
    # with the value living in the workspace root's [workspace.package].
    repo=""
    if grep -qE '^repository\.workspace *= *true' "$cargo"; then
        # Resolve via the workspace root. For src-tauri/Cargo.toml the
        # workspace root is $p/Cargo.toml.
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            repo=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^repository *= *"/ {
                    match($0, /"[^"]*"/)
                    print substr($0, RSTART + 1, RLENGTH - 2)
                    exit
                }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$repo" ]]; then
        repo=$(grep -m1 -E '^repository *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    fi

    if [[ -z "$repo" ]]; then
        echo "FAIL  $cargo: no repository = field — crates.io publish warning + dependabot can't resolve"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    # Accept .git suffix variants.
    case "$repo" in
        "$expected"|"$expected.git"|"$expected/")
            echo "PASS  $cargo: repository = $repo"
            ;;
        *)
            echo "FAIL  $cargo: repository = '$repo' — expected '$expected' (or .git/trailing-slash variant)"
            wrong=$((wrong + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked package Cargo.toml files checked, $missing without repository=, $wrong pointing elsewhere"

[[ $ok -eq 1 ]] && exit 0 || exit 1
