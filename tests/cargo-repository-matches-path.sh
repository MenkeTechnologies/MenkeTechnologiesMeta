#!/usr/bin/env bash
# For every Rust Cargo.toml that sets the `repository` field, pin
# that the URL is `https://github.com/MenkeTechnologies/<dir>`
# where <dir> is the submodule directory name in .gitmodules.
#
# Catches the classic rename/typo drift: a submodule renamed at
# the GitHub level (e.g. awkrs → awk-rs) but Cargo.toml's
# `repository` field still pointing at the old URL. crates.io
# renders `repository` as a clickable link on the crate card; a
# stale URL leads users to a "404 not found" page on github.com
# while the crate itself appears healthy.
#
# Other drift caught:
#   - Trailing `.git` left from `git remote -v` copy-paste
#   - Inconsistent path/dash conventions (`audio_haxor` vs
#     `Audio-Haxor` — directory name is the source of truth)
#   - Personal-fork URLs accidentally committed
#     (github.com/contributor/<name> instead of org)
#   - http:// instead of https://
#
# Trailing `/` and trailing `.git` are stripped during comparison
# — both are accepted forms on github.com. The path-segment
# casing must match exactly (GitHub URLs are case-insensitive
# but the canonical form preserves the directory's case).
#
# 26/26 Rust crates with `repository` set green at iter-64 add
# — pure regression floor.
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
mismatch=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    repo=$(grep -m1 -E '^repository *= *"' "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$repo" ]] || continue
    checked=$((checked + 1))

    norm="${repo%/}"
    norm="${norm%.git}"

    base="${p##*/}"
    expected="https://github.com/MenkeTechnologies/$base"

    if [[ "$norm" == "$expected" ]]; then
        echo "PASS  $cargo: repository=$repo"
    else
        echo "FAIL  $cargo: repository=$repo (expected $expected — submodule dir=$base)"
        mismatch=$((mismatch + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml repository fields checked, $mismatch mismatched against submodule path"

[[ $ok -eq 1 ]] && exit 0 || exit 1
