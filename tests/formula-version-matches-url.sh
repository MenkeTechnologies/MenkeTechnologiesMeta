#!/usr/bin/env bash
# For every Homebrew formula that declares an explicit
# `version "..."` field, pin that the version string appears
# as a substring of the `url "..."` field.
#
# Homebrew can usually infer the formula version from the URL
# path (e.g., `releases/download/v1.2.3/foo-...tar.gz` →
# version 1.2.3) — the explicit `version "..."` field is an
# override for cases where the URL pattern doesn't parse, or
# for documentation. When both are declared, they MUST agree:
#
#   Bad:
#     url      "https://github.com/.../releases/download/v1.2.3/foo.tar.gz"
#     version  "1.2.2"   # off-by-one, paste error
#     sha256   "..."     # sha256 will match the v1.2.3 tarball
#
#   `brew install` succeeds (download URL is real, sha256 matches).
#   `brew info` reports version 1.2.2 anyway.
#   `brew outdated` thinks v1.2.3 → v1.2.4 is the next upgrade
#   when really v1.2.2 → v1.2.3 happens at the same moment.
#   Version-checking tooling (`brew bump-formula-pr --dry-run`)
#   produces nonsense diffs.
#
# Detection: extract the explicit version, check that it
# appears as a substring of the URL. The substring check is
# tolerant of `v1.2.3` vs `1.2.3` (the url usually has the `v`
# prefix; the version field is the bare semver — both forms
# include "1.2.3" as a substring).
#
# Formulas without an explicit version field are SKIPPED — they
# rely on Homebrew's url-based inference, which is correct by
# construction.
#
# 10/10 formulas (all have explicit version) green at iter-98
# add — pure regression floor against drift between the
# auto-bumped url and the auto-bumped version field.
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
no_version=0
mismatched=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue

    ver=$(grep -m1 -oE '^\s+version *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ -z "$ver" ]]; then
        no_version=$((no_version + 1))
        continue
    fi

    url=$(grep -m1 -oE '^\s+url *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    if [[ -z "$url" ]]; then
        # url-not-present case is caught by iter-77; skip.
        continue
    fi

    checked=$((checked + 1))

    if echo "$url" | grep -qF "$ver"; then
        echo "PASS  $f: version=$ver appears in url"
    else
        echo "FAIL  $f: version=$ver NOT in url=$url (brew info will show $ver, but download fetches a different artifact)"
        mismatched=$((mismatched + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas with explicit version checked, $mismatched mismatched ($no_version without explicit version)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
