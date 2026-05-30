#!/usr/bin/env bash
# Meta-meta gate: run shellcheck against tests/*.sh so the audit
# scripts themselves don't drift. Every other test in this directory
# validates one slice of the 64-repo umbrella; this one validates the
# auditors.
#
# Iteration 32 (when this script was first written) cleaned up:
#   - 28× SC2164 (cd without || exit) — bulk-added the guard
#   - 3× SC2206 (array split without quote) — intentional in version_gt
#     splitting where IFS=. is set; shellcheck-disabled inline
#   - 2× SC2155 (declare + assign masks return) — refactored or disabled
#
# Severity level: enforce "error" only. Warning/info findings are
# surfaced but don't fail CI — the cleanup work that achieves a fully-
# clean shellcheck pass would create excessive PR noise without
# proportional bug-catching value at this point.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "SKIP  shellcheck not installed (install via \`brew install shellcheck\` / \`apt-get install shellcheck\`)"
    exit 0
fi

count=$(find tests -maxdepth 1 -name '*.sh' -type f | wc -l | tr -d ' ')
echo "Scanning $count tests/*.sh files with shellcheck (severity: error)..."

# Run shellcheck with severity filter — only error-level findings fail.
if shellcheck --severity=error tests/*.sh; then
    echo "PASS  no error-level shellcheck findings across $count test scripts"
else
    echo "FAIL  shellcheck found error-level issues above"
    ok=0
fi

# Informational: report warning/info counts without failing.
warn_count=$(shellcheck --severity=warning tests/*.sh 2>&1 | grep -c "^In tests/" || true)
info_count=$(shellcheck --severity=info tests/*.sh 2>&1 | grep -c "^In tests/" || true)
echo "Informational: $warn_count warning-level findings, $info_count info-level findings (not failing CI)"

[[ $ok -eq 1 ]] && exit 0 || exit 1
