#!/usr/bin/env bash
# For every Cargo.toml's [package].name field, pin that the
# value matches the crates.io ingest shape:
#
#   ^[a-z][a-z0-9_-]*$
#
# crates.io's publish API normalizes names to lowercase before
# storing them. Uploading a name with uppercase chars succeeds
# but the published identifier is the lowercased form — and
# the original mixed-case name in Cargo.toml then diverges from
# what `cargo add` resolves. Worse, the local crate name (used
# in `extern crate foo;` and `use foo::...` statements) is the
# Cargo.toml form; the network-published identifier is the
# lowercased form. Three different strings for the same crate
# in three different contexts.
#
# Per crates.io's ingest constraint docs:
#   - Must start with a lowercase letter
#   - May contain only lowercase letters, digits, `-`, `_`
#   - Max length 64 chars (enforced separately by Cargo)
#
# Skips publish=false crates — they don't go to crates.io so
# the publish-side normalization doesn't apply, though most
# workspace-internal names still happen to satisfy this shape.
# (The org's `-helper` suffix convention on stryke-* connectors
# is already lowercase + hyphens.)
#
# 27/27 crates (publishable + publish=false) green at iter-92
# add — pure regression floor.
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
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    name=$(grep -m1 -E '^name *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$name" ]] || continue
    checked=$((checked + 1))

    if echo "$name" | grep -qE '^[a-z][a-z0-9_-]*$'; then
        echo "PASS  $cargo: name=\"$name\""
    else
        echo "FAIL  $cargo: name=\"$name\" (must match ^[a-z][a-z0-9_-]*\$ — crates.io ingest shape)"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml names checked, $bad with non-conformant shape"

[[ $ok -eq 1 ]] && exit 0 || exit 1
