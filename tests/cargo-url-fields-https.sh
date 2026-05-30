#!/usr/bin/env bash
# For every Cargo.toml's three URL fields (homepage, repository,
# documentation), pin that the URL uses the `https://` scheme.
#
# Why this matters:
#
#   - http:// renders as a warning on crates.io's crate page
#     ("This link uses an insecure protocol") and modern
#     browsers may block the navigation outright with no
#     fallback.
#   - git:// (the unauthenticated git wire protocol) was
#     RETIRED by github.com in March 2022. Existing http://
#     and git:// repository URLs in published crates already
#     redirect to https:// — but the metadata stored on
#     crates.io still shows the deprecated form, which docs.rs
#     and the crate card render as-is.
#   - ssh:// repository URLs (e.g.,
#     `git@github.com:foo/bar.git`) require an SSH key to
#     clone — they break the "click and clone" flow that
#     crates.io users expect, especially for first-time
#     evaluators who don't have GitHub SSH set up.
#
# Pattern enforced: each set URL field must start with
# `https://`. Empty fields (not set in Cargo.toml at all) are
# skipped — separate gates enforce presence (iter-26
# homepage-field, iter-cargo-repository-field, iter-cargo-
# documentation-field).
#
# 26/26 repository fields all https at iter-108 add. Pure
# regression floor against accidental http:// commit (most
# common path: someone runs `git remote set-url origin http://`
# during a network-debugging session, then copies the URL
# into Cargo.toml).
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
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    for field in homepage repository documentation; do
        url=$(grep -m1 -E "^${field} *= *\"" "$cargo" | sed 's/.*"\([^"]*\)".*/\1/')
        [[ -n "$url" ]] || continue
        checked=$((checked + 1))

        if [[ "$url" =~ ^https:// ]]; then
            echo "PASS  $cargo: $field=$url"
        else
            echo "FAIL  $cargo: $field=$url — must use https:// (http/git/ssh deprecated for crates.io display)"
            bad=$((bad + 1))
            ok=0
        fi
    done
done

echo "---"
echo "Summary: $checked Cargo.toml URL fields checked, $bad on non-https scheme"

[[ $ok -eq 1 ]] && exit 0 || exit 1
