#!/usr/bin/env bash
# For every Cargo.toml [package].version field, pin that the
# value does NOT start with `v` followed by a digit.
#
# Cargo-side mirror of iter-165 (brew formula version
# v-prefix). Cargo's semver parser REJECTS v-prefixed
# version strings at build time:
#
#   error: failed to parse the version requirement `v0.1.0`
#   for dependency `foo`
#
# The `v` belongs in the GIT TAG and crates.io's
# `/crates/<name>/<version>` URL renders WITHOUT the prefix.
# The Cargo.toml `version` field is the bare semver triple.
#
# Cargo's own rejection catches this at build time, but the
# error message is generic ("failed to parse version
# requirement") and points at the consumer, not the producer.
# When `version = "v0.1.0"` is in YOUR crate's manifest, the
# error fires in EVERY downstream consumer's build — making
# the producer-side fix harder to trace.
#
# Detection: regex `^v[0-9]` on the version string extracted
# from [package].version. Workspace-inherited versions
# (version.workspace = true) are walked separately by
# iter-122; their workspace-root [workspace.package].version
# is the actual value to check, which is also handled by
# this gate when the workspace root is in the scan path.
#
# 25/25 crates with explicit version green at iter-166 add —
# pure regression floor.
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

extract_version() {
    awk '
        /^\[package\]/         { in_p = 1; next }
        /^\[workspace\.package\]/ { in_w = 1; next }
        /^\[/                  { in_p = 0; in_w = 0 }
        (in_p || in_w) && /^version *= *"/ {
            match($0, /"[^"]+"/)
            print substr($0, RSTART + 1, RLENGTH - 2)
            exit
        }
    ' "$1"
}

checked=0
v_prefix=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    ver=$(extract_version "$cargo")
    [[ -n "$ver" ]] || continue
    checked=$((checked + 1))

    if [[ "$ver" =~ ^v[0-9] ]]; then
        echo "FAIL  $cargo: version=\"$ver\" has v-prefix — Cargo's semver parser rejects this"
        v_prefix=$((v_prefix + 1))
        ok=0
    else
        echo "PASS  $cargo: version=\"$ver\""
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml versions checked, $v_prefix with v-prefix"

[[ $ok -eq 1 ]] && exit 0 || exit 1
