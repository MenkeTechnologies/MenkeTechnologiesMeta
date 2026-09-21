#!/usr/bin/env bash
# Pin that every bin/ script using a bash 4+ builtin refuses to run on
# bash 3, instead of failing silently and producing a truncated result.
#
# macOS still ships bash 3.2 as /bin/bash — it is frozen at the last
# GPLv2 release and is not going to move — while `#!/usr/bin/env bash`
# resolves to whatever comes first on PATH. A generator written against
# bash 4 therefore runs on two very different interpreters depending on
# whose machine it is, and the bash 3 side does not announce itself.
#
# What that looked like here, exactly once and expensively:
# bin/gen-ci-board builds the README's CI status board and fills its
# workflow lists with `mapfile`. Under bash 3.2 mapfile is not found, but
# the call sits inside a `while read` subshell, so `set -e` never sees
# the failure. Every workflow list came back empty, the script printed a
# three-line table containing no repos, and it EXITED 0. Run with
# --in-place that empty table is spliced straight into README.md,
# replacing a 190-row board with nothing, and CI would have had no
# reason to complain.
#
# The fix each script owes is a version guard near the top:
#
#   if (( BASH_VERSINFO[0] < 4 )); then
#       echo "<name>: needs bash 4.4+ (mapfile); this is bash $BASH_VERSION" >&2
#       exit 1
#   fi
#
# Loud and early beats silent and wrong: a script that stops cannot
# corrupt the file it was about to rewrite.
#
# Only bin/ is swept. The tests/ gates use these builtins too, but they
# run on ubuntu-latest in CI where bash is 5.x, and a gate that dies on a
# developer's laptop is a nuisance rather than a corrupted artifact.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if [[ ! -d bin ]]; then
    echo "SKIP  no bin/ directory"
    exit 0
fi

checked=0
unguarded=0

for f in bin/*; do
    [[ -f "$f" ]] || continue
    # Only bash scripts; sh/node/stryke scripts have their own rules.
    head -1 "$f" | grep -qE '^#!.*\bbash\b' || continue

    # bash 4+ constructs: mapfile/readarray, associative arrays, and the
    # ${var^^} / ${var,,} case-conversion expansions.
    uses=$(grep -nE '\bmapfile\b|\breadarray\b|declare -A|local -A|\$\{[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?(\^\^|,,)' "$f" \
        | grep -v '^[0-9]*:[[:space:]]*#' | head -1)
    [[ -z "$uses" ]] && continue

    checked=$((checked + 1))
    if grep -qE 'BASH_VERSINFO' "$f"; then
        echo "PASS  $f: uses a bash 4 builtin and guards on BASH_VERSINFO"
    else
        echo "FAIL  $f: uses a bash 4 builtin (${uses%%:*}: ${uses#*:}) with no BASH_VERSINFO guard — on macOS bash 3.2 this fails silently and can still exit 0"
        unguarded=$((unguarded + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked bin/ bash-4 scripts checked, $unguarded without a version guard"

[[ $ok -eq 1 ]] && exit 0 || exit 1
