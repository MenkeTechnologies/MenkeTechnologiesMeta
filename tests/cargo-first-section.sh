#!/usr/bin/env bash
# For every Cargo.toml, pin that the FIRST section header is
# either `[package]` or `[workspace]`.
#
# This is a readability + tooling convention:
#
#   - Human reviewers expect manifest identity (name, version,
#     edition, license, description) AT THE TOP. Scrolling past
#     `[dependencies]` to find the package name is friction.
#   - Cargo's own `cargo new` template puts [package] first.
#     The convention is universal across crates.io's published
#     manifests.
#   - IDE Cargo.toml plugins (rust-analyzer's project picker,
#     RustRover's manifest tree) parse the first section to
#     identify the crate. Out-of-order manifests render with
#     "(unknown crate)" labels until rust-analyzer indexes the
#     whole file.
#   - Diff tools show the first hunk most prominently. Putting
#     package metadata first means PR diffs that touch metadata
#     are immediately recognizable.
#
# Workspace-only manifests (a top-level Cargo.toml that
# declares ONLY `[workspace]` with no `[package]`) are
# legitimate and accepted — for the umbrella's case, that's
# the traderview workspace root.
#
# 27/27 Cargo.toml files green at iter-109 add — pure
# regression floor against accidental reordering during a
# manual rewrite.
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
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    for cargo in "$p/Cargo.toml" "$p/src-tauri/Cargo.toml"; do
        [[ -f "$cargo" ]] || continue
        # Find first section header line.
        first=$(grep -m1 -E '^\[' "$cargo" | head -1)
        [[ -n "$first" ]] || continue
        checked=$((checked + 1))

        case "$first" in
            \[package\]|\[workspace\]|\[workspace.*)
                echo "PASS  $cargo: first section is $first"
                ;;
            *)
                echo "FAIL  $cargo: first section is $first — should be [package] or [workspace]"
                bad=$((bad + 1))
                ok=0
                ;;
        esac
    done
done

echo "---"
echo "Summary: $checked Cargo.toml files checked, $bad with non-canonical first section"

[[ $ok -eq 1 ]] && exit 0 || exit 1
