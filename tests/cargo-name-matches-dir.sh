#!/usr/bin/env bash
# For every PUBLISHABLE Rust Cargo.toml, pin that the `name`
# field matches the submodule directory name from .gitmodules
# (case-insensitive comparison since GitHub URLs are case-
# insensitive but crates.io names are forced to lowercase).
#
# crates.io publishes the crate under the `name` field's value —
# that becomes the canonical identifier (cargo add <name>,
# docs.rs/<name>, crates.io/crates/<name>). When the published
# name diverges from the GitHub repo dir, three things break
# silently:
#
#   1. README's `cargo add <name>` instructions go stale if the
#      reader assumes the repo name. Worse if the package was
#      renamed once: the OLD name still works (crates.io retains
#      the slot indefinitely) but points at an old version.
#   2. iter-26's GH Pages URL convention assumes repo=name. A
#      crate published as "foo-cli" from a repo called "foo"
#      gets its homepage on github.io/foo/ but the crates.io
#      sidebar says "foo-cli" — confusing.
#   3. iter-63's docs.rs URL check assumes `documentation` =
#      `https://docs.rs/<name>`. If name != dir, the
#      `repository` and `documentation` fields point at
#      different identifiers, doubling the cognitive load on
#      anyone trying to trace a release from card → repo.
#
# Publish=false crates SKIPPED — they don't get published, so
# the name field is purely workspace-internal and the convention
# of `-helper` / `-desktop` suffixes is intentional (stryke-* and
# traderview's src-tauri/).
#
# Pattern enforced: lowercased(name) == lowercased(<dir-from-.gitmodules>)
#
# 11/11 publishable crates green at iter-71 add — pure
# regression floor against future hand-edits that diverge the
# name from the dir without a deliberate rename of both.
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

extract_name() {
    awk '
        /^\[package\]/ { in_p = 1; next }
        /^\[/          { in_p = 0 }
        in_p && /^name *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
        }
    ' "$1"
}

checked=0
skipped=0
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

    if grep -qE '^publish *= *false' "$cargo"; then
        skipped=$((skipped + 1))
        continue
    fi

    name=$(extract_name "$cargo")
    [[ -n "$name" ]] || continue
    checked=$((checked + 1))

    base="${p##*/}"
    bl=$(echo "$base" | tr '[:upper:]' '[:lower:]')
    nl=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    if [[ "$bl" == "$nl" ]]; then
        echo "PASS  $cargo: name=\"$name\" matches dir \"$base\""
    else
        echo "FAIL  $cargo: name=\"$name\" but submodule dir is \"$base\" (case-insensitive comparison)"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked publishable crates checked ($skipped publish=false skipped), $bad name/dir mismatches"

[[ $ok -eq 1 ]] && exit 0 || exit 1
