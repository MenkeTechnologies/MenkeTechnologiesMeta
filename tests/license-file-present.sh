#!/usr/bin/env bash
# For every Rust submodule that declares `license = "MIT"` (or any
# non-empty license string) in Cargo.toml, pin that a LICENSE / LICENSE.md /
# license.md file exists in the repo root.
#
# crates.io / cargo doc / GitHub all expect the license-string in
# Cargo.toml to be backed by an actual LICENSE file. A repo that
# claims "MIT" in Cargo.toml but ships no license text technically
# violates the MIT license itself (the license requires the notice
# to be included with the distribution). It also generates a "no
# license file detected" warning at `cargo package` time.
#
# Catches: new Rust submodule added with Cargo.toml from a template
# but the LICENSE file forgotten; LICENSE file deleted during a
# refactor.
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

has_license_file() {
    local dir="$1"
    # Single-file forms.
    for f in LICENSE LICENSE.md LICENSE.txt License License.md license license.md COPYING COPYING.txt; do
        [[ -f "$dir/$f" ]] && return 0
    done
    # Dual-license naming (used by `license = "MIT OR Apache-2.0"` repos):
    # LICENSE-MIT + LICENSE-APACHE are commonly shipped as separate files
    # so each license text is independently referenceable.
    if [[ -f "$dir/LICENSE-MIT" || -f "$dir/LICENSE-APACHE" ]]; then
        return 0
    fi
    return 1
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    # Identify the canonical Cargo.toml that declares license=. Falls
    # through to src-tauri/ when top-level Cargo.toml is a workspace
    # root with no [package] license field (Audio-Haxor pattern —
    # caught iter 37: workspace-root Cargo.toml has no license,
    # src-tauri/Cargo.toml has license="MIT", and the old logic
    # exited at the workspace root without ever finding the license
    # declaration).
    cargo=""
    lic=""
    for candidate in "$p/Cargo.toml" "$p/src-tauri/Cargo.toml"; do
        [[ -f "$candidate" ]] || continue
        v=$(grep -m1 -E '^license[[:space:]]*=[[:space:]]*"' "$candidate" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
        if [[ -n "$v" ]]; then
            cargo="$candidate"
            lic="$v"
            break
        fi
    done
    if [[ -z "$lic" ]]; then
        # Some workspace-root Cargo.toml files don't have [package] / license —
        # the license lives in each member. Skip informationally.
        continue
    fi

    checked=$((checked + 1))
    if has_license_file "$p"; then
        echo "PASS  $p: Cargo license=\"$lic\" + LICENSE file present"
    else
        echo "FAIL  $p: Cargo license=\"$lic\" but no LICENSE/LICENSE.md/COPYING file at repo root"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked submodules with license= in Cargo.toml, $missing missing LICENSE file"

[[ $ok -eq 1 ]] && exit 0 || exit 1
