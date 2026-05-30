#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the formula declares a `sha256 "..."` line with a
# valid 64-character lowercase hex digest.
#
# Homebrew computes the digest of every download URL and refuses
# to install if it doesn't match the formula's declared sha256.
# This is the supply-chain integrity guarantee: even if the
# GitHub release tarball is replaced with a malicious one (or
# the CDN is compromised), `brew install` fails because the
# digest no longer matches.
#
# Failure modes this gate forecloses:
#
#   1. Formula generated without sha256 (release.yml's auto-bump
#      script didn't fill in the digest) — `brew install` runs
#      WITHOUT verification, defeating the integrity guarantee.
#      Homebrew silently warns "no checksum found" but proceeds.
#   2. sha256 value with non-hex chars (typo replacing a `0` with
#      an `O`) — brew rejects at install with "sha256 mismatch."
#   3. sha256 of wrong length (truncated to 63 chars from a
#      pasting error) — same install-time rejection.
#
# Per the CLAUDE.md audit-tool tampering rule: modifying or
# silently deleting a sha256 to make `brew install` "work"
# without verification IS the tampering pattern that section
# forbids. This gate makes that drift fail at lint time, not at
# silent install time.
#
# Test pattern: `sha256 "<64 lowercase hex chars>"` appearing
# anywhere in the formula. Bottle blocks ("bottle do ... sha256
# cellar: ...") also count, but the main url-block sha256 is the
# one that matters for source-install integrity.
#
# 10/10 formulas green at iter-74 add — pure regression floor
# (and security-critical regression floor at that).
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    # If the homebrew-menketech submodule isn't initialized,
    # there's nothing to check — pass through.
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
missing=0
malformed=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    # Look for sha256 "<digest>" — accept any 64-char hex string.
    sha_lines=$(grep -E 'sha256 *"[a-f0-9]+"' "$f" || true)

    if [[ -z "$sha_lines" ]]; then
        echo "FAIL  $f: no \`sha256 \"<digest>\"\` line (brew install runs WITHOUT integrity check)"
        missing=$((missing + 1))
        ok=0
        continue
    fi

    # Validate at least one sha256 is exactly 64 chars (proper digest length).
    if ! echo "$sha_lines" | grep -qE 'sha256 *"[a-f0-9]{64}"'; then
        bad=$(echo "$sha_lines" | head -1)
        echo "FAIL  $f: sha256 present but not 64 hex chars (got: $bad)"
        malformed=$((malformed + 1))
        ok=0
        continue
    fi

    echo "PASS  $f: sha256 declared"
done

echo "---"
echo "Summary: $checked formulas checked, $missing without sha256, $malformed with non-64-char digest"

[[ $ok -eq 1 ]] && exit 0 || exit 1
