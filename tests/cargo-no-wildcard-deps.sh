#!/usr/bin/env bash
# For every Rust Cargo.toml, pin that no dependency uses a `"*"`
# wildcard version requirement.
#
# crates.io's publish API REJECTS any crate with wildcard
# dependencies — `cargo publish` fails with:
#
#   error: failed to publish to registry at https://crates.io
#   caused by: the crate is missing the following fields:
#     dependencies cannot have wildcard versions
#
# This is a publish-time gate (slow feedback), but the same check
# at lint time gives instant feedback. Detection:
#
#   - `name = "*"`          (short form)
#   - `name = { version = "*", ... }` (table form)
#
# Both are caught. Applied to:
#   [dependencies]
#   [dev-dependencies]
#   [build-dependencies]
#   [workspace.dependencies]
#
# 0/27 wildcard deps at iter-62 add — pure regression floor
# against the publish-blocker drift.
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

# Detect wildcard dep entries — both forms — inside the four dep
# section kinds. Returns name + form per hit (one per line).
detect_wildcards() {
    awk '
        /^\[dependencies\]/             { in_d = 1; sect = "deps";       next }
        /^\[dev-dependencies\]/         { in_d = 1; sect = "dev-deps";   next }
        /^\[build-dependencies\]/       { in_d = 1; sect = "build-deps"; next }
        /^\[workspace\.dependencies\]/  { in_d = 1; sect = "ws-deps";    next }
        /^\[/                           { in_d = 0 }
        in_d && /^[A-Za-z0-9_-]+ *= *"\*"/ {
            match($0, /^[A-Za-z0-9_-]+/)
            print sect ": " substr($0, RSTART, RLENGTH) " = \"*\"  (short form)"
        }
        in_d && /^[A-Za-z0-9_-]+ *= *\{[^}]*version *= *"\*"/ {
            match($0, /^[A-Za-z0-9_-]+/)
            print sect ": " substr($0, RSTART, RLENGTH) " = { version = \"*\", ... }  (table form)"
        }
    ' "$1"
}

checked=0
wild=0

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

    hits=$(detect_wildcards "$cargo")
    if [[ -z "$hits" ]]; then
        echo "PASS  $cargo: no wildcard deps"
    else
        while IFS= read -r h; do
            echo "FAIL  $cargo: $h"
            wild=$((wild + 1))
        done <<< "$hits"
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml files checked, $wild wildcard dep entries"

[[ $ok -eq 1 ]] && exit 0 || exit 1
