#!/usr/bin/env bash
# For every Homebrew formula's `test do ... end` block, pin
# that the block contains at least one `assert*` method call.
#
# Iter-88 pinned the existence of the test do block. Iter-121
# pins that the block actually VERIFIES something.
#
# Without an assertion, `brew test <formula>` runs the block's
# commands but returns success regardless of output. A test
# like:
#
#   test do
#     shell_output("#{bin}/foo --version")
#   end
#
# fetches the binary, runs `--version`, and reports SUCCESS even
# if the binary segfaults — the shell_output method captures
# stdout/stderr but doesn't fail on non-zero exit codes. The
# only thing that fails `brew test` is an explicit assertion:
#
#   test do
#     assert_match "version 1.2.3", shell_output("#{bin}/foo --version")
#   end
#
# Common assertion methods (from Homebrew's Minitest-derived
# DSL):
#   assert_match           — output matches regex/string
#   assert_equal           — strict equality
#   assert_predicate       — object responds true to a predicate
#   assert                 — boolean truthy
#   assert_no_match        — output doesn't match
#   assert_path_exists     — filesystem path exists
#   refute                 — boolean falsy
#   refute_match           — same negative
#
# Detection regex: `\bassert\w*` (matches assert, assert_match,
# assert_equal, assert_path_exists, etc.) OR `\brefute\w*` (the
# negative forms). The test block body is extracted via regex
# from `test do` to the matching `end` at the same indentation.
#
# Pairs with iter-88 (test block exists), iter-89 (def install),
# iter-115 (system array form). Now: brew test actually
# validates installed binaries instead of silently succeeding.
#
# 10/10 formulas green at iter-121 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

formulas_dir="homebrew-menketech/Formula"
if [[ ! -d "$formulas_dir" ]]; then
    echo "SKIP  $formulas_dir not initialized"
    exit 0
fi

checked=0
no_assert=0

audit_one() {
    python3 - "$1" << 'PY'
import sys, re
path = sys.argv[1]
content = open(path).read()
m = re.search(r'(?ms)^\s+test do\s*\n(.*?)^\s+end$', content)
if not m:
    print("NO_BLOCK")
    sys.exit()
body = m.group(1)
if re.search(r'\b(assert|refute)\w*', body):
    print("OK")
else:
    print("NO_ASSERT")
PY
}

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    output=$(audit_one "$f")
    case "$output" in
        OK)
            echo "PASS  $f: test block contains assertion"
            ;;
        NO_BLOCK)
            echo "FAIL  $f: no test do block (delegated to iter-88, but indentation may differ)"
            no_assert=$((no_assert + 1))
            ok=0
            ;;
        NO_ASSERT)
            echo "FAIL  $f: test do block contains no assert*/refute* call — brew test will silently succeed on broken binaries"
            no_assert=$((no_assert + 1))
            ok=0
            ;;
    esac
done

echo "---"
echo "Summary: $checked formulas checked, $no_assert without assertion in test block"

[[ $ok -eq 1 ]] && exit 0 || exit 1
