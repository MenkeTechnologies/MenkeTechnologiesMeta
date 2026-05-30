#!/usr/bin/env bash
# For every Cargo.toml dependency entry, pin that no entry
# declares `default-features = true`.
#
# `default-features` defaults to `true` in Cargo when the key
# is absent from a dependency table:
#
#   foo = { version = "1.0", default-features = true, ... }
#   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#   Equivalent to:
#   foo = { version = "1.0", ... }
#
# The explicit `default-features = true` is REDUNDANT — it
# doesn't change resolver behavior. It's almost always a sign
# of one of three drifts:
#
#   1. Copy-paste from a stack-overflow answer or another
#      project where the author thought they had to be
#      explicit. The copy-paste pulls the redundant flag
#      along.
#
#   2. Refactor leftover: a previous version had
#      `default-features = false` to disable some default
#      feature; the developer later changed their mind and
#      flipped it to `true` instead of removing the line.
#      The line is dead code.
#
#   3. Confusion about default behavior: a contributor unsure
#      whether the field defaults to true or false defensively
#      writes it out. The defensive write is a STYLE
#      SIGNAL that the dep table is hand-edited rather than
#      generated, increasing review attention to that line
#      for future audits.
#
# The fix is trivial: delete the redundant key. The deletion
# reads cleaner and matches the convention used by every other
# dep in the manifest that's relying on the default.
#
# Detection: regex on `default-features = true` (with flexible
# whitespace) anywhere in dep tables. The `= false` form is
# legitimately meaningful (disables default features) so the
# gate only flags `= true`.
#
# 0/573 dep lines have redundant default-features=true at
# iter-148 add — pure regression floor.
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
sections = re.split(r'(?m)^(\[[^\]]+\])', content)
i = 1
bad = []
while i < len(sections):
    h = sections[i]
    b = sections[i+1] if i+1 < len(sections) else ''
    if h in ('[dependencies]', '[dev-dependencies]',
             '[build-dependencies]', '[workspace.dependencies]'):
        for ln in b.splitlines():
            s = ln.strip()
            if not s or s.startswith('#'):
                continue
            if re.search(r'default-features\s*=\s*true', s):
                bad.append(f"{h} {s[:80]}")
    i += 2
print("OK" if not bad else "BAD:" + ";".join(bad))
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
    checked=$((checked + 1))

    output=$(audit_one "$cargo")
    if [[ "$output" == "OK" ]]; then
        echo "PASS  $cargo: no redundant default-features=true"
    else
        echo "FAIL  $cargo: redundant default-features=true ${output#BAD:}"
        n=$(echo "${output#BAD:}" | tr ';' '\n' | grep -c .)
        bad=$((bad + n))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml files checked, $bad redundant default-features=true entries"

[[ $ok -eq 1 ]] && exit 0 || exit 1
