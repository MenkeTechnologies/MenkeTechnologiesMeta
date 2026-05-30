#!/usr/bin/env bash
# For every Cargo.toml inline-table dependency entry
# (`serde = { version = "1", features = [...] }`), pin
# that all keys in the inline table are canonical Cargo
# dependency-spec keys per the official manifest spec.
#
# Canonical inline-table dep keys (Cargo 1.85+):
#
#   version           Semver requirement string
#   features          Feature activation list
#   optional          Make dep optional (gated on a
#                     feature)
#   default-features  Disable/enable upstream default
#                     features
#   path              Local path dep (relative)
#   git               Git URL for git dep
#   branch            Git branch
#   tag               Git tag
#   rev               Git revision SHA
#   workspace         Inherit from [workspace.dependencies]
#   registry          Alternative registry name
#   registry-index    Alternative registry URL
#   package           Crate name (when key is alias)
#
# A non-canonical key in an inline-table dep:
#
#   serde = {
#       version = "1",
#       feature = ["derive"],         # WRONG — singular
#       default_features = false,     # WRONG — snake_case
#       optionnal = true,             # WRONG — typo
#       registery = "internal"        # WRONG — typo
#   }
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key:
#     dependencies.serde.feature
#   warning: unused manifest key:
#     dependencies.serde.default_features
#   warning: unused manifest key:
#     dependencies.serde.optionnal
#
# Dep still resolves; warnings may be filtered in CI
# logs. The INTENDED configuration is silently NOT
# applied:
#
#   - feature = ["derive"] (singular) → ignored;
#     features list stays empty; `derive` macro not
#     enabled; build fails with "no Derive macro" on
#     downstream `use` of #[derive(Serialize)] —
#     blamed on user code, real cause is the typo
#
#   - default_features = false → ignored; upstream
#     default features stay enabled; transitive deps
#     pull in extra std features the crate's no-std
#     build forbids; build fails on no-std target
#     with cryptic error
#
#   - optionnal = true → ignored; dep is non-
#     optional; features that "depend on optionnal
#     dep" don't gate it properly; --no-default-
#     features still pulls the dep
#
#   - registery = "internal" → ignored; cargo uses
#     default registry; resolution fails with
#     "package not found in crates.io" when the dep
#     was only published to the internal registry
#
# Most failure modes are MISDIAGNOSED because the
# manifest reads as if the field is set. Contributors
# search the source code for the bug instead of the
# manifest.
#
# Common typo sources:
#
#   feature             → features         (singular)
#   default_features    → default-features (snake→kebab)
#   defaults-features   → default-features (plural in
#                                           wrong place)
#   optionnal           → optional         (typo)
#   regestry / registery → registry        (typo)
#   workspace=true (no
#   space)              → workspace = true (spacing —
#                                           but TOML
#                                           normalizes
#                                           this; not
#                                           a real typo)
#   branchname          → branch           (suffix)
#   git_url             → git              (suffix)
#
# Detection: TOML-parse each Cargo.toml. For every
# inline-table dep in [dependencies], [dev-dependencies],
# [build-dependencies], check each key against the
# canonical set.
#
# Pairs with cargo manifest hygiene catalog:
#   cargo-bin-canonical-keys      — [[bin]] keys
#   cargo-package-canonical-keys  — [package] keys
#   cargo-dep-canonical-keys (this) — dep inline-table keys
#
# Three-table coverage of cargo manifest's most-typo-
# prone surfaces.
#
# 168/168 inline-table deps use canonical keys at
# iter-222 add — pure regression floor.
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
    'version', 'features', 'optional', 'default-features',
    'path', 'git', 'branch', 'tag', 'rev', 'workspace',
    'registry', 'registry-index', 'package',
}
total = 0
bad = []
for sec in ('dependencies', 'dev-dependencies', 'build-dependencies'):
    for k, v in (d.get(sec, {}) or {}).items():
        if not isinstance(v, dict):
            continue
        total += 1
        for kk in v.keys():
            if kk not in allowed:
                bad.append(f'{sec}.{k}.{kk}')
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for b in "${ba[@]}"; do
                echo "FAIL  $cargo: $b — non-canonical dep key (cargo emits 'unused manifest key' + intended config silently NOT applied)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked inline-table deps checked, $bad non-canonical key uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
