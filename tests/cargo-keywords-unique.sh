#!/usr/bin/env bash
# For every Cargo.toml `keywords = [...]` array, pin that
# every entry is unique within the array (no duplicates).
#
# crates.io's max_keywords limit is 5. Duplicates inside the
# array are doubly wasteful:
#
#   - Duplicates burn slots from the 5-keyword budget. A crate
#     that declares `keywords = ["cli", "rust", "cli", "tui",
#     "fast"]` effectively has 4 distinct keywords ("cli"
#     "rust" "tui" "fast") consuming 5 slots. The wasted
#     slot's lost discovery potential is irreversible —
#     crates.io's search index treats the duplicate as a single
#     match.
#
#   - crates.io's publish validator MIGHT silently dedupe
#     during ingest (the behavior isn't documented for
#     consistency). When it doesn't dedupe, the displayed
#     keywords list shows the dup verbatim — looks sloppy on
#     the crate card.
#
#   - cargo-crate registry exports include the duplicate
#     entry, which downstream tooling (vulnerability scanners,
#     org-wide dep dashboards) may double-count when computing
#     keyword frequencies.
#
# Detection: extract keywords array, count distinct vs total
# entries.
#
# Pairs with iter-keywords-conformant (shape + max-5
# enforcement) and iter-keywords-categories (presence of both
# fields). Three gates now cover the keywords field:
#   - Presence (existing)
#   - Shape validity (existing)
#   - Within-array uniqueness (iter-153 this gate)
#
# 11/11 keyword arrays green at iter-153 add — pure
# regression floor against copy-paste duplicate during
# keyword refresh.
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
m = re.search(r'(?m)^keywords\s*=\s*\[([^\]]+)\]', content)
if not m:
    print("NO_KEYWORDS")
    sys.exit()
kws = re.findall(r'"([^"]+)"', m.group(1))
if not kws:
    print("NO_KEYWORDS")
    sys.exit()
dups = sorted({k for k in kws if kws.count(k) > 1})
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
        NO_KEYWORDS) continue ;;
        OK)
            checked=$((checked + 1))
            echo "PASS  $cargo: keywords are unique"
            ;;
        BAD:*)
            checked=$((checked + 1))
            echo "FAIL  $cargo: duplicate keywords: ${output#BAD:}"
            bad=$((bad + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked keyword arrays checked, $bad with duplicates"

[[ $ok -eq 1 ]] && exit 0 || exit 1
