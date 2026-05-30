#!/usr/bin/env bash
# For every Rust binary submodule with both Cargo.toml AND
# Cargo.lock, pin that the lockfile's `[[package]]` entry for the
# crate's own package name has a `version` matching Cargo.toml's
# version field.
#
# Catches the failure mode where someone bumps Cargo.toml's version
# (via the `bp` shortcut or manual edit) but skips running
# `cargo update`/`cargo build` to refresh Cargo.lock. The locked
# self-version then references an older release. Consequences:
#
#   - `cargo build --locked` (the standard release pattern, per the
#     iter-6 release-locked-build gate) FAILS because the requested
#     dependency version doesn't match the lockfile entry.
#   - Crates.io publish proceeds (it doesn't check Cargo.lock) but
#     the .crate file's bundled lockfile is wrong; downstream
#     `cargo install --locked <crate>` users get a build-time error.
#
# The fix is one-line: `cargo update -p <crate>` (or just any cargo
# command that touches the lockfile). This test pins detection.
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
drifted=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    # Locate the package Cargo.toml (top-level or src-tauri).
    cargo=""
    cargo_dir=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
        cargo_dir="$p"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
        cargo_dir="$p/src-tauri"
    fi
    [[ -n "$cargo" ]] || continue

    # Find Cargo.lock — workspace root usually has it, even if package
    # lives in src-tauri/.
    lock=""
    if [[ -f "$p/Cargo.lock" ]]; then
        lock="$p/Cargo.lock"
    elif [[ -f "$cargo_dir/Cargo.lock" ]]; then
        lock="$cargo_dir/Cargo.lock"
    fi
    [[ -n "$lock" ]] || continue

    pkg_name=$(awk '
        /^\[package\]/{in_p=1}
        in_p && /^name *= *"/{match($0,/"[^"]*"/); print substr($0,RSTART+1,RLENGTH-2); exit}
    ' "$cargo")
    cargo_ver=$(grep -m1 -E '^version *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$pkg_name" && -n "$cargo_ver" ]] || continue

    # Find the [[package]] block in Cargo.lock matching this crate's name.
    # `found` flag prevents END block from re-printing when exit fires.
    lock_ver=$(awk -v pkg="$pkg_name" '
        /^\[\[package\]\]/{in_pkg=1; cur_name=""; cur_ver=""; next}
        in_pkg && /^name *= *"/{match($0,/"[^"]*"/); cur_name=substr($0,RSTART+1,RLENGTH-2)}
        in_pkg && /^version *= *"/{match($0,/"[^"]*"/); cur_ver=substr($0,RSTART+1,RLENGTH-2)}
        in_pkg && /^$/{if(cur_name==pkg){print cur_ver; found=1; exit} in_pkg=0}
        END{if(!found && in_pkg && cur_name==pkg){print cur_ver}}
    ' "$lock")

    if [[ -z "$lock_ver" ]]; then
        echo "INFO  $p: $pkg_name not found in $lock (workspace member published separately?)"
        continue
    fi

    checked=$((checked + 1))
    if [[ "$cargo_ver" == "$lock_ver" ]]; then
        echo "PASS  $p: Cargo.toml $cargo_ver == Cargo.lock $lock_ver"
    else
        echo "FAIL  $p: Cargo.toml $cargo_ver != Cargo.lock $lock_ver — run \`cargo update -p $pkg_name\` to sync"
        drifted=$((drifted + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml ↔ Cargo.lock self-version pairs checked, $drifted drifted"

[[ $ok -eq 1 ]] && exit 0 || exit 1
