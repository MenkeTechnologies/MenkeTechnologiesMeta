#!/usr/bin/env bash
# For every Cargo.toml `categories = [...]` array, pin that
# every entry is unique within the array.
#
# Mirror of iter-153 (keywords-unique). Categories on
# crates.io serve the same discovery role as keywords but
# are drawn from a fixed slug list rather than free-form
# text:
#
#   - crates.io's max_categories limit is 5 (same as
#     keywords)
#   - Duplicates waste category slots
#   - Search-index treats duplicate category entries as a
#     single category for query matching
#   - Crate card rendering shows the duplicate verbatim if
#     ingest doesn't dedupe
#
# Drift introduction is identical to iter-153:
#   - Refresh during a crate rename — old category retained
#     alongside new equivalent
#   - Copy-paste from another crate without noticing the
#     overlap
#   - Alphabetization step that didn't dedupe
#
# Detection: extract categories array via regex, compare
# len(cats) vs len(set(cats)). Report which specific
# categories appear more than once.
#
# Pairs with iter-153 (keywords-unique). Together: both
# discovery-slot fields on the crate card are unique-within-
# their-array.
#
# 11/11 categories arrays green at iter-154 add — pure
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
m = re.search(r'(?m)^categories\s*=\s*\[([^\]]+)\]', content)
if not m:
    print("NO_CATEGORIES")
    sys.exit()
cats = re.findall(r'"([^"]+)"', m.group(1))
if not cats:
    print("NO_CATEGORIES")
    sys.exit()
dups = sorted({c for c in cats if cats.count(c) > 1})
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
        NO_CATEGORIES) continue ;;
        OK)
            checked=$((checked + 1))
            echo "PASS  $cargo: categories are unique"
            ;;
        BAD:*)
            checked=$((checked + 1))
            echo "FAIL  $cargo: duplicate categories: ${output#BAD:}"
            bad=$((bad + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked category arrays checked, $bad with duplicates"

[[ $ok -eq 1 ]] && exit 0 || exit 1
