#!/usr/bin/env bash
# For every Rust submodule with a Cargo.toml version field, pin that
# `Cargo.toml.version >= latest git tag` (semver-wise).
#
# Three states:
#   cargo == tag: just-released or no dev work in flight (PASS)
#   cargo > tag:  dev cycle in progress, next release will tag the
#                 current Cargo version (INFO — surfaced but not failed)
#   cargo < tag:  regression — someone reverted Cargo.toml below
#                 the latest published version, breaking semver
#                 monotonicity. Downstream consumers expecting cargo
#                 == tag would get an older version than the tag
#                 suggests, and a subsequent cargo publish would
#                 attempt to re-publish an old version (crates.io
#                 rejects duplicate version uploads, so the release
#                 workflow would silently fail). FAIL.
#
# Skips repos with no tags yet (pre-1.0 dev, no released version
# to compare against).
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

# Compare two semver strings X.Y.Z lexically by field.
# Returns 0 if $1 > $2, 1 if equal, 2 if $1 < $2.
semver_cmp() {
    local IFS=.
    # shellcheck disable=SC2206 # intentional IFS-based field split
    local -a a=($1) b=($2)
    local i
    for ((i = 0; i < ${#a[@]} || i < ${#b[@]}; i++)); do
        local av="${a[i]:-0}"
        local bv="${b[i]:-0}"
        # Strip any prerelease suffix like "-dev" / "-rc1" for comparison.
        av="${av%%-*}"
        bv="${bv%%-*}"
        if (( 10#$av > 10#$bv )); then return 0; fi
        if (( 10#$av < 10#$bv )); then return 2; fi
    done
    return 1
}

checked=0
regressed=0
ahead=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    cargo_v=$(grep -m1 -E '^version *= *"' "$cargo" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$cargo_v" ]] || continue

    # Get latest semver-shaped tag in this submodule.
    tag=$(git -C "$p" describe --tags --abbrev=0 --match 'v*' 2>/dev/null) || true
    if [[ -z "$tag" ]]; then
        echo "INFO  $p: Cargo $cargo_v but no v* tags yet (pre-release dev)"
        continue
    fi

    tag_v="${tag#v}"
    checked=$((checked + 1))

    if semver_cmp "$cargo_v" "$tag_v"; then
        # cargo > tag — dev cycle in progress.
        echo "INFO  $p: Cargo $cargo_v > tag $tag (dev cycle; next release will tag $cargo_v)"
        ahead=$((ahead + 1))
    else
        case "$?" in
            1) echo "PASS  $p: Cargo $cargo_v == tag $tag (just-released or quiescent)" ;;
            2) echo "FAIL  $p: Cargo $cargo_v < tag $tag — REGRESSION. crates.io rejects re-uploading an older version; the release workflow would silently fail. Did a downgrade slip through?"
               regressed=$((regressed + 1))
               ok=0 ;;
        esac
    fi
done

echo "---"
echo "Summary: $checked Rust crates checked, $ahead with dev-cycle ahead, $regressed regressed below latest tag"

[[ $ok -eq 1 ]] && exit 0 || exit 1
