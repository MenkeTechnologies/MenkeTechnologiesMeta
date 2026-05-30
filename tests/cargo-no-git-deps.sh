#!/usr/bin/env bash
# For every publishable Rust crate's dependency tables, pin that
# no entry uses `git = "..."` as a source.
#
# crates.io's publish API REJECTS git dependencies at publish
# time with:
#
#   error: failed to prepare local package for uploading
#   caused by: all dependencies must have a version specified
#   when publishing. dependency `foo` does not specify a version
#
# Same failure mode as iter-62's wildcard gate (publish-time
# blocker), same fix (catch at lint time). Git deps sneak in from
# tutorials that pin to an upstream main branch for an unreleased
# feature, or from copy-paste of internal workspace patterns into
# a publishable crate.
#
# `publish = false` crates (the 14 stryke-* connectors that are
# workspace-internal, Tauri apps, etc.) are SKIPPED — they never
# go to crates.io so the publish-time block doesn't apply, and
# git deps are sometimes legitimately needed for unreleased
# upstream fixes.
#
# Detected forms:
#   foo = { git = "https://..." }                     (table)
#   foo = { git = "https://...", branch = "main" }    (table w/ ref)
#
# 0/27 publishable crates with git deps at iter-66 add — pure
# regression floor.
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

# Find git = "..." lines inside any of the four dep section kinds.
# Returns "section: full-line" per hit.
detect_git_deps() {
    awk '
        /^\[dependencies\]/             { in_d = 1; sect = "deps";       next }
        /^\[dev-dependencies\]/         { in_d = 1; sect = "dev-deps";   next }
        /^\[build-dependencies\]/       { in_d = 1; sect = "build-deps"; next }
        /^\[workspace\.dependencies\]/  { in_d = 1; sect = "ws-deps";    next }
        /^\[/                           { in_d = 0 }
        in_d && /git *= *"/ {
            print sect ": " $0
        }
    ' "$1"
}

checked=0
git_hits=0
skipped=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    if grep -qE '^publish *= *false' "$cargo"; then
        echo "SKIP  $cargo: publish=false"
        skipped=$((skipped + 1))
        continue
    fi
    checked=$((checked + 1))

    hits=$(detect_git_deps "$cargo")
    if [[ -z "$hits" ]]; then
        echo "PASS  $cargo: no git deps"
    else
        while IFS= read -r h; do
            echo "FAIL  $cargo: $h"
            git_hits=$((git_hits + 1))
        done <<< "$hits"
        ok=0
    fi
done

echo "---"
echo "Summary: $checked publishable crates checked ($skipped publish=false skipped), $git_hits git dep entries"

[[ $ok -eq 1 ]] && exit 0 || exit 1
