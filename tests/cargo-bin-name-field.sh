#!/usr/bin/env bash
# For every `[[bin]]` table in a Cargo.toml, pin that the block
# declares a `name = "..."` field.
#
# Cargo's resolution rule for [[bin]] entries: if `name` is
# missing, Cargo falls back to the file stem of `path = "..."`
# (e.g. `src/bin/foo.rs` → bin name "foo"). The fallback works,
# but has three failure modes:
#
#   1. Rename `path = "src/bin/foo.rs"` → `"src/bin/bar.rs"`
#      without setting an explicit name — the bin's name silently
#      changes from "foo" to "bar". Every workflow / formula /
#      shell alias / brew tap that calls `cargo run --bin foo`
#      breaks at command time.
#   2. Brew formula's `bin.install` rule (`bin.install "foo"`)
#      no longer finds the binary because cargo wrote it as
#      target/release/bar instead. release.yml's tarball assembly
#      breaks — but the failure may not surface until after a
#      tag push.
#   3. `default-run = "foo"` (iter-70) starts failing because
#      no [[bin]] declares name "foo" — even if a path-derived
#      "foo" bin still exists, the lookup is by explicit name
#      first.
#
# Explicit `name =` decouples the published bin name from its
# source-file location. Source files can move freely; the
# install/run interface stays stable.
#
# 36/36 [[bin]] blocks green at iter-79 add — pure regression
# floor against silent-rename drift.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

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
no_name=0

# For each Cargo.toml, walk [[bin]] sections and verify name=.
# Uses Python for robust section parsing (regex anchored to
# section header).
audit_one() {
    local cargo="$1"
    python3 - "$cargo" << 'PY'
import re, sys
cargo = sys.argv[1]
content = open(cargo).read()
sections = re.split(r'(?m)^(\[\[?[a-zA-Z_][a-zA-Z_.-]*\]\]?)', content)
i = 1
hit = 0
miss = 0
while i < len(sections):
    header = sections[i]
    body = sections[i+1] if i+1 < len(sections) else ''
    if header == '[[bin]]':
        hit += 1
        if not re.search(r'(?m)^name *= *"', body):
            miss += 1
            print(f"MISS")
    i += 2
print(f"COUNT {hit} {miss}")
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
    hit=$(echo "$output" | awk '/^COUNT/{print $2}')
    miss=$(echo "$output" | awk '/^COUNT/{print $3}')

    [[ "$hit" -gt 0 ]] || continue
    checked=$((checked + hit))

    if [[ "$miss" -gt 0 ]]; then
        echo "FAIL  $cargo: $miss of $hit [[bin]] blocks missing name field"
        no_name=$((no_name + miss))
        ok=0
    else
        echo "PASS  $cargo: $hit [[bin]] blocks all have name field"
    fi
done

echo "---"
echo "Summary: $checked [[bin]] blocks checked, $no_name without name field"

[[ $ok -eq 1 ]] && exit 0 || exit 1
