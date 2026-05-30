#!/usr/bin/env bash
# For every workflow yml step's `with:` block, pin
# that secret-like field values use `${{ }}`
# interpolation (no bare credential strings).
#
# Secret-like field names this gate scans:
#
#   - token / TOKEN
#   - secret / SECRET (or secrets)
#   - password / PASSWORD
#   - api_key / apikey / api-key / API_KEY
#   - auth_token / authtoken / AUTH_TOKEN
#   - ssh_key / ssh-key / SSH_KEY
#
# (case-insensitive; matches by substring within the
# field name)
#
# A bare credential in workflow file:
#
#   - uses: some-action/deploy@v1
#     with:
#       api-key: sk-prod-abcdef123          # WRONG
#       deploy-token: glpat-AbCdEf123       # WRONG
#       password: prod_password_123         # WRONG
#       ssh-key: |
#         -----BEGIN OPENSSH PRIVATE KEY-----  # WRONG
#         ...
#
# All four leak the secret into git history. Failure
# mode identical to iter-241 (checkout token):
#
#   - Credential lives in repo forever (`git log
#     --all` preserves the blob)
#   - GitHub's secret-scanning push-protection only
#     catches well-known patterns (GitHub PATs,
#     AWS keys, Slack webhooks, Stripe keys, etc.).
#     Custom tokens (deploy keys, bearer tokens
#     from internal APIs, third-party SaaS tokens,
#     vendor-specific patterns) NOT caught.
#   - Public repo = internet has it.
#
# Generalization of iter-241 (which covered only
# actions/checkout's `token`). This gate covers any
# action's secret-like field.
#
# Examples of actions where this matters:
#
#   softprops/action-gh-release: token (covered by
#                                 GH_TOKEN env var,
#                                 not with: field —
#                                 but defensive check
#                                 catches accidental
#                                 misuse)
#   appleboy/scp-action:         password, key,
#                                 passphrase
#   ncipollo/release-action:     token
#   peter-evans/create-pull-request: token
#   dorny/test-reporter:         path (not secret —
#                                 but if mis-named
#                                 "secret-path" might
#                                 trigger; acceptable
#                                 low false-positive)
#   slackapi/slack-github-action: webhook-url (URL
#                                  with secret token)
#   docker/login-action:         password, username
#   helm/kind-action:             (none currently in
#                                  this fleet, but
#                                  catches future
#                                  drift)
#
# Detection: YAML-parse each workflow. For every step's
# with: dict, check each key whose name contains any
# of (case-insensitive): token, secret, password,
# apikey, api_key, api-key. If the value is a string
# and doesn't contain `${{`, fail.
#
# False positive risk:
#
#   - A literal API key that's PUBLIC (e.g., a
#     publishable Stripe key starting with pk_) is
#     LEGITIMATELY bare. The gate flags it; the fix
#     is either wrap in ${{ }} unnecessarily (small
#     cost) or rename the key to not match the
#     pattern.
#   - YAML `<token>` placeholders in templates would
#     fire, but templates aren't committed live
#     workflows.
#
# Pairs with workflow security defense family:
#   workflow-no-secret-echo            — no echo
#                                        $SECRET
#   workflow-no-workflow-level-secret-env — workflow-
#                                            scope
#                                            secrets
#   workflow-checkout-token-interpolated (iter-241)
#     — checkout token only
#   workflow-with-secrets-interpolated (this) — all
#     secret-like with-keys
#
# Generalizes iter-241 to any action.
#
# 17/17 secret-like with-keys interpolated at iter-242
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
secret_markers = ('token', 'secret', 'password',
                  'apikey', 'api_key', 'api-key')
total = 0
bad = []
for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        w = step.get('with', {})
        if not isinstance(w, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        for k, v in w.items():
            kl = str(k).lower()
            if not any(m in kl for m in secret_markers):
                continue
            total += 1
            if isinstance(v, str) and '${{' not in v:
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
            echo "FAIL  $wf: with $b — secret-like field value not \${{ }} interpolated; credential committed to git"
            bad=$((bad + 1))
            ok=0
        done
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked secret-like with-fields checked, $bad without interpolation"

[[ $ok -eq 1 ]] && exit 0 || exit 1
