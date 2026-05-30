#!/usr/bin/env bash
# For every publishable Rust submodule, pin that the package
# Cargo.toml has an explicit `documentation` field. crates.io
# defaults the documentation link to docs.rs/<name> when the field
# is absent, but making it explicit:
#   - surfaces correctly in `cargo metadata` consumers
#   - lets repos override to ship hosted prose docs (e.g. GH Pages)
#     instead of just rustdoc API reference
#   - catches typos / copy-paste errors at PR time (real-world case:
#     zshrs's documentation pointed at strykelang/zshrs.html through
#     a copy-paste error before iter 29 caught it)
#
# Accepts:
#   - https://docs.rs/<crate-name> (preferred default — auto-rendered
#     rustdoc on every crates.io publish)
#   - https://menketechnologies.github.io/<repo>/ (acceptable when the
#     repo ships hand-curated docs that complement docs.rs)
#   - Other https URLs that look MenkeTechnologies-attributable
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
wrong=0
skipped=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    # Skip publish=false crates (Tauri apps + stryke-* connectors).
    if grep -qE '^publish *= *false' "$cargo"; then
        skipped=$((skipped + 1))
        continue
    fi

    checked=$((checked + 1))
    submodule_name="${p##*/}"

    doc=$(grep -m1 -E '^documentation *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')

    if [[ -z "$doc" ]]; then
        echo "FAIL  $cargo: no documentation field — crates.io shows the default docs.rs/<name> link, but explicit is better for cargo metadata consumers + lets repo opt into a hosted prose docs URL"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    # Strict path validation: the URL path component must start with
    # the crate or submodule name. Catches the real iter-29 case where
    # zshrs/Cargo.toml had documentation =
    # "https://menketechnologies.github.io/strykelang/zshrs.html" —
    # the substring "zshrs" was present but the PATH PREFIX was
    # /strykelang/ from copy-paste.
    pkg_name=$(awk '/^\[package\]/{in_p=1} in_p && /^name *= *"/{match($0,/"[^"]*"/); print substr($0,RSTART+1,RLENGTH-2); exit}' "$cargo")
    case "$doc" in
        "https://docs.rs/$pkg_name"|"https://docs.rs/$pkg_name/"*|"https://docs.rs/$submodule_name"|"https://docs.rs/$submodule_name/"*)
            echo "PASS  $cargo: documentation = $doc"
            ;;
        "https://menketechnologies.github.io/$pkg_name"|"https://menketechnologies.github.io/$pkg_name/"*|"https://menketechnologies.github.io/$submodule_name"|"https://menketechnologies.github.io/$submodule_name/"*)
            echo "PASS  $cargo: documentation = $doc"
            ;;
        *)
            echo "FAIL  $cargo: documentation = '$doc' — path doesn't start with crate ($pkg_name) or submodule ($submodule_name) name; likely a copy-paste error from a sibling"
            wrong=$((wrong + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked publishable crates checked, $skipped skipped (publish=false), $missing without documentation, $wrong with wrong-crate URL"

[[ $ok -eq 1 ]] && exit 0 || exit 1
