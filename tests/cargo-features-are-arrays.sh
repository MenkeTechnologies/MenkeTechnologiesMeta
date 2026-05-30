#!/usr/bin/env bash
# For every Cargo.toml `[features]` section, pin that each
# feature value is an ARRAY literal (`[...]`) rather than a
# string, scalar, or table.
#
# Cargo's feature value type is strictly `array of strings`.
# The TOML grammar would technically accept other shapes, but
# Cargo's resolver errors at build time:
#
#   error: invalid type: string "foo", expected sequence
#
# The drift sneaks in when:
#   - A single-item feature gets misformatted as a string
#     (`foo = "bar"` instead of `foo = ["bar"]`) during a
#     refactor that converted a multi-line array to a one-
#     line form and dropped the brackets.
#   - A feature value is interpolated from a template that
#     forgot to wrap in brackets.
#   - A hand-edit moves a feature's dep-list into a comment
#     block above it and leaves the feature name with no
#     value at all (`foo =` parses as empty string in TOML 0.5
#     — TOML 1.0 rejects it but Cargo may accept legacy
#     manifests).
#
# Cargo's "invalid type" error at build time is informative
# but only fires when the project is actually built. Lint-time
# detection catches the bug at PR review before any CI Rust
# build slot is consumed.
#
# Detection: per-line parse of [features] body. Each line of
# the form `<name> = <value>` must have <value> start with `[`.
# Comments and blank lines are skipped.
#
# 12/12 feature entries across 3 crates green at iter-127 add
# — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

checked=0
bad=0

audit_one() {
    python3 - "$1" << 'PY'
import sys, re
cargo = sys.argv[1]
content = open(cargo).read()
m = re.search(r'(?ms)^\[features\]\n(.*?)(?=\n\[|\Z)', content)
if not m:
    print("NO_FEATURES")
    sys.exit()
body = m.group(1)
results = []
for ln in body.splitlines():
    stripped = ln.strip()
    if not stripped or stripped.startswith('#'):
        continue
    nm = re.match(r'^([a-zA-Z0-9_-]+)\s*=\s*(.+)$', stripped)
    if not nm:
        continue
    name, value = nm.group(1), nm.group(2)
    if value.startswith('['):
        results.append(f"OK:{name}")
    else:
        results.append(f"BAD:{name}:{value[:50]}")
print("\n".join(results) if results else "NO_FEATURES")
PY
}

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    cargo=""
    if [[ -f "$p/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/Cargo.toml"; then
        cargo="$p/Cargo.toml"
    elif [[ -f "$p/src-tauri/Cargo.toml" ]] && grep -qE '^\[package\]' "$p/src-tauri/Cargo.toml"; then
        cargo="$p/src-tauri/Cargo.toml"
    fi
    [[ -n "$cargo" ]] || continue

    output=$(audit_one "$cargo")
    [[ "$output" == "NO_FEATURES" ]] && continue

    while IFS=: read -r status name value; do
        [[ -z "$status" ]] && continue
        checked=$((checked + 1))
        if [[ "$status" == "OK" ]]; then
            echo "PASS  $cargo: feature \"$name\" is array"
        else
            echo "FAIL  $cargo: feature \"$name\" value is not array: $value"
            bad=$((bad + 1))
            ok=0
        fi
    done <<< "$output"
done

echo "---"
echo "Summary: $checked feature entries checked, $bad with non-array values"

[[ $ok -eq 1 ]] && exit 0 || exit 1
