#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the formula declares a `test do ... end` block.
#
# Homebrew's `brew test <formula>` runs the formula's test block
# to verify the installed binary actually works. Without a test
# block, `brew test` exits 0 silently — the user gets no signal
# that the installed version is broken.
#
# Why this matters for the tap CI:
#
#   homebrew-menketech's release.yml workflow auto-bumps each
#   formula on every release. Without a `test do` block, the
#   auto-bumped formula passes `brew install` (the install step
#   itself works) but never validates that the new binary
#   actually runs — `brew test` is a no-op. A broken release
#   tarball ships to users without any tap-side rejection.
#
# Test block convention enforced by Homebrew's `brew audit
# --strict`:
#
#   test do
#     assert_match "version 1.2.3", shell_output("#{bin}/foo --version")
#   end
#
# (Often just runs `--version` or `--help` and asserts on
# output. Minimal but catches "binary segfaults on launch" and
# "wrong version published" — the two highest-frequency
# release-day failures.)
#
# This gate pins PRESENCE only. Test content quality is left to
# per-formula judgment. Some formulas test more aggressively
# (run a known input/output pair); others run only
# --version. Both pass.
#
# 10/10 formulas green at iter-88 add — pure regression floor.
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
missing=0

for f in "$formulas_dir"/*.rb; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))
    if grep -qE '^\s+test do' "$f"; then
        echo "PASS  $f: test do block present"
    else
        echo "FAIL  $f: no \`test do\` block (brew test will exit 0 silently — broken binaries ship unverified)"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $missing without test block"

[[ $ok -eq 1 ]] && exit 0 || exit 1
