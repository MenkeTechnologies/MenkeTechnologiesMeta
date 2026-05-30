#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate's
# python3 heredoc invocation must use a QUOTED marker:
#
#   python3 - "$cargo" << 'PY'    # CORRECT: 'PY' single-quoted
#   python3 - "$arg" << "PY"      # CORRECT: "PY" double-quoted
#   python3 - "$arg" << PY        # WRONG:   bare PY — shell expansion!
#
# Why quoted heredocs:
#
# An UNQUOTED heredoc marker tells bash to PERFORM PARAMETER
# EXPANSION on the heredoc body BEFORE passing it to the
# python3 process. That means:
#
#   - Every `$variable` in the Python code is bash-expanded
#     instead of staying as Python syntax. A line like
#     `for $name in items:` would FAIL with bash trying to
#     resolve `$name` as a shell variable.
#   - Every `$(command)` substitution executes — turning
#     Python's `os.environ.get("$(date)")` into a SHELL
#     COMMAND EXECUTION at heredoc evaluation time.
#   - Backslash escapes interact with bash's escape rules
#     before Python sees them — common Python regex like
#     `r"\d+"` becomes `r"d+"` because bash consumes the
#     backslash.
#   - Backticks ` `` ` are interpreted as command
#     substitution — Python code that happens to use them
#     (rare but possible in docstrings) gets executed.
#
# All four failure modes are silent: the Python script fails
# at parse time, runtime, or — worst case — succeeds with
# CORRUPTED INPUT because the bash expansion produced
# accidentally-valid-looking Python text.
#
# Quoted markers (`'PY'` or `"PY"`) disable bash's expansion
# pass; the heredoc body passes through to python3 verbatim.
#
# Detection: regex on `python3` + `<<` + marker. Quoted marker
# (single or double quote followed by identifier followed by
# matching quote) is OK. Bare identifier after `<<` is FAIL.
#
# 17/17 python heredocs across the catalog use quoted markers
# at iter-174 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
bad=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    # Skip the meta-python3-skip-fallback gate which references
    # the heredoc pattern in regex string literals (false-match).
    [[ "$(basename "$f")" == "meta-python3-skip-fallback.sh" ]] && continue
    # Skip this gate itself.
    [[ "$(basename "$f")" == "meta-python-heredoc-quoted.sh" ]] && continue

    while IFS= read -r line; do
        text="${line#*:}"
        stripped=$(echo "$text" | sed -E 's/^[[:space:]]*//')
        case "$stripped" in
            \#*) continue ;;
        esac
        # Look for `python3 ... <<`.
        if echo "$stripped" | grep -qE 'python3[[:space:]].*<<'; then
            checked=$((checked + 1))
            # Quoted heredoc form accepted.
            if echo "$stripped" | grep -qE "<<\s*['\"]"; then
                : # pass
            else
                echo "FAIL  $f: unquoted heredoc marker — bash will expand body: $stripped"
                bad=$((bad + 1))
                ok=0
            fi
        fi
    done < <(grep -n "python3" "$f" 2>/dev/null)
done

echo "---"
echo "Summary: $checked python heredoc lines checked, $bad with unquoted marker"

[[ $ok -eq 1 ]] && exit 0 || exit 1
