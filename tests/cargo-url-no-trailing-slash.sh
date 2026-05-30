#!/usr/bin/env bash
# For Cargo.toml's `repository` and `documentation` fields, pin
# that the URL value does NOT end with a trailing `/`.
#
# Convention rationale:
#
#   repository:    https://github.com/MenkeTechnologies/<repo>
#                  (no trailing slash; GitHub URLs work both
#                  ways but the canonical form is sans-slash)
#
#   documentation: https://docs.rs/<crate>
#                  (no trailing slash; docs.rs convention)
#
#   homepage:      https://menketechnologies.github.io/<repo>/
#                  (TRAILING SLASH present per iter-26's GH
#                  Pages convention — GH Pages serves the
#                  trailing-slash form canonically and the
#                  sans-slash form redirects with a 301)
#
# The split (homepage HAS slash, repository / documentation do
# NOT) reflects the upstream services' own canonical forms:
#
#   - GitHub's repository URL canonical is without slash —
#     `git clone https://github.com/foo/bar` works; with
#     trailing slash it works too, but `git clone` strips
#     it from the local origin name. Repository URLs
#     embedded in tooling (cargo, sccache, etc.) treat
#     `https://github.com/foo/bar` and
#     `https://github.com/foo/bar/` as semantically equal but
#     normalize to the sans-slash form when echoing back.
#   - docs.rs's canonical URL is sans-slash; the trailing-
#     slash form 301-redirects.
#   - GitHub Pages canonical IS with trailing slash for
#     directory-style URLs; the sans-slash form 301-redirects
#     to the trailing-slash form.
#
# crates.io renders repository / documentation / homepage as
# three separate clickable links on the crate page. When the
# URL doesn't match the upstream's canonical form, the browser
# pays the redirect cost on every click — minor for a single
# user, multiplied across crate-page visitors over the crate's
# lifetime.
#
# Detection: check repository and documentation values for
# trailing `/`. Homepage is intentionally EXEMPT to preserve
# the iter-26 GH Pages convention.
#
# 37/37 repository+documentation URLs green at iter-132 add —
# pure regression floor against trailing-slash drift during
# manual URL paste.
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
trailing=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    for field in repository documentation; do
        url=$(grep -m1 -E "^${field} *= *\"" "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
        [[ -n "$url" ]] || continue
        checked=$((checked + 1))

        if [[ "$url" == */ ]]; then
            echo "FAIL  $cargo: $field=$url has trailing slash — canonical form is sans-slash"
            trailing=$((trailing + 1))
            ok=0
        else
            echo "PASS  $cargo: $field=$url"
        fi
    done
done

echo "---"
echo "Summary: $checked repository+documentation URLs checked, $trailing with trailing slash"

[[ $ok -eq 1 ]] && exit 0 || exit 1
