#!/usr/bin/env bash
# For every Cargo.toml across the umbrella, pin that the file
# parses as syntactically valid TOML (1.0 spec).
#
# Cargo's own parser rejects invalid TOML with:
#
#   error: failed to parse manifest at `<path>`
#   caused by: TOML parse error at line N, column M
#
# This is caught by `cargo build` immediately — but the entire
# CI Rust build job has to spin up first (rustc download, target/
# cache restore, dep fetch) before the error surfaces. Lint-time
# TOML validation cuts that round trip from minutes to seconds:
# a contributor PR with a broken Cargo.toml gets a fast-fail
# annotation without burning a full Rust build slot.
#
# Common breakages:
#   - Duplicate key in same section
#   - Mismatched brackets in inline tables: `dep = { version = "1.0" }`
#     with the trailing `}` dropped on hand-edit
#   - Multi-line strings without `"""` delimiters
#   - Unescaped backslash in Windows-style paths used as `path = "..."`
#   - `[features]` table with reserved key shadowing (defaults
#     vs default = [])
#
# Test uses Python's `tomllib` (stdlib since 3.11) which
# implements TOML 1.0 — matches Cargo's `toml_edit` crate
# parsing tolerance. A clean parse here means Cargo will parse
# it identically.
#
# Excludes target/ and vendor/ paths (Cargo.toml files generated
# inside build artifacts or vendored deps aren't ours).
#
# 38/38 Cargo.toml files parse green at iter-73 add — pure
# regression floor against syntax breakage during hand-edit.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
# tomllib is stdlib in 3.11+. Older Pythons get the fallback `tomli`.
if ! python3 -c 'import tomllib' 2>/dev/null && ! python3 -c 'import tomli' 2>/dev/null; then
    echo "SKIP  no TOML parser available (need python 3.11+ or tomli installed)"
    exit 0
fi

checked=0
broken=0

while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))

    err=$(python3 -c '
import sys
try:
    import tomllib as toml
except ImportError:
    import tomli as toml
try:
    with open(sys.argv[1], "rb") as fh:
        toml.load(fh)
except toml.TOMLDecodeError as e:
    print(str(e).split("\n")[0])
    sys.exit(1)
' "$f" 2>&1) || {
        echo "FAIL  $f: $err"
        broken=$((broken + 1))
        ok=0
        continue
    }
done < <(find . -path './.git' -prune -o -type f -name 'Cargo.toml' -not -path '*/target/*' -not -path '*/vendor/*' -print 2>/dev/null)

echo "---"
echo "Summary: $checked Cargo.toml files checked, $broken with TOML parse errors"

[[ $ok -eq 1 ]] && exit 0 || exit 1
