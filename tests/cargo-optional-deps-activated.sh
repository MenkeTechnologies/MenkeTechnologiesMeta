#!/usr/bin/env bash
# For every Cargo.toml dependency entry marked `optional = true`,
# pin that the dep is referenced by at least one feature in the
# [features] table.
#
# Optional dependencies in Cargo follow this pattern:
#
#   [dependencies]
#   foo = { version = "1.0", optional = true }
#
#   [features]
#   default = ["with-foo"]
#   with-foo = ["dep:foo"]      # or just "foo" in pre-1.60 syntax
#
# When the `with-foo` feature is enabled, Cargo activates the
# `foo` dependency. Without that feature reference, `foo` is
# NEVER activated — it sits as DEAD METADATA in the manifest:
#
#   - cargo metadata resolves foo's transitive graph (slow)
#   - dep audit tools (cargo-audit, cargo-deny) include foo in
#     their scan even though no code path uses it
#   - reviewers see foo in [dependencies] and assume it's
#     pulled by some feature — burning review time tracing it
#   - Cargo doesn't emit a warning; the orphan is silent
#
# Detection: walk every `[dependencies]` / `[dev-dependencies]` /
# `[build-dependencies]` section, collect entries with
# `optional = true`. Then scan the [features] section body
# for references to each optional dep in any of three forms:
#
#   "dep_name"           — pre-1.60 implicit-feature syntax
#   "dep:dep_name"       — 1.60+ explicit dep activation
#   "dep_name/feat"      — activate a feature on the dep
#                          (also implicitly activates the dep)
#
# If none of those forms appears in the features body, the
# dep is ORPHAN.
#
# 11/11 optional deps activated at iter-149 add — pure
# regression floor.
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

audit_one() {
    python3 - "$1" << 'PY'
import sys, re
cargo = sys.argv[1]
content = open(cargo).read()
sections = re.split(r'(?m)^(\[[^\]]+\])', content)
i = 1
optional_deps = []
while i < len(sections):
    h = sections[i]
    b = sections[i+1] if i+1 < len(sections) else ''
    if h in ('[dependencies]', '[dev-dependencies]', '[build-dependencies]'):
        for ln in b.splitlines():
            s = ln.strip()
            if not s or s.startswith('#'):
                continue
            nm = re.match(r'^([a-zA-Z0-9_-]+)\s*=\s*\{', s)
            if nm and re.search(r'optional\s*=\s*true', s):
                optional_deps.append(nm.group(1))
    i += 2

if not optional_deps:
    print("NO_OPTIONAL")
    sys.exit()

m = re.search(r'(?ms)^\[features\]\n(.*?)(?=\n\[|\Z)', content)
feature_body = m.group(1) if m else ''

results = []
for dep in optional_deps:
    esc = re.escape(dep)
    pat = rf'"(dep:)?{esc}(/[a-zA-Z0-9_-]+)?"'
    if re.search(pat, feature_body):
        results.append(f"OK:{dep}")
    else:
        results.append(f"BAD:{dep}")
print("\n".join(results))
PY
}

checked=0
orphan=0

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
    [[ "$output" == "NO_OPTIONAL" ]] && continue

    while IFS=: read -r status dep; do
        [[ -z "$status" ]] && continue
        checked=$((checked + 1))
        if [[ "$status" == "OK" ]]; then
            echo "PASS  $cargo: optional dep \"$dep\" activated by a feature"
        else
            echo "FAIL  $cargo: optional dep \"$dep\" not referenced in [features] — orphan dead code"
            orphan=$((orphan + 1))
            ok=0
        fi
    done <<< "$output"
done

echo "---"
echo "Summary: $checked optional deps checked, $orphan unactivated by any feature"

[[ $ok -eq 1 ]] && exit 0 || exit 1
