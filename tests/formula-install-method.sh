#!/usr/bin/env bash
# For every Homebrew formula in homebrew-menketech/Formula/*.rb,
# pin that the formula declares a `def install ... end` method.
#
# Homebrew calls `install` to place the downloaded artifacts into
# the Cellar (typically `bin.install "foo"` or `prefix.install
# Dir["*"]`). Without an `install` method:
#
#   - `brew install <name>` fetches and unpacks the tarball, then
#     exits 0 because Ruby's default no-op for an undefined method
#     IS the install behavior (Homebrew's base class defines
#     install as `nil`-returning).
#   - No files land in the Cellar.
#   - `brew list <name>` shows the formula as installed but with
#     zero files.
#   - The binary that the user expected to be in $PATH is missing.
#   - Worst case: a stale binary from a previous version (still
#     in the Cellar from a successful older install) silently
#     keeps serving requests while the user thinks they upgraded.
#
# Like iter-88's `test do` gate, this is REQUIRED by Homebrew's
# own `brew audit --strict` for any formula — but tap-level
# audit only fires on install/test paths. A formula added but
# never installed slips past.
#
# 10/10 formulas green at iter-89 add — pure regression floor.
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
    if grep -qE '^\s+def install' "$f"; then
        echo "PASS  $f: def install present"
    else
        echo "FAIL  $f: no \`def install\` method (brew install succeeds but places no files in Cellar)"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked formulas checked, $missing without install method"

[[ $ok -eq 1 ]] && exit 0 || exit 1
