#!/usr/bin/env bash
# For every publishable Rust Cargo.toml, pin that each entry in
# [dependencies], [dev-dependencies], and [build-dependencies]
# has SOME version specifier — either a string ("1.0"), a table
# with version= / workspace= / path= / git= key, or skipped
# entirely because the parser only flags TABLE entries lacking
# all four pointer fields.
#
# crates.io's publish API requires every dependency to declare
# its source (version, workspace, path, or git). A bare table
# like `foo = { features = ["full"] }` has features but no
# pointer — Cargo fails publish with:
#
#   error: failed to prepare local package for uploading
#   caused by: all dependencies must have a version specified
#   when publishing. dependency `foo` does not specify a version
#
# This is the third member of the publish-blocker class (after
# iter-62 wildcards, iter-66 git-only deps). All three blockers
# fail at publish time — slow feedback. Same lint-time check
# pattern, sub-second cost.
#
# Detection logic:
#   - Short-form `foo = "1.0"` → PASS (has version string)
#   - Table form `foo = { ... }`:
#     - Has `version = ` field    → PASS
#     - Has `workspace = ` field  → PASS (inherits from workspace)
#     - Has `path = ` field       → PASS (local path dep — also
#                                      a publish blocker but
#                                      caught by Cargo's own
#                                      check separately)
#     - Has `git = ` field        → PASS (caught by iter-66 if
#                                      publishable)
#     - None of the above         → FAIL (no source pointer)
#
# publish=false crates SKIPPED — they don't go to crates.io so
# the publish-time block doesn't apply.
#
# 11/11 publishable crates green at iter-86 add — pure regression
# floor.
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
skipped=0

audit_one() {
    python3 - "$1" << 'PY'
import sys, re
cargo = sys.argv[1]
content = open(cargo).read()
sections = re.split(r'(?m)^(\[[^\]]+\])', content)
i = 1
bad_lines = []
while i < len(sections):
    h = sections[i]
    b = sections[i+1] if i+1 < len(sections) else ''
    if h in ('[dependencies]', '[dev-dependencies]', '[build-dependencies]'):
        for ln in b.splitlines():
            stripped = ln.strip()
            if not stripped or stripped.startswith('#'):
                continue
            m = re.match(r'^([a-zA-Z0-9_-]+) *= *(.+)$', stripped)
            if not m:
                continue
            name = m.group(1)
            value = m.group(2).strip()
            if value.startswith(('"', "'")):
                continue
            if value.startswith('{'):
                if re.search(r'\b(version|workspace|path|git)\s*=', value):
                    continue
                bad_lines.append(f"{h} {name}")
    i += 2
print("OK" if not bad_lines else "BAD:" + ";".join(bad_lines))
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

    if grep -qE '^publish *= *false' "$cargo"; then
        skipped=$((skipped + 1))
        continue
    fi
    checked=$((checked + 1))

    output=$(audit_one "$cargo")
    if [[ "$output" == "OK" ]]; then
        echo "PASS  $cargo: all deps have source pointer"
    else
        echo "FAIL  $cargo: deps lacking version/workspace/path/git: ${output#BAD:}"
        n=$(echo "${output#BAD:}" | tr ';' '\n' | grep -c .)
        bad=$((bad + n))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked publishable crates checked ($skipped publish=false skipped), $bad dep entries without source pointer"

[[ $ok -eq 1 ]] && exit 0 || exit 1
