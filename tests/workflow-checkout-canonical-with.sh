#!/usr/bin/env bash
# For every workflow yml step using `actions/checkout`,
# pin that the `with:` block uses only canonical
# parameter keys per actions/checkout@v4+ schema.
#
# Canonical actions/checkout v4 with-block keys:
#
#   repository                Repo to check out
#                             (default: github.repository)
#   ref                       Branch/tag/SHA to check out
#   token                     PAT or GITHUB_TOKEN
#   ssh-key                   SSH private key
#   ssh-known-hosts           Known-hosts content
#   ssh-strict                StrictHostKeyChecking
#   ssh-user                  SSH login user
#   persist-credentials       Keep token in .git/config
#   path                      Subdir to clone into
#   clean                     Run git clean
#   filter                    Partial-clone filter
#   sparse-checkout           Sparse paths
#   sparse-checkout-cone-mode Sparse-checkout cone mode
#   fetch-depth               Clone depth (0 = full)
#   fetch-tags                Fetch all tags
#   show-progress             Show clone progress
#   lfs                       Fetch Git LFS objects
#   submodules                false/true/recursive
#   set-safe-directory        Add safe.directory config
#   github-server-url         GitHub Enterprise URL
#
# A non-canonical key in actions/checkout `with:`:
#
#   - uses: actions/checkout@v4
#     with:
#       fetch_depth: 0              # WRONG — snake_case
#       persist_credentials: false  # WRONG — snake_case
#       submodule: recursive        # WRONG — singular
#       sub-modules: true           # WRONG — wrong hyphen
#       lfs_fetch: true             # WRONG — invented
#
# GitHub Actions silently IGNORES unknown with-keys.
# The action runs with DEFAULTS for the parameter the
# contributor thought they configured:
#
#   - fetch_depth (snake) → ignored; fetch-depth
#     stays at default 1 (shallow); workflows that
#     use `git log --all` find no commit history;
#     git describe fails; deploy scripts blame "git
#     state corrupted"
#
#   - persist_credentials (snake) → ignored;
#     persist-credentials stays at default TRUE; the
#     token is left in .git/config; any subsequent
#     `git push` from another step uses it without
#     explicit token passing; security exposure
#     window the contributor THOUGHT they closed
#     stays open
#
#   - submodule (singular) → ignored; submodules
#     stays at default false; the submodules the
#     workflow needs aren't cloned; build fails
#     "no such file or directory" inside submodule
#     paths; debugging time wasted searching for
#     missing files
#
#   - sub-modules (extra hyphen) → ignored; same as
#     above; the typo is visually so close that
#     reviewers miss it
#
#   - lfs_fetch (invented) → ignored; lfs stays
#     false; large files come down as pointer text
#     instead of binaries; build fails "invalid file
#     format" on the LFS file
#
# All failure modes are MISDIAGNOSED. Contributor
# searches the build / Git config / submodule
# config for the bug instead of the manifest.
#
# Common typo sources:
#
#   fetch_depth          → fetch-depth          (snake)
#   fetchDepth           → fetch-depth          (camel)
#   fetch-depth-limit    → fetch-depth          (suffix)
#   persist_credentials  → persist-credentials  (snake)
#   persistCredentials   → persist-credentials  (camel)
#   submodule            → submodules           (singular)
#   sub-modules          → submodules           (extra
#                                                 hyphen)
#   set_safe_directory   → set-safe-directory   (snake)
#   ssh_key              → ssh-key              (snake)
#   sparse_checkout      → sparse-checkout      (snake)
#   lfs_fetch            → lfs                  (suffix)
#   token_secret         → token                (suffix)
#
# Snake-case is the most common typo because git
# configuration uses snake_case AND camelCase
# conventions (git config user.name vs core.bare).
# Contributors typing checkout config drift toward
# git's conventions.
#
# Detection: YAML-parse each workflow. For every
# step with `uses: actions/checkout@<v>`, check
# `with:` block keys against the canonical v4 set.
#
# Pairs with canonical-keys family (action-level
# extension; previously workflow root/job/step):
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-checkout-canonical-with (this) — most-
#     used action's parameter keys
#
# Eleventh table in the canonical-keys family.
#
# 274/274 actions/checkout with-keys canonical at
# iter-230 add — pure regression floor.
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
    'repository', 'ref', 'token', 'ssh-key',
    'ssh-known-hosts', 'ssh-strict', 'ssh-user',
    'persist-credentials', 'path', 'clean', 'filter',
    'sparse-checkout', 'sparse-checkout-cone-mode',
    'fetch-depth', 'fetch-tags', 'show-progress',
    'lfs', 'submodules', 'set-safe-directory',
    'github-server-url',
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
        if 'actions/checkout' not in u:
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
            echo "FAIL  $wf: actions/checkout $b — non-canonical with-key (silently ignored; default applied instead of intended config)"
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
echo "Summary: $checked actions/checkout uses checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
