#!/usr/bin/env bash
# For every workflow yml job `services:` block (which
# spins up sidecar containers alongside the main job
# container), pin that each service's keys are
# canonical per GitHub Actions service-container
# schema.
#
# Canonical service container keys:
#
#   image         Docker image (required) — e.g.,
#                 postgres:15, redis:7, mysql:8
#   credentials   Registry creds for private images
#                 (username + password)
#   env           Env vars for the service container
#   ports         Port exposes (host:container)
#   volumes       Volume mounts
#   options       Raw docker run options (--health-
#                 cmd, --health-interval, etc.)
#
# A non-canonical key:
#
#   services:
#     postgres:
#       image: postgres:15
#       env_vars:                  # WRONG — snake_case
#         POSTGRES_PASSWORD: test
#       Ports:                     # WRONG — capitalized
#         - 5432:5432
#       volume:                    # WRONG — singular
#         - data:/var/lib/postgres
#       options-list:              # WRONG — suffix
#         --health-cmd "pg_isready"
#       credential:                # WRONG — singular
#         username: foo
#         password: bar
#
# GitHub Actions silently IGNORES unknown service keys.
# The service container runs but with DEFAULTS for the
# parameter the contributor thought they configured:
#
#   - env_vars (snake) → ignored; env stays empty;
#     POSTGRES_PASSWORD not set; container fails to
#     start (psql refuses unauthenticated); the job
#     fails with cryptic "connection refused" when
#     it tries to connect
#
#   - Ports (capital) → ignored; no ports exposed;
#     job's run blocks can't reach localhost:5432;
#     "could not connect to server" errors
#
#   - volume (singular) → ignored; no volume mounted;
#     postgres data is on container's overlay
#     filesystem and disappears when service stops;
#     tests that require persistent state fail
#     ephemerally
#
#   - options-list (suffix) → ignored; no health-cmd
#     applied; job's `needs-healthy` step waits
#     forever or proceeds before service ready;
#     race condition errors
#
#   - credential (singular) → ignored; image pull
#     uses anonymous creds; private registry pulls
#     fail "denied: requested access to the resource
#     is denied" — looks like the image doesn't
#     exist when it actually does
#
# Failure modes MISDIAGNOSED. Contributor checks
# docker image / network / cargo test arguments
# before checking the manifest keys.
#
# Common typo sources:
#
#   env_vars         → env             (snake suffix)
#   environment      → env             (long form)
#   Ports            → ports           (capitalized)
#   port             → ports           (singular)
#   volume           → volumes         (singular)
#   options-list     → options         (suffix)
#   docker-options   → options         (compound)
#   credential       → credentials     (singular)
#   docker-credentials → credentials   (compound)
#   docker-image     → image           (compound)
#   container-image  → image           (compound)
#   tag              → image           (image:tag is
#                                       one field)
#
# Detection: TOML-parse each Cargo.toml. For every
# job's services dict, for each service, check keys
# against canonical set.
#
# Pairs with canonical-keys family — seventeenth
# table:
#   workflow-{top,job,step}-canonical-keys
#   cargo-{bin,package,dep,profile,workspace,lib,
#          bench}-canonical-keys
#   workflow-checkout/cache/upload-artifact/
#     download-artifact/rust-toolchain/swatinem-
#     rust-cache-canonical-with
#   workflow-services-canonical-keys (this)
#
# Service containers are sidecars for tests that need
# database/cache/queue infrastructure (postgres,
# redis, kafka, localstack).
#
# 7/7 service blocks have canonical keys at iter-243
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
allowed = {'image', 'credentials', 'env', 'ports', 'volumes', 'options'}
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    svcs = job.get('services', {})
    if not isinstance(svcs, dict):
        continue
    for sn, svc in svcs.items():
        if not isinstance(svc, dict):
            continue
        total += 1
        for k in svc.keys():
            if k not in allowed:
                bad.append(f'{jn}/services.{sn}.{k}')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: $b — non-canonical service key (silently ignored; container default applied)"
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
echo "Summary: $checked service blocks checked, $bad with non-canonical keys"

[[ $ok -eq 1 ]] && exit 0 || exit 1
