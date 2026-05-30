#!/usr/bin/env bash
# Meta self-audit extension: every tests/*.sh audit gate file
# must use kebab-case naming:
#
#   ^[a-z][a-z0-9-]*$
#
# Lowercase letters, digits, and hyphens only. First char must
# be a lowercase letter.
#
# Why kebab-case for gate filenames:
#
#   - SHELL-FRIENDLY: bash globs and tab-completion work
#     identically on kebab-case across all shells. Mixed
#     case files can hit case-insensitive filesystems
#     (default macOS HFS+, NTFS) differently than case-
#     sensitive (Linux ext4, APFS-case-sensitive).
#   - URL-SAFE: gate filenames appear in CI URLs, gist
#     references, and PR comments. Hyphens are URL-safe;
#     underscores require encoding in some legacy systems.
#   - REGEX-FRIENDLY: when meta-self-audit gates use
#     `for f in tests/*.sh` and then derive
#     `$(basename "$f" .sh)`, the result feeds into shell
#     associative-array keys, awk conditions, etc. without
#     escape concerns.
#   - SEARCHABILITY: `grep -r "cargo-deps-have-version"`
#     in commit history finds every reference unambiguously.
#     `grep -r "CargoDepsHaveVersion"` would miss the
#     filename-cased variant.
#
# Self-exempt because this gate file itself satisfies the
# rule (meta-gate-filename-kebab.sh matches kebab-case).
#
# 150/150 audit gates green at iter-158 add — pure regression
# floor.
#
# The meta self-audit catalog now spans SEVEN gates:
#
#   iter-65:  SHAPE       — shebang, pipefail, exec bit, root pattern
#   iter-99:  WIRING      — every gate invoked from ci.yml
#   iter-100: PORTABILITY — python3 skip fallback
#   iter-101: SCOPE       — find . excludes .git/
#   iter-102: OUTPUT      — Summary line in every post-bootstrap gate
#   iter-133: EXIT CODES  — every gate uses exit 0 / 1
#   iter-158: NAMING      — every gate uses kebab-case filename
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
bad=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))
    base=$(basename "$f" .sh)
    if echo "$base" | grep -qE '^[a-z][a-z0-9-]*$'; then
        : # silent pass
    else
        echo "FAIL  $f: \"$base\" not kebab-case (^[a-z][a-z0-9-]*\$)"
        bad=$((bad + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked audit gates checked, $bad with non-kebab-case filenames"

[[ $ok -eq 1 ]] && exit 0 || exit 1
