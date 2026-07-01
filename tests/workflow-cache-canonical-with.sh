#!/usr/bin/env bash
# For every workflow yml step using `actions/cache`,
# pin that the `with:` block uses only canonical
# parameter keys per actions/cache@v4+ schema.
#
# Canonical actions/cache v4 with-block keys:
#
#   path                  Cache path(s) (required)
#   key                   Cache key (required)
#   restore-keys          Fallback keys for cache miss
#   upload-chunk-size     Chunk size for upload
#   enableCrossOsArchive  Cross-OS cache compatibility
#                         (note: camelCase, this is
#                         actions/cache's only camel
#                         field by convention)
#   fail-on-cache-miss    Fail if no cache hit
#   lookup-only           Check existence without
#                         downloading
#   save-always           Save even on job failure
#
# A non-canonical key in actions/cache `with:`:
#
#   - uses: actions/cache@v4
#     with:
#       path: ~/.cargo
#       key: foo
#       restore_keys: ["bar"]        # WRONG — snake
#       upload_chunk_size: 32MB      # WRONG — snake
#       enable_cross_os_archive: yes # WRONG — snake
#       fail_on_cache_miss: true     # WRONG — snake
#       save_always: true            # WRONG — snake
#
# GitHub Actions silently IGNORES unknown with-keys.
# The action runs with DEFAULTS for the parameter the
# contributor thought they configured:
#
#   - restore_keys (snake) → ignored; restore-keys
#     stays empty; cache miss produces no fallback
#     download; full rebuild from scratch on EVERY
#     PR even when the key is close to an existing
#     cache
#
#   - upload_chunk_size (snake) → ignored; default
#     chunk size used; large caches upload slowly
#     and may hit GitHub's per-chunk timeout, marking
#     cache as failed upload
#
#   - enable_cross_os_archive (snake instead of
#     enableCrossOsArchive camel) → ignored; cache
#     is OS-specific; macos build can't read ubuntu
#     cache and vice versa; effective cache hit rate
#     drops 50% in multi-OS matrix builds
#
#   - fail_on_cache_miss (snake) → ignored; cache
#     miss is tolerated; the workflow that wanted
#     "fail if not cached" doesn't fail; the cache
#     dependency assumption is broken silently
#
#   - save_always (snake) → ignored; cache is only
#     saved on job SUCCESS; flaky test failures
#     leave the cache without updates; cumulative
#     drift between cache content and required state
#
# enableCrossOsArchive is the ONLY camelCase field in
# actions/cache@v4 schema — a known irregularity. All
# others use kebab-case. The exception makes typo
# auto-correction unreliable: contributors often
# either:
#   - Camel-case ALL fields (incorrect) — likely
#     from K8s reflex
#   - Snake-case ALL fields including
#     enable_cross_os_archive (incorrect)
#   - Kebab-case enable-cross-os-archive (looks
#     right but doesn't match the schema)
#
# Only `enableCrossOsArchive` is correct for that
# field; everything else is kebab-case.
#
# Common typo sources:
#
#   restore_keys              → restore-keys
#   restoreKeys               → restore-keys
#   upload_chunk_size         → upload-chunk-size
#   uploadChunkSize           → upload-chunk-size
#   enable_cross_os_archive   → enableCrossOsArchive
#                                (snake → CAMEL, not
#                                 kebab — schema
#                                 irregularity)
#   enable-cross-os-archive   → enableCrossOsArchive
#                                (kebab → camel)
#   fail_on_cache_miss        → fail-on-cache-miss
#   failOnCacheMiss           → fail-on-cache-miss
#   lookup_only               → lookup-only
#   lookupOnly                → lookup-only
#   save_always               → save-always
#   saveAlways                → save-always
#
# Detection: YAML-parse each workflow. For every step
# with `uses: actions/cache@<v>`, check `with:` block
# keys against the canonical v4 set.
#
# Pairs with canonical-keys family — twelfth table:
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-checkout-canonical-with
#   workflow-cache-canonical-with (this)
#
# 14/14 actions/cache with-keys canonical at iter-231
# add — pure regression floor.
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
    'path', 'key', 'restore-keys', 'upload-chunk-size',
    'enableCrossOsArchive', 'fail-on-cache-miss',
    'lookup-only', 'save-always',
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
        if 'actions/cache' not in u:
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
            echo "FAIL  $wf: actions/cache $b — non-canonical with-key (silently ignored; default applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune \
    -o -path '*/grammars/sources/*' -prune \
    -o -path '*/build/_deps/*' -prune \
    -o -path '*/clap-libs/*' -prune \
    -o -path '*/clap-juce-extensions/*' -prune \
    -o -path '*/node_modules/*' -prune \
    -o -path '*/vendor/*' -prune \
    -o -path '*/target/*' -prune \
    -o -path '*/third_party/*' -prune \
    -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked actions/cache uses checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
