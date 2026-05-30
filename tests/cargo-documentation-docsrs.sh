#!/usr/bin/env bash
# For every Rust Cargo.toml that sets the `documentation` field,
# pin that the URL is exactly `https://docs.rs/<crate-name>`
# (trailing slash optional).
#
# docs.rs is the canonical hosted-rustdoc location for crates
# published to crates.io. Every publish triggers an automatic
# build there at https://docs.rs/<name>. Setting the
# `documentation` field to anything else (a custom GH Pages URL,
# a personal blog, a GitHub repo) is wrong for three reasons:
#
#   1. crates.io renders the field as a "Documentation" sidebar
#      link. Users click it expecting current API reference —
#      if it lands on a stale blog post or the repo's README,
#      they bounce.
#   2. docs.rs is the only source guaranteed to be in sync with
#      the published version. Any other URL drifts on every
#      release.
#   3. The `homepage` field already covers the GH Pages docs
#      site (iter-26 convention). Duplicating that URL in
#      `documentation` collapses two clickable links into one
#      destination, which iter-57 specifically gates against.
#
# Pattern enforced: `https://docs.rs/<exact-name>` (case-
# sensitive, no `/latest`, no version pin — docs.rs auto-redirects
# to the latest version when no version is specified).
#
# 11/11 publishable crates with documentation field set green
# at iter-63 add — pure regression floor.
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
    docs=$(grep -m1 -E '^documentation *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$docs" ]] || continue
    [[ -n "$name" ]] || continue
    checked=$((checked + 1))

    expected="https://docs.rs/$name"
    norm="${docs%/}"

    if [[ "$norm" == "$expected" ]]; then
        echo "PASS  $cargo: documentation=$docs"
    else
        echo "FAIL  $cargo: documentation=$docs (expected $expected — docs.rs is the canonical hosted-rustdoc URL)"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml documentation fields checked, $bad pointing at non-docs.rs URL"

[[ $ok -eq 1 ]] && exit 0 || exit 1
