#!/usr/bin/env bash
# For every Cargo.toml's [package] section, pin that the
# canonical minimum trio of fields is declared:
#
#   name        — crate identifier
#   version     — release version (semver)
#   edition     — Rust edition guard
#
# Each field can be either:
#   - Direct: `name = "foo"` / `version = "0.1.0"` / `edition = "2021"`
#   - Inherited: `name.workspace = true` (rare for name, common
#                for version/edition in workspace setups)
#
# Cargo refuses to build a [package] manifest missing any of
# the three:
#
#   error: missing field `name`
#   error: missing field `version`
#   error: edition `<value>` is unstable, the only allowed
#          values are 2015, 2018, 2021, 2024, or omit edition
#
# The omit-edition case is technically allowed (Cargo defaults
# to 2015 if absent), but that's a footgun: a fresh `cargo
# new` produces 2024 today, so a manifest without edition is
# effectively a legacy-edition silent demotion.
#
# Lint-time detection catches these gaps before any Rust build
# slot is consumed. The errors are sub-second to detect with
# a regex walk; the equivalent cargo-side error fires only
# after dep resolution and target/ restoration (multi-minute
# CI cost).
#
# Detection: for each field, accept EITHER direct declaration
# (`field = ...`) OR workspace inheritance (`field.workspace =
# true`). At least one form per field must be present.
#
# Other [package] fields (license, description, repository,
# etc.) are checked by their own gates (cargo-description-
# length, cargo-repository-field, license-file-present, etc.).
# This gate focuses on the ABSOLUTE minimum that Cargo itself
# rejects building without.
#
# 27/27 crates green at iter-130 add — pure regression floor
# against accidental field deletion during manifest refactor.
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
m = re.search(r'(?ms)^\[package\]\n(.*?)(?=\n\[|\Z)', content)
if not m:
    print("NO_PACKAGE")
    sys.exit()
body = m.group(1)
missing = []
for f in ('name', 'version', 'edition'):
    has_direct = bool(re.search(rf'(?m)^{f}\s*=', body))
    has_inherit = bool(re.search(rf'(?m)^{f}\.workspace\s*=\s*true', body))
    if not has_direct and not has_inherit:
        missing.append(f)
print("OK" if not missing else "BAD:" + ",".join(missing))
PY
}

checked=0
bad=0

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue

    for cargo in "$p/Cargo.toml" "$p/src-tauri/Cargo.toml"; do
        [[ -f "$cargo" ]] || continue
        output=$(audit_one "$cargo")
        case "$output" in
            NO_PACKAGE) continue ;;
            OK)
                checked=$((checked + 1))
                echo "PASS  $cargo: name + version + edition all declared"
                ;;
            BAD:*)
                checked=$((checked + 1))
                echo "FAIL  $cargo: [package] missing required field(s) ${output#BAD:}"
                bad=$((bad + 1))
                ok=0
                ;;
        esac
    done
done

echo "---"
echo "Summary: $checked [package] sections checked, $bad missing one of name/version/edition"

[[ $ok -eq 1 ]] && exit 0 || exit 1
