#!/usr/bin/env bash
# For every Homebrew formula's explicit `version "..."` field,
# pin that the value does NOT start with `v` followed by a
# digit.
#
# The org convention (Homebrew-standard):
#
#   url       "https://github.com/.../releases/download/v1.2.3/foo.tar.gz"
#   version   "1.2.3"          # bare semver, NO v prefix
#
# The `v` prefix belongs in the GIT TAG and the URL PATH —
# both are pointers to a release artifact. The `version`
# field is the SEMANTIC VERSION ITSELF — the bare semver
# triple.
#
# When `version` accidentally carries the `v` prefix:
#
#   version "v1.2.3"
#
# downstream tooling that compares versions string-by-string
# may break:
#
#   - `brew outdated <name>` compares the formula's version
#     against the latest upstream tag. Upstream tag is
#     `v1.2.3` → formula version `v1.2.3` → "current" (OK).
#     But: `brew bump-formula-pr` looks at upstream as
#     `1.2.3` (bare) for the version-bump calculation, so
#     it produces nonsense diffs that try to bump
#     `v1.2.3 → 1.2.4` (mixing forms).
#   - `brew info <name>` displays the version verbatim:
#     `==> foo: stable v1.2.3` reads as a copy-paste from
#     a release page rather than a clean version label.
#   - The formulae.brew.sh website parses formula metadata
#     for the "Latest version" sidebar. Mixed prefix-form
#     entries sort incorrectly in lexicographic order.
#
# Detection: regex `^v[0-9]` on the version string.
#
# Pairs with iter-98 (version-url match — the URL HAS the
# v-prefix in /v1.2.3/, but the bare version field still
# satisfies "appears as substring" because the bare `1.2.3`
# is inside `v1.2.3`).
#
# 10/10 formulas with explicit version green at iter-165
# add — pure regression floor.
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
v_prefix=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue

    ver=$(grep -m1 -oE '^\s+version *"[^"]+"' "$f" | sed 's/.*"\([^"]*\)".*/\1/')
    [[ -n "$ver" ]] || continue
    checked=$((checked + 1))

    if [[ "$ver" =~ ^v[0-9] ]]; then
        echo "FAIL  $f: version=\"$ver\" has v-prefix — the v belongs in the URL/tag, version field is bare semver"
        v_prefix=$((v_prefix + 1))
        ok=0
    else
        echo "PASS  $f: version=\"$ver\""
    fi
done

echo "---"
echo "Summary: $checked formulas with explicit version checked, $v_prefix with v-prefix"

[[ $ok -eq 1 ]] && exit 0 || exit 1
