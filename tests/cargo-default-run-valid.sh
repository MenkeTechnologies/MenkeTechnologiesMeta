#!/usr/bin/env bash
# For every Cargo.toml that declares `default-run = "<name>"` in
# its [package] section, pin that the value matches a real
# [[bin]] entry's name.
#
# `default-run` controls which binary `cargo run` (without
# `--bin <name>`) executes when a crate has multiple binaries.
# Cargo's rule: must match a [[bin]] table's `name = "..."` field
# (or the implicit `name = <package-name>` for crates with
# src/main.rs).
#
# Drift catches:
#   - Rename a [[bin]] (`name = "foo"` → `name = "foo-cli"`)
#     without updating `default-run = "foo"` → "foo-cli"
#   - Add `default-run` pointing at a bin that was later removed
#   - Typo in default-run value
#
# All three fail at `cargo run` time with:
#
#   error: a bin target must be available for `cargo run`
#
# which the test suite (`cargo test`) doesn't surface — only an
# explicit `cargo run` does. So the drift sits dormant until
# someone hits the workflow that runs the binary directly.
#
# 2/2 Cargo.toml files with default-run set green at iter-70
# add — pure regression floor.
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

extract_default_run() {
    awk '
        /^\[package\]/ { in_p = 1; next }
        /^\[/          { in_p = 0 }
        in_p && /^default-run *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
        }
    ' "$1"
}

extract_bin_names() {
    awk '
        /^\[\[bin\]\]/                          { in_bin = 1; next }
        /^\[/ && !/^\[\[bin\]\]/                { in_bin = 0 }
        in_bin && /^name *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
        }
    ' "$1"
}

extract_package_name() {
    awk '
        /^\[package\]/ { in_p = 1; next }
        /^\[/          { in_p = 0 }
        in_p && /^name *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
        }
    ' "$1"
}

checked=0
bad=0

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

    dr=$(extract_default_run "$cargo")
    [[ -n "$dr" ]] || continue
    checked=$((checked + 1))

    bin_names=$(extract_bin_names "$cargo")
    # Implicit bin name: if src/main.rs exists, the package name
    # itself is a valid bin name even without an explicit [[bin]]
    # entry.
    pkg_name=$(extract_package_name "$cargo")
    if [[ -f "$pkg_dir/src/main.rs" && -n "$pkg_name" ]]; then
        bin_names="$bin_names
$pkg_name"
    fi

    if echo "$bin_names" | grep -qFx "$dr"; then
        echo "PASS  $cargo: default-run=\"$dr\" matches a bin"
    else
        flat=$(echo "$bin_names" | grep -v '^$' | tr '\n' ' ')
        echo "FAIL  $cargo: default-run=\"$dr\" but available bins: $flat"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml files with default-run checked, $bad referencing unknown bin"

[[ $ok -eq 1 ]] && exit 0 || exit 1
