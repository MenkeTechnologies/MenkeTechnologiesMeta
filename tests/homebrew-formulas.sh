#!/usr/bin/env bash
# Pins quality invariants on the homebrew-menketech tap formulas so a
# broken auto-bump (zero sha256, mismatched url version, stale install
# block) can't silently ship and cause `brew install` to fail or — worse —
# pull a placeholder tarball.
#
# This catches the exact failure mode seen 2026-05-29 with powerliners
# (HOMEBREW_TAP_TOKEN expired → formula stuck at v0.0.6 with sha256 =
# 64 zeros, while the actual release was at v0.1.1; brew install would
# 404 on the URL or fail digest verification).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

tap="homebrew-menketech/Formula"
if [[ ! -d "$tap" ]]; then
    echo "SKIP  $tap not initialized (submodule not checked out)"
    exit 0
fi

n=$(ls "$tap"/*.rb 2>/dev/null | wc -l | tr -d ' ')
if [[ $n -eq 0 ]]; then
    echo "FAIL  no formulas under $tap/"
    exit 1
fi
echo "PASS  $n formulas under $tap/"

ZERO_SHA="0000000000000000000000000000000000000000000000000000000000000000"

for f in "$tap"/*.rb; do
    name=$(basename "$f" .rb)

    # `version "X.Y.Z"` must appear and parse as semver-ish
    ver=$(grep -E '^[[:space:]]+version[[:space:]]+"' "$f" | head -1 | grep -oE '"[^"]+"' | tr -d '"')
    if [[ -z "$ver" ]]; then
        echo "FAIL  $name has no version field"
        ok=0
        continue
    fi
    case "$ver" in
        [0-9]*.[0-9]*.[0-9]*) :;;
        *)
            echo "FAIL  $name version '$ver' isn't semver-shaped"
            ok=0
            ;;
    esac

    # Every sha256 line must NOT be 64 zeros (placeholder from a broken
    # auto-bump where the workflow couldn't push to the tap).
    while IFS= read -r sum; do
        if [[ "$sum" == "$ZERO_SHA" ]]; then
            echo "FAIL  $name has placeholder sha256 (release workflow likely never updated it)"
            ok=0
        fi
    done < <(grep -oE 'sha256 "[0-9a-f]{64}"' "$f" | grep -oE '[0-9a-f]{64}')

    # Every url line must contain the version string, so an out-of-band
    # version bump that forgot to update the URL is caught.
    while IFS= read -r u; do
        if [[ "$u" != *"$ver"* ]]; then
            echo "FAIL  $name url '$u' missing version '$ver'"
            ok=0
        fi
    done < <(grep -oE 'url "https://[^"]+"' "$f" | grep -oE 'https://[^"]+')

    # def install block must exist and bin.install at least one binary
    if ! grep -qE 'def install' "$f"; then
        echo "FAIL  $name has no 'def install' block"
        ok=0
    elif ! grep -qE 'bin\.install' "$f"; then
        echo "FAIL  $name has 'def install' but no 'bin.install ...' line"
        ok=0
    fi

    echo "PASS  $name v$ver (urls reference version, sha256 non-placeholder, install present)"
done

[[ $ok -eq 1 ]] && exit 0 || exit 1
