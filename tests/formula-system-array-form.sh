#!/usr/bin/env bash
# For every Homebrew formula, pin that any `system` call uses
# the ARRAY form (multiple arguments) rather than the SINGLE-
# STRING form (which goes through shell parsing).
#
# Homebrew's `system` Ruby method:
#
#   system "bin/foo --version"           # SINGLE-STRING form
#   → invokes /bin/sh -c "bin/foo --version"
#   → shell parses the string: word-split, glob, quote handling
#   → any user-controllable substring becomes shell-injection
#
#   system "bin/foo", "--version"         # ARRAY form
#   → execvp("bin/foo", ["bin/foo", "--version"])
#   → no shell involvement; --version is a literal argument
#   → safe under any input
#
# The Homebrew style guide explicitly recommends the array form
# (`brew audit --strict` flags string-form calls for known
# patterns). The audit doesn't catch every case, though —
# formulas with interpolated content like
# `system "#{bin}/foo --flag"` slip past brew audit because the
# interpolation happens before the audit's regex inspection.
# This gate catches the SHAPE: any `system "..."` with no
# comma after the first quoted argument.
#
# Common drift introduction:
#   - Convenience: writing the whole command as one string is
#     shorter than splitting into args
#   - Copy-paste from a Bash script where shell parsing is
#     expected
#   - Quoting an embedded interpolation: `system "#{bin}/foo
#     --version #{some_var}"` — looks safe but `some_var` can
#     contain shell metacharacters
#
# Allowed patterns (multi-arg array form):
#   system "foo"                          # zero args, no shell — OK
#   system bin/"foo", "--version"         # Pathname + literal
#   system "#{bin}/foo", "--flag", arg    # interpolation + args
#
# Detection: lines containing `system "<arg>"` with NO comma
# or additional quoted arg after — those go through shell. The
# zero-arg case `system "foo"` is technically also string-form
# but harmless (no shell metachars in a single word); the gate
# flags only multi-token strings (containing whitespace).
#
# 10/10 formulas green at iter-115 add — pure regression floor
# against shell-injection introduction.
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
risky=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    # Lines matching `system "<arg with spaces>"` at end-of-line
    # (no trailing comma + another arg).
    while IFS= read -r match; do
        ln_num="${match%%:*}"
        line="${match#*:}"
        stripped=$(echo "$line" | sed -E 's/^[[:space:]]*//')
        # Skip comments.
        case "$stripped" in
            \#*) continue ;;
        esac
        # Check: `system "..."` with multi-word content inside,
        # no comma after the closing quote.
        if echo "$stripped" | grep -qE 'system\s+"[^"]*\s[^"]*"\s*$'; then
            echo "FAIL  $f:$ln_num: single-string \`system\` with multi-word arg — goes through shell. Use array form. Line: $line"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE 'system\s+"' "$f" 2>/dev/null || true)
done

echo "---"
echo "Summary: $checked formulas checked, $risky single-string system calls"

[[ $ok -eq 1 ]] && exit 0 || exit 1
