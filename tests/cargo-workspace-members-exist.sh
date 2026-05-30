#!/usr/bin/env bash
# For every Cargo.toml that declares a `[workspace]` section, pin
# that each entry in `members = [...]` refers to a directory
# that exists AND contains its own Cargo.toml.
#
# Cargo's workspace resolver walks the members list at every
# command (`cargo build`, `cargo test`, `cargo metadata`). A
# stale entry that no longer points at a valid sub-crate fails
# with:
#
#   error: failed to load manifest for workspace member
#   `./foo`
#   caused by: failed to read `./foo/Cargo.toml`
#   caused by: No such file or directory (os error 2)
#
# Failure mode: dormant until the next `cargo build`. The
# workspace-level metadata commands (`cargo metadata`,
# `cargo tree`) hit it instantly but normal IDE / rust-analyzer
# usage typically doesn't surface the error until the editor
# is restarted.
#
# Drift caught:
#   - Rename a sub-crate directory without updating members
#   - Delete a sub-crate directory without removing its entry
#   - Typo in members entry (e.g. "src-trauri" instead of
#     "src-tauri")
#   - members entry pointing at a directory that lacks
#     Cargo.toml (left only as a docs/scripts dir)
#
# Glob patterns in members (`"crates/*"`) are SKIPPED — they
# resolve at runtime and may legitimately match zero entries
# during early-stage workspace construction.
#
# 11/11 workspace member paths green at iter-72 add — pure
# regression floor.
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

# Extract every entry from `members = [...]` in [workspace].
# Handles single-line and multi-line array forms.
extract_members() {
    awk '
        /^\[workspace\]/        { in_ws = 1; next }
        /^\[/ && !/^\[workspace/ { in_ws = 0 }
        in_ws && /^members *= *\[/ { in_m = 1 }
        in_m {
            # collect all quoted entries from current line
            line = $0
            while (match(line, /"[^"]+"/)) {
                print substr(line, RSTART + 1, RLENGTH - 2)
                line = substr(line, RSTART + RLENGTH)
            }
            if (line ~ /\]/) { in_m = 0 }
        }
    ' "$1"
}

checked=0
missing=0
skipped_glob=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    for cargo in "$p/Cargo.toml" "$p/src-tauri/Cargo.toml"; do
        [[ -f "$cargo" ]] || continue
        grep -qE '^\[workspace\]' "$cargo" || continue

        pkg_dir="$(dirname "$cargo")"

        while IFS= read -r m; do
            [[ -n "$m" ]] || continue
            case "$m" in
                *\**) skipped_glob=$((skipped_glob + 1)); continue ;;
            esac
            checked=$((checked + 1))

            mdir="$pkg_dir/$m"
            if [[ ! -d "$mdir" ]]; then
                echo "FAIL  $cargo: workspace member \"$m\" → $mdir does not exist"
                missing=$((missing + 1))
                ok=0
            elif [[ ! -f "$mdir/Cargo.toml" ]]; then
                echo "FAIL  $cargo: workspace member \"$m\" → $mdir exists but has no Cargo.toml"
                missing=$((missing + 1))
                ok=0
            else
                echo "PASS  $cargo: workspace member \"$m\""
            fi
        done < <(extract_members "$cargo")
    done
done

echo "---"
echo "Summary: $checked workspace members checked ($skipped_glob glob entries skipped), $missing missing"

[[ $ok -eq 1 ]] && exit 0 || exit 1
