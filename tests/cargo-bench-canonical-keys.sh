#!/usr/bin/env bash
# For every Cargo.toml `[[bench]]` table, pin that all
# keys are canonical Cargo bench-target keys per the
# official manifest spec.
#
# Canonical bench keys (Cargo 1.85+):
#
#   name              Bench's compiled name (required)
#   path              Source file path (defaults to
#                     benches/<name>.rs)
#   test              Include in cargo test
#   bench             Include in cargo bench (default
#                     true)
#   doc               Include in cargo doc
#   doctest           Run doc-tests
#   harness           Use Cargo's default bench harness
#                     (false for criterion etc.)
#   edition           Rust edition override
#   crate-type        Output crate type
#   required-features Feature requirement
#
# A non-canonical key in [[bench]]:
#
#   [[bench]]
#   name = "my_bench"
#   harnes = false               # WRONG — typo
#   path-prefix = "benches/"     # WRONG — invented
#   required_features = ["nightly"]  # WRONG — snake
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key: bench.harnes
#   warning: unused manifest key:
#     bench.required_features
#
# Bench still loads; warnings may be filtered in CI
# logs. The INTENDED configuration is silently NOT
# applied:
#
#   - harnes = false → ignored; harness stays at
#     default true; criterion's custom harness is
#     bypassed; bench runs but with WRONG metrics
#     (Cargo's built-in vs criterion's full
#     statistical analysis)
#
#   - required_features = ["nightly"] → ignored;
#     bench is registered without the feature gate;
#     `cargo bench` tries to build it on stable
#     Rust; build fails with cryptic nightly-only
#     errors — blamed on Rust version, real cause is
#     the typo
#
# Criterion is the most common reason `harness =
# false` is set on benches. A typo there means the
# bench RUNS but with stdlib's `#[bench]` harness
# instead of criterion's macros, producing
# meaningless metrics that look correct in CI logs.
#
# Common typo sources:
#
#   harnes              → harness            (one-char
#                                              typo)
#   required_features   → required-features  (snake→kebab)
#   bench_name          → name               (suffix)
#   sourcepath          → path               (compound)
#   src                 → path               (synonym)
#   path-prefix         → (not a key — paths are
#                          full, not prefixed)
#   crate_type          → crate-type         (snake→kebab)
#
# Detection: TOML-parse each Cargo.toml. For every
# entry in d['bench'], check each key against the
# canonical set.
#
# Pairs with cargo manifest hygiene catalog (seventh
# in the family):
#   cargo-bin-canonical-keys       — [[bin]] keys
#   cargo-package-canonical-keys   — [package] keys
#   cargo-dep-canonical-keys       — dep inline-table keys
#   cargo-profile-canonical-keys   — [profile.*] keys
#   cargo-workspace-canonical-keys — [workspace] keys
#   cargo-lib-canonical-keys       — [lib] keys
#   cargo-bench-canonical-keys (this) — [[bench]] keys
#
# Seven-table coverage of cargo manifest's most typo-
# prone surfaces.
#
# 11/11 [[bench]] blocks canonical at iter-226 add —
# pure regression floor.
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
    'harness', 'edition', 'crate-type',
    'required-features',
}
total = 0
bad = []
for i, x in enumerate(d.get('bench', [])):
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
                echo "FAIL  $cargo: [[bench]] $b — non-canonical key (cargo emits 'unused manifest key' + intended bench config silently NOT applied)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked [[bench]] blocks checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
