#!/usr/bin/env bash
# For every workflow yml, pin that no `permissions:` block
# requests `id-token: write`.
#
# `id-token: write` grants the workflow the ability to issue
# OIDC (OpenID Connect) tokens via the GitHub Actions JWT
# endpoint. These tokens can then be exchanged with cloud
# providers for credentials WITHOUT any long-lived secret
# being stored in the repo:
#
#   - AWS: STS AssumeRoleWithWebIdentity → temporary AWS
#     credentials
#   - GCP: Workload Identity Federation → temporary GCP
#     credentials
#   - Azure: federated credentials → temporary Azure tokens
#   - crates.io: trusted publishing (March 2024+)
#   - PyPI: trusted publishing
#
# The mechanism is excellent when you need it; the permission
# is a privilege-escalation footgun when set unintentionally.
# Any step in a workflow with id-token: write can mint an
# OIDC token and exchange it for cloud creds — including via
# untrusted user-controlled steps (PR steps, fork-controlled
# actions called via `uses:`).
#
# Default-safe org policy: NO workflow requests id-token:write
# unless it's actively using OIDC federation. When OIDC is
# added (e.g., for crates.io trusted publishing replacing
# CRATES_IO_TOKEN), this gate must be updated with an explicit
# allowlist of the workflow(s) that need it, with a comment
# documenting:
#   - Which cloud/registry the OIDC trust is configured for
#   - The trust policy reference (e.g., AWS IAM role ARN,
#     crates.io trust ID)
#   - Why this workflow legitimately needs OIDC
#
# Hardcoded-token alternatives (PATs, CRATES_IO_TOKEN stored
# as secrets) are explicitly preferred over silent
# id-token:write expansions; the explicit-allowlist process
# ensures every OIDC trust is reviewed.
#
# 90/90 workflow files green at iter-116 add — pure
# regression floor against accidental privilege escalation.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Allowlist of workflows that legitimately need id-token:write.
# When OIDC trust is configured, add the workflow file here
# (relative path from meta repo root) and document the trust
# in a comment.
declare -A OIDC_ALLOWLIST=(
    # Example entry:
    # [./foo-repo/.github/workflows/publish.yml]="crates.io trusted publishing (trust ID: foo-publisher)"
    #
    # GitHub Pages deploy: actions/deploy-pages mints an OIDC token to
    # authenticate the deployment to the github-pages environment (first-party
    # GitHub action, no cloud-cred exchange). Lets us serve the static docs/
    # dir from main without the legacy builder's recursive private-submodule
    # clone (which aborts on Audio-Haxor/traderview/zpwr/fusevm/app-store).
    [./.github/workflows/pages.yml]="GitHub Pages deploy via actions/deploy-pages OIDC (first-party; deploys docs/ from main)"
)

checked=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    if grep -qE '\bid-token:[[:space:]]*write\b' "$wf" 2>/dev/null; then
        if [[ -n "${OIDC_ALLOWLIST[$wf]:-}" ]]; then
            echo "PASS  $wf: id-token:write allowlisted (${OIDC_ALLOWLIST[$wf]})"
            continue
        fi
        line=$(grep -nE '\bid-token:[[:space:]]*write\b' "$wf" | head -1)
        echo "FAIL  $wf: id-token:write without OIDC allowlist entry — privilege-escalation footgun. Add to OIDC_ALLOWLIST with trust documentation if intentional. Line: $line"
        risky=$((risky + 1))
        ok=0
    fi
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $risky un-allowlisted id-token:write declarations"

[[ $ok -eq 1 ]] && exit 0 || exit 1
