#!/usr/bin/env bash
# For every Cargo.toml `[profile.<name>]` table, pin
# that all keys are canonical Cargo profile keys per
# the official manifest spec.
#
# Canonical profile keys (Cargo 1.85+):
#
#   opt-level          0/1/2/3/"s"/"z" — opt level
#   debug              true/false/0-2  — debug info
#   debug-assertions   bool — runtime assertion check
#   overflow-checks    bool — integer overflow check
#   lto                true/false/"fat"/"thin"/"off"
#   codegen-units      int — codegen units
#   rpath              bool — encode rpath in binary
#   strip              "none"/"debuginfo"/"symbols"/
#                      bool
#   incremental        bool — incremental compile
#   panic              "abort"/"unwind"
#   split-debuginfo    "off"/"packed"/"unpacked"
#   trim-paths         "none"/"object"/"diagnostics"/
#                      "all"/"macro"/bool
#   package            { <name> = { ... } } —
#                      package-specific overrides
#   build-override     { ... } — build script overrides
#   inherits           profile name to inherit from
#
# A non-canonical key in a [profile.*] block:
#
#   [profile.release]
#   opt_level = 3              # WRONG — snake_case
#   lto-level = "fat"          # WRONG — invented key
#   codegen_units = 1          # WRONG — snake_case
#   debug_assertions = false   # WRONG — snake_case
#   stripped = true            # WRONG — wrong tense
#   panic_strategy = "abort"   # WRONG — invented key
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key: profile.release.opt_level
#   warning: unused manifest key: profile.release.lto-level
#
# The crate still builds; warning may be filtered in CI
# logs. The INTENDED profile configuration is silently
# NOT applied, leaving the profile at its DEFAULTS:
#
#   - opt_level = 3 → ignored; release uses default
#     opt-level=3 (matches accident in this case, but
#     opt_level = 1 would silently produce un-
#     optimized release builds)
#
#   - lto-level = "fat" → ignored; LTO stays at
#     default (false for release); produced binaries
#     are 10-30% larger than expected
#
#   - codegen_units = 1 → ignored; codegen-units
#     stays at default 16; opt quality degrades
#     across translation units
#
#   - panic_strategy = "abort" → ignored; panic stays
#     at default "unwind"; binary size 10-15% larger
#     than intended; unwinding tables stay shipped
#
# Failure mode: the contributor BELIEVES the profile
# optimization is configured. CI build produces
# binaries with the WRONG characteristics (size,
# perf). Benchmarking against the published binary
# shows different numbers than local builds.
#
# Common typo sources:
#
#   opt_level         → opt-level         (snake→kebab)
#   debug_assertions  → debug-assertions  (snake→kebab)
#   overflow_checks   → overflow-checks   (snake→kebab)
#   codegen_units     → codegen-units     (snake→kebab)
#   split_debuginfo   → split-debuginfo   (snake→kebab)
#   trim_paths        → trim-paths        (snake→kebab)
#   build_override    → build-override    (snake→kebab)
#   stripped          → strip             (wrong tense)
#   panic_strategy    → panic             (suffix)
#   lto_level         → lto               (suffix)
#   optimize-level    → opt-level         (long name)
#
# Detection: TOML-parse each Cargo.toml. For every
# top-level table d['profile'][<name>], check each
# key against the canonical set. Skip the special
# `package.<crate>` and `build-override` nested
# tables — those have their own scoped key space.
#
# Pairs with cargo manifest hygiene catalog:
#   cargo-bin-canonical-keys      — [[bin]] keys
#   cargo-package-canonical-keys  — [package] keys
#   cargo-dep-canonical-keys      — dep inline-table keys
#   cargo-profile-canonical-keys (this) — [profile.*] keys
#
# Four-table coverage of cargo manifest's most typo-
# prone surfaces.
#
# 27/27 [profile.*] blocks use canonical keys at
# iter-223 add — pure regression floor.
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
    'opt-level', 'debug', 'debug-assertions',
    'overflow-checks', 'lto', 'codegen-units',
    'rpath', 'strip', 'incremental', 'panic',
    'split-debuginfo', 'trim-paths', 'package',
    'build-override', 'inherits',
}
prof = d.get('profile', {})
if not isinstance(prof, dict):
    print('0|')
    sys.exit()
total = 0
bad = []
for pn, pval in prof.items():
    if not isinstance(pval, dict):
        continue
    total += 1
    for k in pval.keys():
        if k not in allowed:
            bad.append(f'profile.{pn}.{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for b in "${ba[@]}"; do
                echo "FAIL  $cargo: $b — non-canonical profile key (cargo emits 'unused manifest key' + profile silently uses defaults instead)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked [profile.*] blocks checked, $bad non-canonical key uses"

[[ $ok -eq 1 ]] && exit 0 || exit 1
