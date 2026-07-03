#!/usr/bin/env bash
# For every workflow yml `if:` expression (workflow,
# job, or step level), pin that:
#
#   - Parentheses `(` and `)` are balanced
#   - `${{` and `}}` interpolation markers are balanced
#
# A workflow with an unbalanced `if:`:
#
#   if: ${{ (github.event_name == 'push' && (
#         github.ref == 'refs/heads/main' )) }}
#         ^                                ^
#         3 opens                          2 closes
#
# OR:
#
#   if: ${{ github.event_name == 'push'
#         (missing }})
#
# GitHub Actions parses if-expressions with a strict
# tokenizer. Unbalanced parens/interpolation cause:
#
#   Error: Invalid format expected ')' got eof at
#   path: ROOT.jobs.build.if
#
# The error is upload-time validation; the workflow
# is rejected before the first run. But:
#
#   - GitHub's error message format pinpoints column
#     position INSIDE the expression, which is fine
#     for short ifs but useless for long
#     multi-clause expressions
#
#   - The error fires AFTER push; PR check status
#     shows the workflow file as invalid (red X
#     without a clear cause)
#
#   - Debugging requires manually counting opens/
#     closes — error-prone for long expressions
#
# This gate catches it at PR time before push.
#
# Common unbalanced-syntax sources:
#
#   - Refactor: removed a clause but forgot the
#     trailing `)` it was wrapped in
#
#   - Editor: line-wrap broke the expression across
#     lines visually, contributor lost track of
#     nesting
#
#   - Copy-paste: pasted a `${{ ... }}` block but
#     trimmed off the trailing `}}` because the line
#     end was hidden
#
#   - Conditional rewrite: added `&& (foo)` but
#     missed wrapping the original LHS in a `(`
#     paired closer
#
# False positives this gate avoids:
#
#   - `(` or `)` in STRING LITERALS inside the
#     expression: e.g.,
#     `if: github.event.commits[0].message ==
#      'release (1.2.3)'`
#     Counting parens raw would flag this. Solution:
#     this gate counts only parens OUTSIDE single/
#     double-quoted strings.
#
#   - `${{` or `}}` in string literals: e.g.,
#     `if: contains(github.event.head_commit.message,
#      '${{')` — same logic applies.
#
# Detection: YAML-parse each workflow. For every
# if: string expression (any level), tokenize to
# count parens outside quotes, and count `${{`/`}}`
# outside quotes. Each pair must balance.
#
# Pairs with workflow correctness family:
#   workflow-no-constant-if   — no constant true/
#                                false conditions
#   workflow-if-balanced-syntax (this) — syntactic
#                                         validity
#
# 0/90 workflows have unbalanced if at iter-240 add
# — pure regression floor.
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

def count_outside_quotes(s, chars_open, chars_close):
    """Count opens/closes outside single/double quotes."""
    i = 0
    in_single = False
    in_double = False
    opens = 0
    closes = 0
    while i < len(s):
        c = s[i]
        if in_single:
            if c == "'": in_single = False
        elif in_double:
            if c == '"': in_double = False
        else:
            if c == "'": in_single = True
            elif c == '"': in_double = True
            else:
                if s[i:i+len(chars_open)] == chars_open:
                    opens += 1; i += len(chars_open); continue
                if s[i:i+len(chars_close)] == chars_close:
                    closes += 1; i += len(chars_close); continue
        i += 1
    return opens, closes

total = 0
bad = []

def visit(node, path):
    if isinstance(node, dict):
        for k, v in node.items():
            if k == 'if' and isinstance(v, str):
                # Count parens outside quotes
                p_open, p_close = count_outside_quotes(v, '(', ')')
                # Count interpolation outside quotes
                i_open, i_close = count_outside_quotes(v, '${{', '}}')
                if p_open != p_close:
                    bad.append(f'{path}:parens({p_open}/{p_close})')
                if i_open != i_close:
                    bad.append(f'{path}:interp({i_open}/{i_close})')
            visit(v, f'{path}/{k}')
    elif isinstance(node, list):
        for i, x in enumerate(node):
            visit(x, f'{path}[{i}]')

# Count and check all if expressions in jobs
def walk_count(node):
    nonlocal_total = 0
    if isinstance(node, dict):
        if isinstance(node.get('if'), str):
            nonlocal_total += 1
        for v in node.values():
            nonlocal_total += walk_count(v)
    elif isinstance(node, list):
        for v in node:
            nonlocal_total += walk_count(v)
    return nonlocal_total

total = walk_count(d.get('jobs', {}))
visit(d.get('jobs', {}), 'jobs')
print(f"{total}|{';'.join(bad)}")
PY
)
    n="${result%%|*}"
    bads="${result#*|}"
    checked=$((checked + n))
    if [[ -n "$bads" ]]; then
        IFS=';' read -ra ba <<< "$bads"
        for b in "${ba[@]}"; do
            echo "FAIL  $wf: if-expression $b — unbalanced (workflow upload will be rejected)"
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
echo "Summary: $checked if-expressions checked, $bad with unbalanced syntax"

[[ $ok -eq 1 ]] && exit 0 || exit 1
