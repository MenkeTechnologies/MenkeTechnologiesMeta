#!/usr/bin/env bash
# For every Rust submodule's package Cargo.toml, pin that the
# `version` field is strict X.Y.Z (or X.Y.Z-prerelease) semver.
#
# Cargo accepts loose forms like `1.0` (no patch), `1` (only major),
# or `1.0.0-dev` (prerelease without numeric segments) but each
# triggers different surprising behaviors:
#
#   - `1.0` is interpreted as `1.0.0` for cargo internal use but
#     OTHER tools (release-please, dependabot, brew formula bumpers)
#     have inconsistent handling — some treat as `1.0.0`, others
#     as `1.0.x` floating range
#   - Missing patch breaks the `cargo-vs-tag-version` gate (iter 33)
#     because semver comparison `1.0` vs `1.0.0` returns < not ==
#   - Prerelease shapes without a numeric ordering segment can
#     compare unexpectedly: `1.0.0-dev` < `1.0.0-rc1` < `1.0.0`
#     but `1.0.0-RC1` > `1.0.0-dev`
#
# Test enforces strict `^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$`.
# Handles `version.workspace = true` inheritance by following
# through to `[workspace.package].version`.
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
loose=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Resolve via workspace inheritance if needed.
    ver=""
    if grep -qE '^version\.workspace *= *true' "$cargo"; then
        ws_root="$p/Cargo.toml"
        if [[ -f "$ws_root" ]] && grep -qE '^\[workspace\.package\]' "$ws_root"; then
            ver=$(awk '
                /^\[workspace\.package\]/ { in_ws = 1; next }
                /^\[/                     { in_ws = 0 }
                in_ws && /^version *= *"/ {
                    match($0, /"[^"]*"/)
                    print substr($0, RSTART + 1, RLENGTH - 2)
                    exit
                }
            ' "$ws_root")
        fi
    fi
    if [[ -z "$ver" ]]; then
        # Direct form: `version = "X.Y.Z"` in [package] section.
        ver=$(awk '
            /^\[package\]/ { in_p = 1; next }
            /^\[/          { in_p = 0 }
            in_p && /^version *= *"/ {
                match($0, /"[^"]*"/)
                print substr($0, RSTART + 1, RLENGTH - 2)
                exit
            }
        ' "$cargo")
    fi
    [[ -n "$ver" ]] || continue

    checked=$((checked + 1))

    if [[ "$ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
        echo "PASS  $cargo: version = \"$ver\""
    else
        echo "FAIL  $cargo: version = \"$ver\" — not strict X.Y.Z[-prerelease] semver"
        loose=$((loose + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml files checked, $loose with non-strict-semver version"

[[ $ok -eq 1 ]] && exit 0 || exit 1
