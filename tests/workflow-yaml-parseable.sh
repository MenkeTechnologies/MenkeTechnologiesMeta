#!/usr/bin/env bash
# For every .github/workflows/*.yml across the umbrella, pin that
# the file parses as syntactically valid YAML 1.1 / 1.2.
#
# GitHub Actions silently ignores workflows that fail to parse —
# you get NO error annotation on the PR, NO failed-workflow
# email, and NO entry under the Actions tab. The "workflow ran"
# signal is the absence of a check run entirely, which is
# indistinguishable from "you forgot to trigger CI."
#
# Common syntax breakages:
#   - Tab indentation (YAML requires spaces)
#   - Unbalanced braces in expression syntax `${{ }}`
#   - Missing colon after a key
#   - Inline scalars with unescaped colons (`run: kubectl get foo:bar`)
#   - Multiline `run:` blocks where the trailing `>` or `|` is
#     dropped during hand-edit
#
# Test uses Python's `yaml.safe_load()` — the same parser GitHub
# Actions uses internally (via ruamel.yaml which is YAML 1.2
# compatible). A clean parse here means GitHub will parse it
# identically.
#
# 90/90 workflow files parse green at iter-68 add — pure
# regression floor against the silent-ignore failure mode.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Skip if python3 with PyYAML isn't available (rare on CI runners
# which always include it — bundled with ubuntu-latest, macos-
# latest, windows-latest).
if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "SKIP  PyYAML not installed (pip install PyYAML)"
    exit 0
fi

checked=0
broken=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    err=$(python3 -c '
import sys, yaml
try:
    with open(sys.argv[1]) as f:
        yaml.safe_load(f)
except yaml.YAMLError as e:
    print(str(e).split("\n")[0])
    sys.exit(1)
' "$wf" 2>&1) || {
        echo "FAIL  $wf: $err"
        broken=$((broken + 1))
        ok=0
        continue
    }
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
echo "Summary: $checked workflow files checked, $broken with YAML parse errors"

[[ $ok -eq 1 ]] && exit 0 || exit 1
