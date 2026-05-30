#!/usr/bin/env bash
# For every publishable Rust submodule, report whether large
# dev-only directories (docs/, tests/, benches/, vendor/, parity/,
# .github/) exist AND aren't in the Cargo.toml `exclude` list.
#
# Without an explicit exclude, `cargo publish` ships everything
# `git ls-files` matches. A repo with 100 MB of vendored sources
# under vendor/ publishes a 100 MB .crate file — bloats crates.io's
# storage, slows downstream `cargo install`, and burns the user's
# bandwidth for zero functional benefit.
#
# This test is INFORMATIONAL: it WARN-reports dev dirs that exist
# without being excluded, but doesn't fail CI. Reason: "right
# exclude set" is opinionated (examples/ is sometimes wanted for
# downstream rustdoc), and forcing a one-size-fits-all rule would
# create churn without proportionate value. The signal is "here's
# what's bloating your .crate file; decide if you want to exclude."
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit

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

# Dev dirs that should usually be excluded from a published crate.
DEV_DIRS=(docs tests benches vendor parity .github fuzz)

checked=0
total_bloat=0
total_clean=0

# Extract the exclude list from a Cargo.toml as a newline-delimited
# blob. Handles single-line `exclude = ["a", "b"]` and multi-line
# `exclude = [\n  "a",\n  "b",\n]` forms.
extract_exclude() {
    local cargo="$1"
    awk '
        /^exclude *=/      { in_excl = 1 }
        in_excl {
            buf = buf $0
            if ($0 ~ /\]/) { in_excl = 0 }
        }
        END {
            while (match(buf, /"[^"]+"/)) {
                entry = substr(buf, RSTART + 1, RLENGTH - 2)
                gsub(/^\//, "", entry)
                gsub(/\/$/, "", entry)
                print entry
                buf = substr(buf, RSTART + RLENGTH)
            }
        }
    ' "$cargo"
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

    # Skip publish=false crates — they never go to crates.io so bloat
    # is irrelevant.
    if grep -qE '^publish *= *false' "$cargo"; then
        continue
    fi

    checked=$((checked + 1))

    excluded=$(extract_exclude "$cargo")

    bloat=""
    for d in "${DEV_DIRS[@]}"; do
        [[ -d "$p/$d" ]] || continue
        if ! grep -Fxq "$d" <<< "$excluded"; then
            bloat="$bloat $d"
        fi
    done

    if [[ -z "$bloat" ]]; then
        echo "CLEAN $p: no unexcluded dev dirs"
        total_clean=$((total_clean + 1))
    else
        # Compute approx size of unexcluded dirs (informational). Build
        # the full-path list so du operates from the meta repo root.
        full_paths=""
        for d in $bloat; do
            full_paths="$full_paths $p/$d"
        done
        # shellcheck disable=SC2086  # full_paths is intentionally word-split
        sz_kb=$(du -sk $full_paths 2>/dev/null | awk 'BEGIN{t=0} {t+=$1} END{printf "%d", t}')
        sz_mb=$(( sz_kb / 1024 ))
        echo "INFO  $p: would publish [$bloat ] — ~${sz_mb} MB bloat in .crate file"
        total_bloat=$((total_bloat + 1))
    fi
done

echo "---"
echo "Summary: $checked publishable crates audited, $total_clean clean, $total_bloat with unexcluded dev dirs (informational)"

# This test is informational only — never fails CI.
exit 0
