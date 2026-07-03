#!/usr/bin/env bash
# For every workflow `name:` field value (top-level workflow
# name, job name, OR step name), pin that an UNQUOTED value
# does not contain ": " (colon followed by space).
#
# This is the trap that bit iter-83. The commit added a step
# named:
#
#   - name: Every workflow step has run: or uses:
#
# YAML treats the FIRST `: ` as the key/value separator, so the
# parser saw the key as `name` and the value as `Every workflow
# step has run`. Then `: or uses:` parses as a NESTED mapping
# where `or uses` is a key — but indentation doesn't match the
# step's structure, so the parser bails with:
#
#   mapping values are not allowed here
#
# at the line containing the offending name. Workflow vanishes
# from Actions tab (silent-no-op as documented in iter-68).
#
# The fix is trivial — wrap the value in quotes:
#
#   - name: "Every workflow step has run: or uses:"
#
# Quoted values can contain any characters; YAML treats the
# scalar as the literal string between the quotes.
#
# Iter-68 (workflow-yaml-parseable.sh) already catches this
# bug as a YAML parse failure. Iter-105 catches it ONE LEVEL
# EARLIER — at the source-text scan, with a specific
# explanatory error message that points at the colon-space
# pattern. Iter-68's error is generic ("mapping values are
# not allowed here"); iter-105's error names the exact fix
# ("wrap the value in quotes").
#
# Detection: parse each `- name: <value>` and `name: <value>`
# line, skip if the value begins with `"` or `'` (already
# quoted), check for `: ` substring in the value.
#
# Acceptable patterns (no `: ` in value):
#   name: Build and test
#   name: Run cargo build
#   name: "Step containing: colon"   ← quoted, exempt
#
# Risky patterns (colon-space in unquoted value):
#   name: Build: test                ← would FAIL parse
#   name: Run: cargo build           ← would FAIL parse
#
# 90/90 workflow files green at iter-105 add — pure regression
# floor against the iter-83 trap.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked_files=0
total_names=0
risky=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked_files=$((checked_files + 1))

    while IFS= read -r ln_num_text; do
        ln_num="${ln_num_text%%:*}"
        line="${ln_num_text#*:}"

        # Extract the value after `name:` (with or without dash prefix).
        val=$(echo "$line" | sed -E 's/^[[:space:]]*- name:[[:space:]]*//; s/^[[:space:]]*name:[[:space:]]*//')

        # Skip already-quoted values.
        case "$val" in
            \"*|\'*) continue ;;
        esac

        total_names=$((total_names + 1))

        if echo "$val" | grep -qE ': '; then
            echo "FAIL  $wf:$ln_num: unquoted name value contains \`: \` — YAML will parse as nested mapping, workflow vanishes. Fix: wrap in double quotes. Line: $line"
            risky=$((risky + 1))
            ok=0
        fi
    done < <(grep -nE '^[[:space:]]*(- )?name:' "$wf")
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
echo "Summary: $checked_files workflow files, $total_names unquoted name fields checked, $risky containing risky \`: \` pattern"

[[ $ok -eq 1 ]] && exit 0 || exit 1
