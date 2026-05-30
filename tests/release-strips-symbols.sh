#!/usr/bin/env bash
# For every Rust binary submodule (Cargo.toml declares [[bin]]
# AND has a release.yml workflow), pin that the release artifact
# is built with stripped debug symbols — either via Cargo.toml's
# `[profile.release] strip = true` OR an explicit `strip` invocation
# in release.yml's packaging step.
#
# Unstripped Rust release binaries carry ~5-10x more bytes than
# stripped equivalents (debug symbols, type metadata, source paths
# for backtraces, etc.). For a tap formula that ships via brew, the
# user pays this size in download bandwidth on every install. A
# 20 MB binary stripped to 4 MB is a 5x improvement on perceived
# install speed — and zero cost since rust's panic backtraces work
# fine without the embedded debug info.
#
# Test accepts either form:
#   - `strip = true` or `strip = "symbols"` in [profile.release]
#   - any `strip` command in release.yml (typically `strip $binary`
#     after `cargo build --release`)
#
# Skips library-only crates (no [[bin]]) and crates without
# release.yml (they don't publish binary releases at all).
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
no_strip=0

# Detect strip directive in Cargo.toml [profile.release] section.
cargo_strips() {
    local cargo="$1"
    awk '
        /^\[profile\.release\]/ { in_p = 1; next }
        /^\[/                   { in_p = 0 }
        in_p && /^strip *= *(true|"symbols"|"debuginfo")/ { found = 1; exit }
        END { exit !found }
    ' "$cargo"
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Only check crates with [[bin]] declarations.
    grep -qE '^\[\[bin\]\]' "$cargo" || continue

    rel=""
    if [[ -f "$p/.github/workflows/release.yml" ]]; then
        rel="$p/.github/workflows/release.yml"
    fi
    # Skip crates without release.yml — they don't publish binaries
    # so the strip optimization doesn't apply.
    [[ -n "$rel" ]] || continue

    checked=$((checked + 1))

    # Check both the package Cargo.toml AND the workspace root.
    # Tauri apps use workspace inheritance: the package crate is in
    # src-tauri/Cargo.toml but [profile.release] lives in the
    # workspace root Cargo.toml (traderview pattern). Without checking
    # both, the workspace-root strip is missed.
    source=""
    if cargo_strips "$cargo"; then
        source="$cargo [profile.release]"
    elif [[ "$cargo" != "$p/Cargo.toml" ]] && [[ -f "$p/Cargo.toml" ]] && cargo_strips "$p/Cargo.toml"; then
        source="$p/Cargo.toml [profile.release] (workspace root)"
    elif grep -qE '\bstrip\b' "$rel"; then
        source="release.yml"
    fi

    if [[ -n "$source" ]]; then
        echo "PASS  $p: strip via $source"
    else
        echo "FAIL  $p: no strip directive — release binary will carry full debug symbols (~5-10x size bloat)"
        no_strip=$((no_strip + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Rust binary crates with release.yml checked, $no_strip without strip"

[[ $ok -eq 1 ]] && exit 0 || exit 1
