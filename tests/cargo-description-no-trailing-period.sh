#!/usr/bin/env bash
# For every Rust submodule's Cargo.toml description field, pin that
# the value does NOT end with a period.
#
# Per the Cargo book's metadata style guide (`cargo-toml` documentation
# under "Field reference"): descriptions are presented as a short
# blurb (not a sentence), and many display contexts (crates.io card,
# cargo search output, IDE tooltips) append their own punctuation.
# A description ending with `.` then renders as `..` in those
# contexts — small visual noise but consistent across the org.
#
# Convention preferred over enforcement: this gate FAILs on trailing
# periods because the style guide is unambiguous and the fix is
# trivial (one character stripped). For repos that have a legitimate
# reason to end with `.` (e.g., the description is two sentences and
# the period structurally matters), the fix is to rephrase as a
# single short blurb.
#
# Also catches multi-sentence descriptions where iter-27's length
# cap (150 chars) wasn't enough to surface the convention violation.
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
trailing=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    desc=$(grep -m1 -E '^description *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$desc" ]] || continue
    checked=$((checked + 1))

    last="${desc: -1}"
    if [[ "$last" == "." ]]; then
        echo "FAIL  $cargo: description ends with '.' — last 40 chars: ...${desc: -40}"
        trailing=$((trailing + 1))
        ok=0
    else
        echo "PASS  $cargo: description ends with '${last}'"
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml descriptions checked, $trailing with trailing period"

[[ $ok -eq 1 ]] && exit 0 || exit 1
