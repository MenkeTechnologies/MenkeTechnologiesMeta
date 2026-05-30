#!/usr/bin/env bash
# For every Rust binary-shipping submodule README that makes an
# explicit binary-count claim (e.g. "5-binary suite: foo / bar / ..."
# or "ships 3 binaries"), pin that the claimed count matches the
# Cargo.toml [[bin]] count.
#
# Catches the iter-9 powerliners case where the README's binary table
# listed a "powerliners" binary that had been DROPPED in v0.1.1
# (commit 9d697d8a56) but the README wasn't refreshed. Users
# copy-pasting from the README hit `command not found` after
# `brew install powerliners`. Without this gate, the next iteration
# would have to spot the gap manually again.
#
# Two pattern shapes detected:
#   "N-binary suite" / "N binary"            — explicit count
#   "binaries: foo, bar, baz"                — list of names
#
# When both forms are present, both are validated against Cargo.
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

# Get Cargo.toml [[bin]] names for a submodule.
cargo_bins() {
    local cargo="$1"
    [[ -f "$cargo" ]] || return 1
    awk '
        /^\[\[bin\]\]/ { in_bin = 1; next }
        /^\[/          { in_bin = 0 }
        in_bin && /^name *= *"/ {
            match($0, /"[^"]*"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            in_bin = 0
        }
    ' "$cargo"
}

checked=0
mismatched=0
no_claim=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -f "$p/README.md" ]] || continue
    cargo="$p/Cargo.toml"
    [[ -f "$cargo" ]] || continue
    grep -qE '^\[\[bin\]\]' "$cargo" || continue

    declared=$(cargo_bins "$cargo" | sort -u)
    declared_n=$(printf '%s\n' "$declared" | grep -c .)

    # Find an explicit N-binary count claim. Strict shapes only, to
    # avoid false positives from "Perl 5 binary-protocol" or "Python
    # 3 binary cache" style phrases:
    #   "N-binary" (hyphenated, suite-style — e.g. "5-binary suite")
    #   "ships N binaries" / "the N binaries" / "N binaries:" (plural)
    # The singular "N binary" (without hyphen and without plural -ies)
    # is too ambiguous — too many false positives in prose.
    claimed_n=$(grep -oE '[0-9]+-binary|ships [0-9]+ binaries|the [0-9]+ binaries|[0-9]+ binaries:' "$p/README.md" \
                | grep -oE '[0-9]+' \
                | sort -u)

    if [[ -z "$claimed_n" ]]; then
        no_claim=$((no_claim + 1))
        continue
    fi

    checked=$((checked + 1))
    failed=0
    for n in $claimed_n; do
        if [[ "$n" != "$declared_n" ]]; then
            echo "FAIL  $p/README.md: claims '$n binary/binaries' but Cargo.toml has $declared_n [[bin]] entries [$declared]"
            failed=1
        fi
    done
    if [[ $failed -eq 0 ]]; then
        echo "PASS  $p/README.md: $claimed_n-binary claim matches Cargo.toml [$declared]"
    else
        mismatched=$((mismatched + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked READMEs with explicit binary-count claim checked, $no_claim with no claim (skipped), $mismatched with mismatched count"

[[ $ok -eq 1 ]] && exit 0 || exit 1
