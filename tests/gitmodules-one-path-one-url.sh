#!/usr/bin/env bash
# For every [submodule "..."] block in .gitmodules, pin that
# the block declares EXACTLY one `path = ...` line and EXACTLY
# one `url = ...` line.
#
# Git's `.gitmodules` parser is per-block last-wins for
# duplicate keys (same as YAML mapping behavior in iter-128).
# Multiple `url = ...` lines in a single submodule block:
#
#   [submodule "foo"]
#     path = foo
#     url = https://github.com/MenkeTechnologies/foo.git
#     url = git@github.com:contributor/foo-fork.git
#
# The SECOND url silently overrides the first. `git submodule
# update --init --recursive` clones from the FORK, not the
# canonical repo. The first line passes code review because
# the canonical URL "is there"; the override slips past
# because review focuses on the first occurrence.
#
# Same failure mode for duplicate `path = ...` lines — only
# the second path is recorded, so the submodule mounts at a
# different directory than the first line suggests. Tests /
# build scripts referencing the first path break silently.
#
# iter-76 pins the URL CONTENT (canonical github.com/
# MenkeTechnologies/ form). iter-134 pins the STRUCTURE
# (exactly one path, exactly one url per block) so the
# canonical URL can't be silently overridden.
#
# Detection: parse .gitmodules block-by-block, count `path =`
# and `url =` lines per block, require exactly 1 of each.
#
# 64/64 .gitmodules blocks green at iter-134 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -f .gitmodules ]]; then
    echo "SKIP  no .gitmodules"
    exit 0
fi

output=$(awk '
BEGIN { name = ""; path_n = 0; url_n = 0; total = 0; bad = 0 }
/^\[submodule/ {
    if (name != "") {
        total++
        if (path_n != 1 || url_n != 1) {
            print "BAD " name ": " path_n " path lines, " url_n " url lines"
            bad++
        }
    }
    name = $2
    path_n = 0
    url_n = 0
    next
}
/^\tpath = /  { path_n++ }
/^\turl = /   { url_n++ }
END {
    if (name != "") {
        total++
        if (path_n != 1 || url_n != 1) {
            print "BAD " name ": " path_n " path lines, " url_n " url lines"
            bad++
        }
    }
    print "COUNT " total " " bad
}
' .gitmodules)

count_line=$(echo "$output" | grep '^COUNT ' | head -1)
total=$(echo "$count_line" | awk '{print $2}')
bad=$(echo "$count_line" | awk '{print $3}')

if [[ "$bad" -gt 0 ]]; then
    echo "$output" | grep '^BAD ' | while IFS= read -r line; do
        echo "FAIL  .gitmodules ${line#BAD }"
    done
    ok=0
fi

echo "---"
echo "Summary: $total .gitmodules blocks checked, $bad with non-canonical path/url count"

[[ $ok -eq 1 ]] && exit 0 || exit 1
