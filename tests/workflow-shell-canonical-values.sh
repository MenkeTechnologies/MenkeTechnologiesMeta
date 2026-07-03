#!/usr/bin/env bash
# For every workflow yml step `shell:` value (when set
# in step.shell or defaults.run.shell), pin that the
# value is canonical per GitHub Actions runner support
# matrix.
#
# Canonical shell values:
#
#   bash         Default on Linux + macOS (recommended
#                for cross-platform run blocks)
#   sh           POSIX sh on Linux + macOS
#   python       Python interpreter (system Python on
#                the runner)
#   pwsh         PowerShell Core 6+ (cross-platform;
#                default on Windows)
#   powershell   Windows PowerShell 5.1 (Windows
#                only)
#   cmd          Command Prompt (Windows only)
#
# A non-canonical shell value:
#
#   - run: cargo build
#     shell: Bash               # WRONG — capitalized
#   - run: ./build.sh
#     shell: bash4              # WRONG — version
#                                 suffix invented
#   - run: python script.py
#     shell: python3            # WRONG — should be
#                                 'python'
#   - run: ./build.ps1
#     shell: PowerShell         # WRONG — capitalized
#
# GitHub Actions rejects unknown shell values at step
# execution time with:
#
#   Error: Process completed with exit code 1.
#   /home/runner/work/_temp/<sha>.sh: line 1:
#   Bash: command not found
#
# The error message implies the SHELL doesn't exist —
# leading contributors to debug runner image / PATH
# instead of the manifest. The fix is trivial; the
# diagnosis time can be hours.
#
# Common typo sources:
#
#   Bash             → bash         (capitalization)
#   BASH             → bash         (uppercase)
#   bash4            → bash         (version suffix)
#   bash-5           → bash         (version dash)
#   Sh               → sh           (capitalization)
#   POSIX            → sh           (concept word)
#   python3          → python       (version suffix)
#   python2          → python       (version suffix;
#                                    python2 is EOL,
#                                    likely a misread
#                                    of intent)
#   PowerShell       → powershell   (capitalization)
#   Pwsh             → pwsh         (capitalization)
#   ps1              → pwsh         (file extension
#                                    used as shell)
#   ksh / fish / zsh → bash         (using user's
#                                    preferred shell —
#                                    runner doesn't
#                                    have these by
#                                    default)
#
# Note: GitHub Actions also supports CUSTOM shells via
# `shell: my-shell {0}` template syntax. This gate
# only flags BARE shell names that look like typos.
# If a workflow legitimately uses `shell: bash -e {0}`
# template form, the YAML loader gives a string with
# a space — which is NOT in our canonical set but is
# a legitimate template. To distinguish:
#
#   - Canonical: short single word from the allow set
#   - Template: contains '{0}' or ' ' (space + flag)
#
# The gate accepts both: a value matching the canonical
# set OR a value containing `{0}` template marker.
#
# Detection: YAML-parse each workflow. For step.shell
# and defaults.run.shell, check value against
# canonical set OR template form (contains '{0}').
#
# Pairs with canonical-keys / canonical-values family:
#   workflow-permissions-canonical-values  — value form
#   workflow-shell-canonical-values (this) — value form
#
# 45/45 shell values canonical at iter-237 add — pure
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
canonical = {'bash', 'sh', 'python', 'pwsh', 'powershell', 'cmd'}
total = 0
bad = []

def check_shell(s, where):
    if s is None:
        return 0, []
    if not isinstance(s, str):
        return 1, [f'{where}:non-string({s!r})']
    # Template form: contains {0} or has flag args
    if '{0}' in s or ' ' in s:
        # Template form — accept as legitimate
        return 1, []
    if s in canonical:
        return 1, []
    return 1, [f'{where}:{s!r}']

# defaults.run.shell (workflow level)
df = d.get('defaults', {})
if isinstance(df, dict):
    r = df.get('run', {})
    if isinstance(r, dict):
        n, b = check_shell(r.get('shell'), 'defaults')
        total += n; bad.extend(b)

for jn, job in (d.get('jobs', {}) or {}).items():
    if not isinstance(job, dict):
        continue
    # job.defaults.run.shell
    jdf = job.get('defaults', {})
    if isinstance(jdf, dict):
        jr = jdf.get('run', {})
        if isinstance(jr, dict):
            n, b = check_shell(jr.get('shell'), f'job/{jn}/defaults')
            total += n; bad.extend(b)
    for i, step in enumerate(job.get('steps', []) or []):
        if not isinstance(step, dict):
            continue
        sn = step.get('name', f'step #{i+1}')
        n, b = check_shell(step.get('shell'), f'job/{jn}/{sn}')
        total += n; bad.extend(b)

print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: shell $b — non-canonical value (runner errors 'command not found')"
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
echo "Summary: $checked shell values checked, $bad non-canonical"

[[ $ok -eq 1 ]] && exit 0 || exit 1
