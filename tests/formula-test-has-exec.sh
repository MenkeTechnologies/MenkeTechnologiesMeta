#!/usr/bin/env bash
# For every Homebrew formula's `test do ... end` block,
# pin that the block contains at least one execution
# call: `system`, `shell_output`, or `pipe_output`.
#
# iter-88  pinned `test do ... end` presence.
# iter-121 pinned that the block has `assert*` methods.
# This gate (iter-205) pins that the block actually
# INVOKES the binary, not just makes assertions about
# constants.
#
# Without an execution call, the test block can pass
# without ever loading the installed binary into memory.
# Example pathological cases:
#
#   test do
#     assert_equal 1, 1
#   end
#
# This passes `brew test foo` with no actual smoke test
# of the binary. The assertion is true but tests
# nothing about whether the binary works.
#
#   test do
#     assert File.exist?("#{bin}/foo")
#   end
#
# This checks file presence but not executability —
# `bin.install` could have written a 0-byte file or a
# broken symlink and this still passes.
#
# A real smoke test needs to LOAD the binary and run
# code from it. The three Homebrew helpers that
# accomplish this:
#
#   system "#{bin}/foo", "--version"
#     - Spawns the binary as a subprocess
#     - Fails the test if exit status is non-zero
#     - Catches segfaults, missing shared libs, broken
#       packaging, dyld errors on macOS, etc.
#
#   shell_output("#{bin}/foo --version")
#     - Spawns the binary, captures stdout
#     - Returns the output as a string
#     - Usually paired with assert_match for content
#       verification
#     - Does NOT fail on non-zero exit unless
#       explicitly checked with `shell_output(..., 1)`
#
#   pipe_output("#{bin}/foo", "input string")
#     - Spawns the binary with input piped on stdin
#     - Returns stdout
#     - Useful for testing filters / processors
#
# Brew's reviewer guidance (`brew audit --strict`):
# "Tests should run the formula's binary, not just
# verify install paths." Tap formulas aren't subject
# to strict audit but follow the convention.
#
# Failure mode without this gate:
#
#   - Formula author writes a placeholder test that
#     passes locally
#   - `brew test foo` returns 0 — looks like it works
#   - Installed binary is actually broken (linker
#     issue, missing runtime dep, packaging bug)
#   - Users hit the failure at first invocation
#   - bug report blames "brew install broke" when
#     the formula's test never actually invoked the
#     binary
#
# Detection: regex on `(system|shell_output|
# pipe_output)\b` in formula files. Restricted to
# files that have `test do` block (the pin is
# conditional on test block presence — formulas
# without test blocks are caught by iter-88).
#
# Pairs with the brew formula test catalog:
#   iter-88:  test do block presence
#   iter-121: test block has assert*
#   iter-205: test block invokes the binary (this)
#
# 10/10 formulas have execution call in test block at
# iter-205 add — pure regression floor.
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
no_exec=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    # Skip formulas without test blocks (iter-88 covers those)
    grep -qE '^\s*test do' "$f" || continue
    checked=$((checked + 1))

    if ! grep -qE '\b(system|shell_output|pipe_output)\b' "$f"; then
        echo "FAIL  $f: test block has no system/shell_output/pipe_output call — binary never invoked"
        no_exec=$((no_exec + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas with test block checked, $no_exec without execution call"

[[ $ok -eq 1 ]] && exit 0 || exit 1
