#!/usr/bin/env bash
# For every Rust Cargo.toml that declares `[[bin]]` entries with
# an explicit `path = "..."`, pin that the referenced source file
# actually exists on disk.
#
# Cargo's `[[bin]]` table accepts `path = "src/bin/foo.rs"`,
# `path = "src/main.rs"`, or any custom location. If the file is
# renamed or moved without updating Cargo.toml — or if Cargo.toml
# is edited to point at a typo'd path — `cargo build` fails with
# "could not find source file" only at build time, which is the
# slowest possible feedback loop.
#
# This gate catches the drift before `cargo build` does, with
# zero compilation cost: just stat the path. Catches:
#
#   - Renamed src/bin/foo.rs → src/bin/bar.rs without editing
#     Cargo.toml (cargo errors but only on full build)
#   - Typo in Cargo.toml's path = "src/bin/foobar.rs" → "src/bin/foboar.rs"
#   - Deleted bin source without removing the [[bin]] entry
#   - Workspace pattern: bin entry pointing at a path that lives
#     in a sibling crate (broken workspace-rooted relative path)
#
# Resolves paths RELATIVE to the directory containing Cargo.toml
# (Cargo's own resolution rule). For Tauri apps with
# src-tauri/Cargo.toml, paths resolve relative to src-tauri/.
#
# 37/37 [[bin]] path entries green across the umbrella at
# iter-59 add — pure regression floor.
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
missing=0

# Extract every `path = "..."` line within a `[[bin]]` block.
# Stops accumulating when entering any other section header.
extract_bin_paths() {
    awk '
        /^\[\[bin\]\]/ { in_bin = 1; next }
        /^\[/          { in_bin = 0 }
        in_bin && /^path *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
        }
    ' "$1"
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    pkg_dir=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"; pkg_dir="$p"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"; pkg_dir="$p/src-tauri"
    fi
    [[ -n "$cargo" ]] || continue

    while IFS= read -r bin_path; do
        [[ -n "$bin_path" ]] || continue
        checked=$((checked + 1))
        full="$pkg_dir/$bin_path"
        if [[ ! -f "$full" ]]; then
            echo "FAIL  $cargo: [[bin]] path=\"$bin_path\" → $full does not exist"
            missing=$((missing + 1))
            ok=0
        else
            echo "PASS  $cargo: [[bin]] path=\"$bin_path\""
        fi
    done < <(extract_bin_paths "$cargo")
done

echo "---"
echo "Summary: $checked [[bin]] path entries checked, $missing pointing at missing files"

[[ $ok -eq 1 ]] && exit 0 || exit 1
