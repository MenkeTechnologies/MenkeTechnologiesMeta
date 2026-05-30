#!/usr/bin/env bash
# For every Cargo.toml `authors = [...]` array, pin that every
# entry is unique within the array.
#
# Third member of the cargo array-uniqueness triad after
# iter-153 (keywords) and iter-154 (categories). Same pattern:
#
#   - Duplicate authors in the array waste rendering slots
#     on crates.io's crate-page Authors sidebar
#   - cargo-crate registry exports include the duplicate, which
#     org-wide contributor-frequency tools may double-count
#   - Hand-edited author lists during contributor renames /
#     email rotations are the common drift source — the old
#     entry gets left in place when the new one is added
#
# Why authors-unique matters even when only ONE author is
# expected: the org convention is `authors = ["MenkeTechnologies"]`
# (single-element). A future expansion to multiple authors
# (e.g., during a contribution from a guest) would introduce
# the array form; the gate forecloses the introduction-time
# bug of "added the new contributor but accidentally kept
# the typo'd old name."
#
# Detection: extract authors array via regex, compare
# len(authors) vs len(set(authors)). Report which specific
# entries appear more than once.
#
# Pairs with iter-153 (keywords), iter-154 (categories).
# Three cargo-metadata array-uniqueness gates now in place.
#
# 26/26 authors arrays green at iter-155 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

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

audit_one() {
    python3 - "$1" << 'PY'
import sys, re
cargo = sys.argv[1]
content = open(cargo).read()
m = re.search(r'(?ms)^authors\s*=\s*\[([^\]]+)\]', content)
if not m:
    print("NO_AUTHORS")
    sys.exit()
authors = re.findall(r'"([^"]+)"', m.group(1))
if not authors:
    print("NO_AUTHORS")
    sys.exit()
dups = sorted({a for a in authors if authors.count(a) > 1})
if dups:
    print("BAD:" + ",".join(dups))
else:
    print("OK")
PY
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

    output=$(audit_one "$cargo")
    case "$output" in
        NO_AUTHORS) continue ;;
        OK)
            checked=$((checked + 1))
            echo "PASS  $cargo: authors are unique"
            ;;
        BAD:*)
            checked=$((checked + 1))
            echo "FAIL  $cargo: duplicate authors: ${output#BAD:}"
            bad=$((bad + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked author arrays checked, $bad with duplicates"

[[ $ok -eq 1 ]] && exit 0 || exit 1
