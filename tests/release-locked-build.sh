#!/usr/bin/env bash
# For every Rust-shipping submodule with a release.yml, pin that the
# release build invokes `cargo build --locked` (or `cargo build` with
# a CARGO_BUILD_LOCKED env, or test --locked / install --locked).
#
# `--locked` refuses to update Cargo.lock at build time. Without it,
# `cargo build` in CI silently rolls forward transitive deps between
# tag-cut and rebuild, producing UNREPRODUCIBLE release tarballs.
# A user `brew install`ing v1.2.3 today might get different transitive
# crate versions than the same `brew install` next week, even from
# the SAME upstream Cargo.toml — depending on when the release was
# rebuilt and what was in the registry at that moment.
#
# Library crates without a binary aren't in scope (their consumers
# pin via their own Cargo.lock).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

# Detect submodules-initialized state
init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
missing_locked=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    # Skip non-Rust repos
    [[ -f "$p/Cargo.toml" || -f "$p/src-tauri/Cargo.toml" ]] || continue
    # Skip the tap repo
    [[ "$p" == "homebrew-menketech" ]] && continue
    # Skip stryke-* connectors (libraries, not binaries)
    [[ "$p" == stryke-* ]] && continue

    rel="$p/.github/workflows/release.yml"
    [[ -f "$rel" ]] || continue
    checked=$((checked + 1))

    # Look for any cargo build/test/install line and verify --locked appears
    # on at least one such line. We don't insist on every cargo line being
    # --locked (some test/lint paths legitimately mutate Cargo.lock); the
    # canonical RELEASE build line is what matters.
    if grep -qE 'cargo (build|install|test) [^|&\n]*--locked' "$rel"; then
        echo "PASS  $p: release.yml uses cargo --locked"
    elif grep -qE 'CARGO_BUILD_LOCKED|CARGO_TERM_LOCKED' "$rel"; then
        echo "PASS  $p: release.yml sets CARGO_BUILD_LOCKED env"
    else
        echo "FAIL  $p: release.yml runs cargo but never uses --locked — release builds will silently roll deps forward"
        missing_locked=$((missing_locked + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked release.yml files checked, $missing_locked missing --locked discipline"

[[ $ok -eq 1 ]] && exit 0 || exit 1
