#!/usr/bin/env bash
# For every Cargo.toml `[workspace]` table, pin that
# all keys are canonical Cargo workspace keys per the
# official manifest spec.
#
# Canonical workspace keys (Cargo 1.85+):
#
#   members           Array of member crate paths
#   exclude           Array of paths to exclude
#   default-members   Subset for cargo without --workspace
#   resolver          "1"/"2"/"3" dependency resolver
#   dependencies      [workspace.dependencies] table
#                     for sharing dep specs across members
#   package           [workspace.package] table for
#                     sharing package metadata
#                     (description, license, repository,
#                     etc.)
#   metadata          Custom workspace-level metadata
#   lints             [workspace.lints] for lint config
#
# A non-canonical key in [workspace]:
#
#   [workspace]
#   members = ["crate-a", "crate-b"]
#   default_members = ["crate-a"]   # WRONG — snake_case
#   resolvr = "2"                   # WRONG — typo
#   member-exclude = ["..."]        # WRONG — invented key
#   dev-dependencies = { ... }      # WRONG — not in
#                                     workspace schema
#
# Cargo's response is a WARNING, not an error:
#
#   warning: unused manifest key:
#     workspace.default_members
#   warning: unused manifest key:
#     workspace.resolvr
#
# Workspace still loads; warning may be filtered in CI
# logs. The INTENDED configuration is silently NOT
# applied:
#
#   - default_members → ignored; cargo without
#     --workspace builds ALL members instead of the
#     subset; longer CI runs, unintended deps
#     resolved
#
#   - resolvr = "2" → ignored; resolver stays at
#     default (typically "1" for older workspaces,
#     "2" for newer); feature unification behavior
#     differs from what the contributor intended;
#     transitive dep duplication or absent features
#
#   - member-exclude = [...] → ignored; the "exclude"
#     path stays unset; workspace tries to load the
#     directory as a member, fails with cryptic
#     "Cargo.toml not found"
#
#   - dev-dependencies in [workspace] → ignored;
#     contributor expects workspace-shared dev deps;
#     each member silently uses its own dev deps
#     (or none) instead
#
# Failure modes are often delayed: workspace LOADS,
# basic operations work, but cargo subcommands
# behave unexpectedly. Contributor blames cargo
# version differences, not the manifest typo.
#
# Common typo sources:
#
#   default_members  → default-members  (snake→kebab)
#   resolvr / resolve → resolver         (typo / wrong
#                                         word)
#   exclude_paths    → exclude          (suffix)
#   member-exclude   → exclude          (compound name)
#   members_list     → members          (suffix)
#   meta             → metadata         (truncated)
#   workspace-lints  → lints            (prefix)
#   deps             → dependencies     (abbreviated)
#   dev-dependencies → (not allowed in workspace —
#                      use per-member dev-dependencies)
#
# Detection: TOML-parse each Cargo.toml. Check
# d['workspace'].keys() against canonical set.
#
# Pairs with cargo manifest hygiene catalog:
#   cargo-bin-canonical-keys       — [[bin]] keys
#   cargo-package-canonical-keys   — [package] keys
#   cargo-dep-canonical-keys       — dep inline-table keys
#   cargo-profile-canonical-keys   — [profile.*] keys
#   cargo-workspace-canonical-keys (this) — [workspace] keys
#
# Five-table coverage of cargo manifest's most typo-
# prone surfaces.
#
# 12/12 [workspace] keys canonical at iter-224 add —
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
    'members', 'exclude', 'default-members', 'resolver',
    'dependencies', 'package', 'metadata', 'lints',
}
ws = d.get('workspace')
if not isinstance(ws, dict):
    print('0|')
    sys.exit()
total = len(ws)
bad = [k for k in ws.keys() if k not in allowed]
print(f"{total}|{';'.join(bad)}")
PY
)
        n="${result%%|*}"
        bads="${result#*|}"
        checked=$((checked + n))
        if [[ -n "$bads" ]]; then
            IFS=';' read -ra ba <<< "$bads"
            for k in "${ba[@]}"; do
                echo "FAIL  $cargo: [workspace].$k — non-canonical key (cargo emits 'unused manifest key' + intended workspace config silently NOT applied)"
                bad=$((bad + 1))
                ok=0
            done
        fi
    done
done

echo "---"
echo "Summary: $checked [workspace] keys checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
