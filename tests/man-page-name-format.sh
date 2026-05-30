#!/usr/bin/env bash
# For every man/man1/*.1 page across submodules, pin that the
# `.SH NAME` section's first content line follows the canonical
# `<name> \- <description>` format that `whatis` and `apropos`
# rely on for indexing.
#
# A page with mis-formatted .SH NAME silently breaks:
#   - `whatis <name>` returns "nothing appropriate"
#   - `apropos <keyword>` can't find the page by description
#   - `mandb -c` skips the page when rebuilding the man database
#
# The shape required is: page-stem at column 0, followed by an
# escaped hyphen (`\-` or `\\-` depending on layer of escaping in the
# source), followed by a description.
#
# Caught 0 drift at iteration 35 add-time — all 22 man pages already
# conformed. Test serves as a regression-prevention floor: future
# hand-edits that break the format will FAIL CI before merge.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
bad=0

# Walk every man/man1/*.1 file across all submodules + the meta repo.
while IFS= read -r m; do
    [[ -f "$m" ]] || continue
    checked=$((checked + 1))
    # The page stem is the file basename minus .1.
    stem=$(basename "$m" .1)
    # Read the first non-blank line AFTER `.SH NAME`.
    name_line=$(awk '/^\.SH NAME$/{found=1; next} found && NF{print; exit}' "$m")
    # Required shape: starts with stem, optionally followed by
    # `, <alias>` siblings (canonical multi-name form per man-pages(7),
    # e.g. `chmod, fchmod \- ...`), then `\-` (one or two backslashes
    # depending on layer of source escaping), then a description.
    if [[ "$name_line" =~ ^${stem}([[:space:]]*,[[:space:]]*[A-Za-z0-9_-]+)*[[:space:]]+\\\\?-[[:space:]] ]]; then
        echo "PASS  $m"
    else
        echo "FAIL  $m: .SH NAME content line '$name_line' doesn't match '<stem>[, <alias>...] \\- <description>'"
        bad=$((bad + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -name '*.1' -print 2>/dev/null | grep '/man/man1/')

echo "---"
echo "Summary: $checked man pages checked, $bad with mis-formatted .SH NAME"

[[ $ok -eq 1 ]] && exit 0 || exit 1
