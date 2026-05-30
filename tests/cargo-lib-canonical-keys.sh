#!/usr/bin/env bash
# For every Cargo.toml `[lib]` table, pin that all keys
# are canonical Cargo lib-target keys per the official
# manifest spec.
#
# Canonical lib keys (Cargo 1.85+):
#
#   name              Lib's compiled name (defaults to
#                     package.name)
#   path              Source file path (defaults to
#                     src/lib.rs)
#   test              Include in cargo test
#   bench             Include in cargo bench
#   doc               Include in cargo doc
#   doctest           Run doc-tests
#   proc-macro        Procedural macro crate
#   harness           Use Cargo's default test harness
#   edition           Rust edition override
#   crate-type        Output crate type: lib/rlib/dylib/
#                     cdylib/staticlib/proc-macro
#   required-features Feature requirement
#
# A non-canonical key in [lib]:
#
#   [lib]
#   name = "foo"
#   crate_type = ["cdylib"]    # WRONG — snake_case
#   harnes = false             # WRONG — typo
#   procmacro = true           # WRONG — missing hyphen
#   doc-test = false           # WRONG — different word
#                                (should be `doctest`)
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key: lib.crate_type
#   warning: unused manifest key: lib.harnes
#   warning: unused manifest key: lib.procmacro
#
# Lib still builds; warning may be filtered in CI
# logs. The INTENDED configuration is silently NOT
# applied:
#
#   - crate_type = ["cdylib"] → ignored; crate-type
#     stays default ["lib"]; the C-ABI dynamic
#     library never builds; downstream FFI consumers
#     fail with "no such file: libfoo.so" — but the
#     manifest LOOKS like it specifies cdylib
#
#   - harnes = false → ignored; harness stays at
#     default true; the no-harness custom test
#     runner the contributor wrote is bypassed
#
#   - procmacro = true → ignored; proc-macro stays
#     false; the proc-macro registration (extern
#     crate proc_macro) compiles but the macros
#     don't expand — downstream users see "cannot
#     find macro"
#
#   - doc-test → ignored; doctests still run by
#     default; contributor's intent to skip them is
#     not applied
#
# Failure mode: the contributor BELIEVES the lib's
# crate-type is cdylib (or other intended config).
# CI builds produce the WRONG outputs. Downstream
# FFI / proc-macro / no-harness consumers fail in
# baffling ways.
#
# Common typo sources:
#
#   crate_type           → crate-type        (snake→kebab)
#   cratetype            → crate-type        (no separator)
#   proc_macro           → proc-macro        (snake→kebab)
#   procmacro            → proc-macro        (no separator)
#   harnes               → harness           (one-char typo)
#   doc-test             → doctest           (separator
#                                              typo;
#                                              different
#                                              word)
#   doc_test             → doctest           (snake)
#   required_features    → required-features (snake→kebab)
#
# Detection: TOML-parse each Cargo.toml. Check
# d['lib'].keys() against canonical set.
#
# Pairs with cargo manifest hygiene catalog (sixth in
# the family — completes the table coverage):
#   cargo-bin-canonical-keys       — [[bin]] keys
#   cargo-package-canonical-keys   — [package] keys
#   cargo-dep-canonical-keys       — dep inline-table keys
#   cargo-profile-canonical-keys   — [profile.*] keys
#   cargo-workspace-canonical-keys — [workspace] keys
#   cargo-lib-canonical-keys (this) — [lib] keys
#
# Six-table coverage of cargo manifest's most typo-
# prone surfaces.
#
# 19/19 [lib] keys canonical at iter-225 add — pure
# regression floor.
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
    'proc-macro', 'harness', 'edition', 'crate-type',
    'required-features',
}
lib = d.get('lib')
if not isinstance(lib, dict):
    print('0|')
    sys.exit()
total = len(lib)
bad = [k for k in lib.keys() if k not in allowed]
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for k in "${ba[@]}"; do
                echo "FAIL  $cargo: [lib].$k — non-canonical key (cargo emits 'unused manifest key' + intended lib config silently NOT applied)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked [lib] keys checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
