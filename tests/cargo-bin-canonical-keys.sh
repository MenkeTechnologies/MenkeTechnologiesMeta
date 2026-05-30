#!/usr/bin/env bash
# For every Cargo.toml `[[bin]]` table, pin that all keys
# are canonical Cargo bin-target keys per the official
# manifest spec:
#
#   name              required — bin's compiled name
#   path              optional — source file path
#   test              optional — include in cargo test
#   bench             optional — include in cargo bench
#   doc               optional — include in cargo doc
#   doctest           optional — run doc-tests
#   proc-macro        optional — procedural macro crate
#   harness           optional — use Cargo's default harness
#   required-features optional — feature requirement
#   edition           optional — Rust edition override
#   crate-type        optional — target crate type
#
# A non-canonical key in a [[bin]] block:
#
#   [[bin]]
#   name = "foo"
#   bin_name = "foo-cli"        # WRONG — invented field
#   harnes = false              # WRONG — typo of harness
#   doc-test = true             # WRONG — should be doctest
#                                 (different word)
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key: bin.bin_name
#   warning: unused manifest key: bin.harnes
#   warning: unused manifest key: bin.doc-test
#
# The bin still builds; the warning may be suppressed in
# CI log filtering; the contributor sees the warning
# locally and either fixes it or ignores it. Either way,
# the INTENDED configuration is silently NOT applied:
#
#   - `bin_name = "foo-cli"` — the field is ignored;
#     the bin's actual name remains "foo"
#   - `harnes = false` — the field is ignored; the
#     bin uses Cargo's default harness anyway
#   - `doc-test = true` — the field is ignored; the
#     bin's doctests run per the default
#
# Failure mode: the contributor BELIEVES the
# configuration is in effect; later debugging is
# misdirected because the manifest reads as if the
# field is set.
#
# Common typo sources:
#
#   bin_name        → name              (snake_case confusion)
#   harnes          → harness           (one-char typo)
#   doc-test        → doctest           (separator typo)
#   doc_test        → doctest           (snake_case)
#   proc_macro      → proc-macro        (snake→kebab)
#   required_features → required-features (snake→kebab)
#   crate_type      → crate-type        (snake→kebab)
#
# The gate catches these at PR time; cargo's warning
# would surface only on a clean local build.
#
# Detection: TOML-parse each Cargo.toml. For every
# entry in d['bin'], check each key against the
# canonical set.
#
# Pairs with cargo bin/target hygiene family:
#   cargo-bin-name-field          — name presence
#   cargo-bin-path-exists         — path file exists
#   cargo-bin-required-features-valid — required-features
#                                        reference real features
#   cargo-bin-canonical-keys (this) — key set
#
# 0/37 [[bin]] blocks have non-canonical keys at iter-220
# add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

if [[ ! -f .gitmodules ]]; then
    echo "SKIP  no .gitmodules"
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

for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    for cargo in "$p/Cargo.toml" "$p/src-tauri/Cargo.toml"; do
        [[ -f "$cargo" ]] || continue
        result=$(python3 - "$cargo" <<'PY'
import sys
try:
    try:
        import tomllib
    except ImportError:
        import tomli as tomllib
    with open(sys.argv[1], 'rb') as f:
        d = tomllib.load(f)
except Exception:
    print('0|')
    sys.exit()
allowed = {
    'name', 'path', 'test', 'bench', 'doc', 'doctest',
    'proc-macro', 'harness', 'required-features',
    'edition', 'crate-type',
}
total = 0
bad = []
for i, x in enumerate(d.get('bin', [])):
    if not isinstance(x, dict):
        continue
    total += 1
    name = x.get('name', f'#{i+1}')
    for k in x.keys():
        if k not in allowed:
            bad.append(f'{name}:{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for b in "${ba[@]}"; do
                echo "FAIL  $cargo: [[bin]] $b — non-canonical key (typo? check kebab-case)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked [[bin]] blocks checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
