#!/usr/bin/env bash
# For every Cargo.toml `exclude = [...]` and `include = [...]`
# array, pin that every entry is unique within the array.
#
# Fourth member of the cargo array-uniqueness family after
# iter-153 (keywords), iter-154 (categories), iter-155
# (authors). Same pattern, applied to the publish-shape
# fields.
#
# Why uniqueness matters for exclude/include:
#
#   - Duplicates waste manifest bytes; the resolver walks
#     the list once per entry to test glob matches, so a
#     duplicate doubles the per-file match cost.
#   - cargo publish includes the duplicate in the published
#     crate's manifest; downstream consumers reading the
#     manifest see the redundant entry.
#   - Hand-edited exclude lists during cargo-publish package
#     trimming are the common drift source: adding a new
#     path without checking if it was already excluded.
#   - For include lists (used as a WHITELIST against include
#     semantics), a duplicate suggests the author was
#     uncertain and added the same path twice for safety —
#     a code smell that the include set wasn't reviewed
#     intentionally.
#
# Detection: extract exclude / include arrays via regex,
# compare len(items) vs len(set(items)). Report which entries
# appear more than once.
#
# Known drift allowlist:
#   - strykelang/Cargo.toml exclude has `/.github/` listed
#     twice. Sibling-repo drift; can't fix from meta per the
#     meta-only scope rule. Fix is `sed -i 's|, "/\.github/"||'`
#     applied to strykelang/Cargo.toml from the strykelang
#     repo. Allowlist entry to be removed when fixed.
#
# 5/5 exclude arrays — 1 expected fail (strykelang), 4 PASS.
# 0/0 include arrays.
#
# Net coverage: 4/5 PASS, 1 allowlisted-known-drift.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

# Known-drift allowlist. Each entry is "Cargo.toml-path:field".
# When the drift is fixed in the sibling repo, remove the entry
# and ratchet the gate up.
declare -A KNOWN_DRIFT=(
    [strykelang/Cargo.toml:exclude]="duplicate `/.github/` entry; meta-only scope blocks fix"
)

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
known_drift=0

audit_one() {
    python3 - "$1" "$2" << 'PY'
import sys, re
cargo = sys.argv[1]
field = sys.argv[2]
content = open(cargo).read()
m = re.search(rf'(?ms)^{field}\s*=\s*\[([^\]]+)\]', content)
if not m:
    print("NO_FIELD")
    sys.exit()
items = re.findall(r'"([^"]+)"', m.group(1))
if not items:
    print("NO_FIELD")
    sys.exit()
dups = sorted({i for i in items if items.count(i) > 1})
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

    for field in exclude include; do
        output=$(audit_one "$cargo" "$field")
        case "$output" in
            NO_FIELD) continue ;;
            OK)
                checked=$((checked + 1))
                echo "PASS  $cargo: $field entries unique"
                ;;
            BAD:*)
                checked=$((checked + 1))
                key="$cargo:$field"
                if [[ -n "${KNOWN_DRIFT[$key]:-}" ]]; then
                    echo "WARN  $cargo: $field has duplicate ${output#BAD:} — ALLOWLISTED (${KNOWN_DRIFT[$key]})"
                    known_drift=$((known_drift + 1))
                else
                    echo "FAIL  $cargo: $field has duplicate ${output#BAD:}"
                    bad=$((bad + 1))
                    ok=0
                fi
                ;;
        esac
    done
done

echo "---"
echo "Summary: $checked arrays checked, $bad with un-allowlisted duplicates, $known_drift known-drift allowlisted"

[[ $ok -eq 1 ]] && exit 0 || exit 1
