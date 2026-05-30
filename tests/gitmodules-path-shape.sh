#!/usr/bin/env bash
# For every .gitmodules `path = ...` line, pin that the value
# is a SIMPLE relative path:
#
#   - No leading `/` (absolute paths)
#   - No `..` segments (parent-directory traversal)
#   - No leading `./` (redundant current-directory marker)
#   - No trailing `/` (canonical path form is no-slash)
#
# Why each restriction matters:
#
#   1. ABSOLUTE PATHS (`/foo/bar`):
#      git submodule update interprets these as absolute on
#      the user's filesystem. The submodule then tries to
#      clone into `/foo/bar` which is outside the repo.
#      `git status` doesn't recognize the absolute path as a
#      submodule mount point. The recorded SHA pointer
#      becomes orphaned because git can't find the working
#      tree at the recorded location.
#
#   2. PARENT TRAVERSAL (`../foo`):
#      git submodule mount points must be INSIDE the
#      containing repo. `../foo` references a location
#      outside, which `git submodule add` rejects at
#      creation but a hand-edited .gitmodules can introduce
#      after the fact. Symbolically: submodules form a tree
#      rooted at the meta repo; parent-traversal breaks the
#      tree invariant.
#
#   3. LEADING `./` (`./foo`):
#      Functionally equivalent to `foo` but adds visual
#      noise that breaks string-equality checks. Iter-76's
#      URL gate and other iter-N audits compare path
#      basenames against the URL's repo segment; a leading
#      `./` would cause those to fail.
#
#   4. TRAILING `/` (`foo/`):
#      git's own `git submodule add` strips trailing slashes
#      during canonicalization. A hand-edited path with
#      trailing slash gets compared character-by-character
#      against the canonical form in `git submodule status`
#      output (no trailing slash), so the strings don't
#      match and submodule tracking breaks.
#
# Detection: bash case-statement against the four bad
# patterns. Hand-rolled because `find . -path` etc. don't
# apply to .gitmodules text content.
#
# Pairs with iter-76 (URL canonical), iter-134 (one path
# one url per block), iter-167 (this gate: path SHAPE).
# The three together cover .gitmodules content integrity:
# every block has exactly one path of canonical shape, one
# canonical URL, and they reference the same repo.
#
# 64/64 .gitmodules entries green at iter-167 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -f .gitmodules ]]; then
    echo "SKIP  no .gitmodules"
    exit 0
fi

checked=0
bad=0

while IFS= read -r line; do
    path="${line#$'\t''path = '}"
    [[ -n "$path" ]] || continue
    checked=$((checked + 1))

    case "$path" in
        /*)
            echo "FAIL  .gitmodules: \"$path\" starts with `/` — must be relative"
            bad=$((bad + 1))
            ok=0
            ;;
        ./*)
            echo "FAIL  .gitmodules: \"$path\" starts with `./` — redundant current-directory marker"
            bad=$((bad + 1))
            ok=0
            ;;
        *../*|*..)
            echo "FAIL  .gitmodules: \"$path\" contains `..` — parent-directory traversal forbidden"
            bad=$((bad + 1))
            ok=0
            ;;
        */)
            echo "FAIL  .gitmodules: \"$path\" ends with `/` — canonical form omits trailing slash"
            bad=$((bad + 1))
            ok=0
            ;;
        *)
            : # silent pass
            ;;
    esac
done < <(grep '^\tpath = ' .gitmodules)

echo "---"
echo "Summary: $checked .gitmodules paths checked, $bad with non-canonical shape"

[[ $ok -eq 1 ]] && exit 0 || exit 1
