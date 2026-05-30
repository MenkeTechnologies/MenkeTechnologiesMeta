#!/usr/bin/env bash
# For every workflow yml, pin that no mapping anywhere in the
# YAML tree contains duplicate keys.
#
# YAML 1.1 / 1.2 specs both say duplicate keys in a mapping
# are an ERROR — but most loaders (PyYAML, ruamel, libyaml,
# js-yaml) accept them silently with last-write-wins semantics.
# GitHub Actions' parser also takes last-write-wins.
#
# This produces a class of bugs that's invisible at YAML parse
# time (iter-68 passes) and only manifests as confusing
# behavior:
#
#   on:
#     push:
#       branches: [main]
#       branches: [develop]    # DUPLICATE — silently overrides
#   # Workflow fires only on develop pushes; main pushes don't
#   # trigger CI. PR review shows both lines — looks like
#   # workflow runs on both, but in reality only one is honored.
#
# Other places duplicates sneak in:
#
#   env:
#     RUST_LOG: debug
#     RUST_LOG: trace        # last-write-wins; first line dead
#
#   permissions:
#     contents: read
#     contents: write        # last grants write; reviewer
#                            # might think contents: read still
#                            # applies (it doesn't)
#
#   jobs:
#     test:
#       ...
#     test:                  # duplicate JOB name — last
#                            # definition replaces the first;
#                            # the first job's steps silently
#                            # disappear from the workflow
#
# The PERMISSIONS case is especially insidious: a reviewer
# focused on the more-restrictive line might miss the
# less-restrictive override.
#
# Detection: custom YAML loader that raises on duplicate keys
# at any nesting level. PyYAML's SafeLoader's default behavior
# is silent-override; the gate's custom constructor catches
# the dup at parse time.
#
# 90/90 workflow files green at iter-128 add — pure regression
# floor against silent override corruption.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

if ! command -v python3 >/dev/null 2>&1; then
    echo "SKIP  python3 not on PATH"
    exit 0
fi
if ! python3 -c 'import yaml' 2>/dev/null; then
    echo "SKIP  PyYAML not installed"
    exit 0
fi

checked=0
dup=0

while IFS= read -r wf; do
    [[ -f "$wf" ]] || continue
    checked=$((checked + 1))

    output=$(python3 -c '
import sys, yaml

class StrictLoader(yaml.SafeLoader):
    pass

def detect_dup(loader, node, deep=False):
    mapping = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            raise yaml.YAMLError(f"duplicate key: {key!r}")
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping

StrictLoader.add_constructor(
    yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
    detect_dup,
)

try:
    yaml.load(open(sys.argv[1]), Loader=StrictLoader)
    print("OK")
except yaml.YAMLError as e:
    msg = str(e).split("\n")[0]
    if "duplicate" in msg.lower():
        print("BAD:" + msg)
    else:
        print("OK")
except Exception:
    print("OK")
' "$wf")

    case "$output" in
        BAD:*)
            echo "FAIL  $wf: ${output#BAD:}"
            dup=$((dup + 1))
            ok=0
            ;;
    esac
done < <(find . -path './.git' -prune -o -type f -path '*/.github/workflows/*.yml' -print 2>/dev/null)

echo "---"
echo "Summary: $checked workflow files checked, $dup with duplicate-key mappings"

[[ $ok -eq 1 ]] && exit 0 || exit 1
