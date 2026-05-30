#!/usr/bin/env bash
# For every workflow yml step using `actions/upload-
# artifact`, pin that the `with:` block uses only
# canonical parameter keys per upload-artifact@v4+
# schema.
#
# Canonical actions/upload-artifact v4 with-keys:
#
#   name                  Artifact name (default
#                         'artifact')
#   path                  Path(s) to upload (required)
#   if-no-files-found     'warn' / 'error' / 'ignore'
#                         (default 'warn')
#   retention-days        Days to keep (1-90, default
#                         from repo settings)
#   compression-level     0-9 zip compression
#                         (default 6)
#   overwrite             Replace existing artifact
#                         with same name (default
#                         false)
#   include-hidden-files  Include dotfiles in upload
#                         (default false)
#
# A non-canonical key in upload-artifact `with:`:
#
#   - uses: actions/upload-artifact@v4
#     with:
#       name: foo
#       path: dist/
#       retention_days: 30           # WRONG — snake
#       if_no_files_found: error     # WRONG — snake
#       compression_level: 9         # WRONG — snake
#       overwrites: true             # WRONG — plural
#       include_hidden_files: true   # WRONG — snake
#
# GitHub Actions silently IGNORES unknown with-keys.
# The action runs with DEFAULTS for the parameter
# the contributor thought they configured:
#
#   - retention_days (snake) → ignored; retention-
#     days stays at repo default (typically 90);
#     artifacts pile up using storage quota; the
#     30-day intent never applied
#
#   - if_no_files_found (snake) → ignored; behavior
#     stays default 'warn'; missing-path doesn't
#     fail; release pipeline uploads NOTHING
#     silently; gh release shows zero binaries;
#     contributor blames release.yml structure
#
#   - compression_level (snake) → ignored;
#     compression stays default 6; large artifacts
#     transfer slower than the intended 9 (max)
#
#   - overwrites (plural) → ignored; overwrite stays
#     default FALSE; re-running a release after a
#     fix fails 409 conflict because the original
#     artifact still exists; user has to manually
#     delete from Actions UI before re-running
#
#   - include_hidden_files (snake) → ignored; .env,
#     .git, .dockerignore etc. stay excluded; the
#     intended config file inclusion doesn't work;
#     workflow's "ship config dotfiles" feature is
#     dead
#
# All failure modes MISDIAGNOSED. Contributor checks
# upload paths, action version, runner image, before
# checking the manifest key spelling.
#
# Common typo sources:
#
#   retention_days        → retention-days        (snake)
#   retentionDays         → retention-days        (camel)
#   if_no_files_found     → if-no-files-found     (snake)
#   ifNoFilesFound        → if-no-files-found     (camel)
#   compression_level     → compression-level     (snake)
#   compressionLevel      → compression-level     (camel)
#   overwrites            → overwrite             (plural)
#   replace               → overwrite             (synonym)
#   include_hidden_files  → include-hidden-files  (snake)
#   includeHiddenFiles    → include-hidden-files  (camel)
#   include_hidden        → include-hidden-files  (truncated)
#   artifact_name         → name                  (suffix)
#   artifact_path         → path                  (suffix)
#
# Detection: YAML-parse each workflow. For every
# step with `uses: actions/upload-artifact@<v>`,
# check `with:` block keys against canonical v4 set.
#
# Pairs with canonical-keys family — thirteenth
# table:
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-checkout-canonical-with
#   workflow-cache-canonical-with
#   workflow-upload-artifact-canonical-with (this)
#
# Second-most-used action (52 uses).
#
# 52/52 upload-artifact with-keys canonical at
# iter-232 add — pure regression floor.
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
    'name', 'path', 'if-no-files-found',
    'retention-days', 'compression-level',
    'overwrite', 'include-hidden-files',
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
        if 'actions/upload-artifact' not in u:
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
            echo "FAIL  $wf: actions/upload-artifact $b — non-canonical with-key (silently ignored; default applied)"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked upload-artifact uses checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
