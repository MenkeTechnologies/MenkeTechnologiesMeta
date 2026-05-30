#!/usr/bin/env bash
# For every Rust submodule with a Cargo.toml `exclude` list, pin that
# every directory entry in the list references a real directory in
# the working tree.
#
# Stale exclude entries are common after refactors: someone removes
# a `parity/` or `bench/` directory but forgets to drop the matching
# exclude entry. The exclude still "works" (cargo silently ignores
# patterns that don't match anything), but signals stale intent.
# Worse, `cargo publish` emits warnings about non-matching exclude
# entries which look noisy on the publish log.
#
# Test scope: only directory-shaped entries (starting/ending with /).
# Glob patterns like *.png and file paths like Cargo.toml are not
# checked — those are conventional file patterns, not dir references.
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

# Extract all "..."-quoted strings from the exclude array (handles
# single-line and multi-line array forms).
extract_exclude_entries() {
    local cargo="$1"
    awk '
        /^exclude *=/ { in_excl = 1 }
        in_excl {
            buf = buf $0
            if ($0 ~ /\]/) in_excl = 0
        }
        END {
            while (match(buf, /"[^"]+"/)) {
                print substr(buf, RSTART + 1, RLENGTH - 2)
                buf = substr(buf, RSTART + RLENGTH)
            }
        }
    ' "$cargo"
}

# Entry shape: a directory reference must END with `/` (the trailing
# slash is what makes it a dir per gitignore-style conventions).
# Just starting with `/` isn't enough — `/foo.*` is a glob pattern,
# not a dir. Skip entries with glob chars (`*`, `?`, `[`) entirely
# even if they end with `/`.
is_dir_entry() {
    local entry="$1"
    case "$entry" in
        *'*'*|*'?'*|*'['*) return 1 ;;  # glob pattern
        */)                return 0 ;;  # ends with /
        *)                 return 1 ;;
    esac
}

checked=0
stale=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    entries=$(extract_exclude_entries "$cargo")
    [[ -n "$entries" ]] || continue

    checked=$((checked + 1))
    stale_here=""
    while IFS= read -r entry; do
        [[ -z "$entry" ]] && continue
        is_dir_entry "$entry" || continue
        # Strip leading / for resolution under $p.
        rel="${entry#/}"
        rel="${rel%/}"
        if [[ ! -d "$p/$rel" ]]; then
            stale_here="$stale_here $entry"
        fi
    done <<< "$entries"

    if [[ -z "$stale_here" ]]; then
        n=$(printf '%s\n' "$entries" | grep -c .)
        echo "PASS  $cargo: $n exclude entries, all reference real dirs"
    else
        echo "FAIL  $cargo: stale exclude entries:$stale_here"
        stale=$((stale + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml files with exclude lists checked, $stale with stale entries"

[[ $ok -eq 1 ]] && exit 0 || exit 1
