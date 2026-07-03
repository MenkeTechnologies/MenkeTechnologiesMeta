#!/usr/bin/env bash
# For every workflow yml step using `Swatinem/rust-
# cache`, pin that the `with:` block uses only
# canonical parameter keys per the action's
# action.yml schema.
#
# Canonical Swatinem/rust-cache v2 with-keys:
#
#   prefix-key            Prefix for cache key
#                         (default 'v0-rust')
#   shared-key            Shared cache key (for
#                         job sharing)
#   key                   Additional cache key
#                         segment
#   env-vars              Env vars to include in
#                         cache key (default
#                         CARGO/CC/CFLAGS/CXX/
#                         CMAKE/RUST)
#   workspaces            Workspace paths to
#                         cache (default '.')
#   cache-directories     Extra dirs to cache
#                         beyond cargo/target
#   cache-targets         Cache target/ directory
#                         (default true)
#   cache-on-failure      Save cache even if job
#                         fails (default false)
#   cache-all-crates      Cache all dep crates
#                         (default false; only
#                         cache deps used)
#   save-if               Conditional save expr
#   cache-provider        Cache backend
#                         (github/buildjet)
#   lookup-only           Check existence without
#                         download
#   cache-bin             Cache ~/.cargo/bin
#                         (default true)
#
# A non-canonical key in Swatinem/rust-cache `with:`:
#
#   - uses: Swatinem/rust-cache@v2
#     with:
#       prefix_key: v0-build         # WRONG — snake
#       shared_key: shared           # WRONG — snake
#       env_vars: "CUSTOM_VAR"       # WRONG — snake
#       cache_directories: ./extras  # WRONG — snake
#       cache_on_failure: true       # WRONG — snake
#       cache_targets: false         # WRONG — snake
#       cache_all_crates: true       # WRONG — snake
#       save_if: ${{ ... }}          # WRONG — snake
#
# GitHub Actions silently IGNORES unknown with-keys.
# The action runs with DEFAULTS:
#
#   - prefix_key (snake) → ignored; cache uses
#     'v0-rust' default prefix; cache shared with
#     unrelated workflow runs that share the
#     default prefix; cross-workflow cache pollution
#
#   - shared_key (snake) → ignored; no shared key;
#     each job in matrix gets independent cache;
#     the intended cross-leg cache sharing doesn't
#     happen; multi-OS matrix double-builds deps
#
#   - env_vars (snake) → ignored; custom env vars
#     not included in cache key; cache hit even when
#     CC / CFLAGS / target-specific env changed →
#     stale cache produces wrong artifacts; "works
#     on my machine, breaks in CI"
#
#   - cache_directories (snake) → ignored; only
#     cargo + target cached; the contributor's
#     extra dirs (e.g., ./build-artifacts) stay
#     uncached; full rebuild every run
#
#   - cache_on_failure (snake) → ignored; default
#     false; flaky test failures leave cache without
#     updates; cumulative cache rot over many
#     transient failures
#
#   - cache_all_crates (snake) → ignored; default
#     false; only USED deps are cached; deps
#     gated behind features that are flipped on
#     in a future run produce a cache miss
#     unnecessarily
#
#   - save_if (snake) → ignored; cache always
#     saves; conditional save logic the contributor
#     wrote doesn't apply
#
# Common typo class: snake_case (prefix_key,
# shared_key, env_vars, cache_directories,
# cache_on_failure, cache_all_crates, save_if) or
# camelCase (prefixKey, envVars, cacheOnFailure)
# instead of kebab-case. The action uses kebab-case
# uniformly — no camelCase irregularities like
# actions/cache's enableCrossOsArchive.
#
# Detection: YAML-parse. For every uses: Swatinem/
# rust-cache@<v>, check with: keys vs canonical v2
# set.
#
# Pairs with canonical-keys family — sixteenth table.
# Fourth-most-used action (145 uses).
#
# 145/145 with-keys canonical at iter-235 add — pure
# regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi

checked=0
bad=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    result=$(python3 - "$wf" <<'PY'
import sys, yaml
try:
    d = yaml.safe_load(open(sys.argv[1]))
except Exception:
    print('0|')
    sys.exit()
if not isinstance(d, dict):
    print('0|')
    sys.exit()
allowed = {
    'prefix-key', 'shared-key', 'key', 'env-vars',
    'workspaces', 'cache-directories', 'cache-targets',
    'cache-on-failure', 'cache-all-crates', 'save-if',
    'cache-provider', 'lookup-only', 'cache-bin',
}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        u = step.get('uses')
        if not isinstance(u, str):
            continue
        if 'Swatinem/rust-cache' not in u:
            continue
        total += 1
        w = step.get('with', {})
        if not isinstance(w, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        for k in w.keys():
            if k not in allowed:
                bad.append(f'{jn}/{sn}:{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: Swatinem/rust-cache $b — non-canonical with-key (silently ignored; default applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/_deps/*' -prune \
    -o -path '*/libs/JUCE/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked Swatinem/rust-cache uses checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
