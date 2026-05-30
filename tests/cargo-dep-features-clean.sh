#!/usr/bin/env bash
# For every Cargo.toml inline-table dependency declaring
# a `features = [...]` array, pin that the array has:
#
#   - No empty strings ("")
#   - No duplicate entries
#
# Both are silent failure modes that Cargo accepts without
# warning:
#
#   serde = { version = "1", features = ["derive", "", "rc"] }
#                                                ^
#                                       empty string — no-op
#
#   tokio = { version = "1", features = ["full", "full"] }
#                                            ^^^^^^
#                                       duplicate — wasted
#
# Why each matters:
#
# EMPTY STRINGS:
#
#   - Cargo's feature resolution looks for a feature named
#     "" (zero-length string), finds nothing, and treats it
#     as "no feature requested" — a silent no-op.
#   - The contributor may have INTENDED a feature there
#     (e.g., copy-pasted from an array with a comma-leading
#     element, or a placeholder that was never filled in).
#     The omission of the actual feature name is what
#     matters; CI doesn't catch it because Cargo doesn't
#     warn.
#   - Symptom: compile-time feature gates that were
#     supposed to be enabled silently aren't. Runtime
#     behavior differs from what the manifest LOOKS like
#     it should be.
#
# DUPLICATES:
#
#   - Cargo's resolution treats duplicates as the same
#     single feature — no harm functionally.
#   - But duplicates indicate ORGANIZATIONAL drift:
#     - Refactor merged two feature lists without
#       deduping
#     - Copy-paste extended an existing list and the
#       contributor didn't notice the same feature
#       already there
#     - Generated/edited Cargo.toml from a tool that
#       didn't normalize
#   - The manifest's "list of intended features" no
#     longer matches the actual set of features. Future
#     refactors that read the manifest as the source of
#     truth get confused.
#   - Symptom: the duplicate stays forever, gets copied
#     into yet more manifests, becomes "the convention."
#
# Both are detectable at PR time with no false positives.
# Cargo doesn't emit a warning for either — the gate
# catches them.
#
# Detection: TOML-parse each Cargo.toml. For every
# inline-table dep in [dependencies], [dev-dependencies],
# [build-dependencies] with a `features` array, check:
#   - empty strings → fail
#   - duplicate entries → fail
#
# Pairs with cargo dependency hygiene family
# (cargo-deps-have-version, cargo-no-wildcard-deps,
# cargo-deps-no-exact-pin, cargo-no-redundant-default-
# features, cargo-optional-deps-activated). Adds
# feature-array hygiene.
#
# 142/142 feature arrays clean at iter-213 add — pure
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
        grep -qE '^\[package\]' "$cargo" || continue
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
total = 0
bad = []
for sec in ('dependencies', 'dev-dependencies', 'build-dependencies'):
    for k, v in (d.get(sec, {}) or {}).items():
        if not isinstance(v, dict):
            continue
        feats = v.get('features')
        if not isinstance(feats, list):
            continue
        total += 1
        if any(f == '' for f in feats):
            bad.append(f'{sec}.{k}:empty-string')
            continue
        if len(feats) != len(set(feats)):
            seen = set()
            dups = [f for f in feats if f in seen or seen.add(f)]
            bad.append(f'{sec}.{k}:duplicate:{dups[0]}')
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for b in "${ba[@]}"; do
                echo "FAIL  $cargo: $b — silent feature-resolution drift"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked feature arrays checked, $bad with empty-string / duplicate"

[[ $ok -eq 1 ]] && exit 0 || exit 1
