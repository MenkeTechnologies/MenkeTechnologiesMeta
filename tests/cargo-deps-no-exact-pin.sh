#!/usr/bin/env bash
# For every Cargo.toml dependency entry, pin that the version
# specifier is NOT an exact pin of the form `=N.N.N`.
#
# Cargo accepts the `=` prefix as an "exactly this version,
# nothing else" requirement. While occasionally legitimate
# (e.g., depending on a crate's unstable internals where any
# patch bump is a breaking change), exact pins in published
# crates create three problems:
#
#   1. SEMVER RESOLUTION CONFLICTS: downstream consumers that
#      depend on your crate AND a sibling crate that also
#      depends on the same dep at a different exact pin
#      (e.g., your crate pins `serde =1.0.150` while the
#      sibling pins `serde =1.0.180`) — Cargo cannot resolve
#      because there's no overlap, even though semver says
#      both should be compatible.
#   2. SECURITY UPDATES BLOCKED: a patch release with a CVE
#      fix (1.0.150 → 1.0.151) doesn't apply to exact-pinned
#      consumers. The fix sits unreachable until the publisher
#      updates the pin.
#   3. ECOSYSTEM TAX: every new patch release of the dep
#      requires a new release of EVERY exact-pinned consumer.
#      Multiplies the maintenance overhead of the dep across
#      the whole tree.
#
# Cargo.lock already serves the reproducibility role at the
# binary-crate level (locked builds via `cargo build --locked`).
# Exact pins in Cargo.toml duplicate that job at the cost of
# semver flexibility.
#
# Detection: short-form `name = "=1.2.3"` AND table-form
# `name = { version = "=1.2.3", ... }`. Caret (`^`) and tilde
# (`~`) prefixes are accepted as the canonical semver patterns.
# Bare `"1.2.3"` is implicitly caret (`^1.2.3`).
#
# 43 dep tables scanned, 0 exact pins at iter-110 add — pure
# regression floor against accidental exact-pin introduction.
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
exact=0

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
    if h in ('[dependencies]', '[dev-dependencies]', '[build-dependencies]', '[workspace.dependencies]'):
        for ln in b.splitlines():
            s = ln.strip()
            if not s or s.startswith('#'):
                continue
            # Short form: name = "=1.2.3"
            m1 = re.match(r'^([a-zA-Z0-9_-]+)\s*=\s*"(=[^"]+)"', s)
            if m1:
                bad.append(f"{h} {m1.group(1)} = \"{m1.group(2)}\"")
                continue
            # Table form: name = { version = "=1.2.3", ... }
            m2 = re.match(r'^([a-zA-Z0-9_-]+)\s*=\s*\{.*version\s*=\s*"(=[^"]+)"', s)
            if m2:
                bad.append(f"{h} {m2.group(1)} table version=\"{m2.group(2)}\"")
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
        echo "PASS  $cargo: no exact-pinned deps"
    else
        echo "FAIL  $cargo: exact-pinned deps: ${output#BAD:}"
        n=$(echo "${output#BAD:}" | tr ';' '\n' | grep -c .)
        exact=$((exact + n))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Cargo.toml files checked, $exact exact-pinned dep entries"

[[ $ok -eq 1 ]] && exit 0 || exit 1
