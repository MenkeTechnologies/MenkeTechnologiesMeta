#!/usr/bin/env bash
# For every Homebrew formula's `url` field, pin that the URL
# path includes `/releases/download/` (the binary-release
# artifact path) rather than `/archive/` (the auto-generated
# source-tarball path).
#
# GitHub provides two distinct tarball URLs per repo:
#
#   Source archive (auto-generated, NOT a release artifact):
#     https://github.com/<org>/<repo>/archive/refs/tags/<tag>.tar.gz
#     → Contents: the git tree at the tag SHA, no binaries
#     → Hash: changes if GitHub re-generates the archive
#       (rare but documented — see GitHub's own changelogs)
#
#   Release artifact (uploaded by the publisher):
#     https://github.com/<org>/<repo>/releases/download/<tag>/<asset>
#     → Contents: whatever the release.yml workflow uploaded
#       (typically pre-built binaries per OS/arch)
#     → Hash: PERMANENT — GitHub never re-generates uploaded
#       artifacts; sha256 in the formula stays valid forever
#
# For a Rust-built tap, the binary-release artifact is the
# CORRECT URL:
#
#   1. `brew install` downloads a pre-built binary; no `cargo
#      build` runs locally. Source download forces a full
#      build at install time, defeating the speed advantage of
#      Homebrew.
#   2. The sha256 the formula declares is the digest of the
#      RELEASE ASSET. If the URL points at the source archive,
#      brew downloads the source tarball whose digest is
#      DIFFERENT from what the formula recorded — install
#      fails with "sha256 mismatch."
#   3. iter-77 already pins that the URL is canonical
#      github.com/MenkeTechnologies/... (org + protocol). This
#      gate adds the PATH check: not just any URL on github.com,
#      but specifically the release-download path.
#
# Common drift introductions:
#   - Manual hand-edit using the GitHub "Source code (tar.gz)"
#     link from the release page UI — that link IS the
#     /archive/ source-tarball URL.
#   - Automated formula generation tools that default to
#     /archive/ when no release asset is specified.
#   - Copying a URL from a non-Rust upstream formula that
#     legitimately uses source download.
#
# Detection: URL contains `/archive/` (source) and does NOT
# contain `/releases/download/` (binary release).
#
# 10/10 formulas green at iter-123 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
source_url=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    url=$(grep -m1 -oE '^\s+url *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ -z "$url" ]]; then
        continue  # presence checked by iter-77
    fi

    if echo "$url" | grep -qE '/releases/download/'; then
        echo "PASS  $f: url uses /releases/download/ path"
    elif echo "$url" | grep -qE '/archive/'; then
        echo "FAIL  $f: url=$url uses /archive/ (source tarball) — brew will build from source, sha256 will mismatch the published release asset"
        source_url=$((source_url + 1))
        ok=0
    else
        # Unknown path — neither /archive/ nor /releases/download/.
        # Likely a non-github URL or unusual layout. Skip without
        # failing (iter-77 enforces github.com prefix).
        echo "PASS  $f: url=$url (non-standard path; iter-77 enforces github.com)"
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $source_url using /archive/ source-tarball URL"

[[ $ok -eq 1 ]] && exit 0 || exit 1
