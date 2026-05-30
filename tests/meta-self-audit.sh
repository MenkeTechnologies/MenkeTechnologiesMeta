#!/usr/bin/env bash
# Meta self-audit: every shell script under tests/ must satisfy
# the same hygiene baseline the audit gates enforce on submodules.
#
# Three rules pinned:
#
#   1. Shebang line: `#!/usr/bin/env bash` or `#!/bin/bash`.
#      Without it, a script invoked directly as `./tests/foo.sh`
#      gets dispatched by the user's login shell — which may be
#      zsh (the user's daily) or even fish on contributor boxes.
#      Most tests use bashisms (`[[ ]]`, `local`, array indexing)
#      that fail under POSIX sh or non-bash shells.
#
#   2. `set -uo pipefail` somewhere in the first 60 lines.
#      Without `-u`, unset vars silently expand to empty (turning
#      `[[ "$undeclared" == "foo" ]]` into `[[ "" == "foo" ]]` and
#      passing). Without `pipefail`, a failure in any pipeline
#      stage other than the last is masked — and our audit gates
#      lean heavily on pipelines (`grep | sed | awk`).
#
#   3. Executable bit (chmod +x). Without it, `bash tests/foo.sh`
#      still works (CI wires the explicit `bash` invocation), but
#      `./tests/foo.sh` doesn't — and the file gets a misleading
#      file-type icon in IDEs that warn "this looks like a script
#      but isn't marked runnable."
#
# This gate IS an audit-tool — but it's the unique kind of audit
# tool whose ONLY behavior is to make every other audit tool more
# trustworthy. Violations here invalidate every other gate's
# output (a script without `set -u` could be silently passing on
# typo'd variables). The CLAUDE.md "audit-tool tampering" rule
# applies recursively: this script must itself satisfy the same
# rules it enforces.
#
# 60/60 audit gates green at iter-65 add — pure regression floor.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

checked=0
no_shebang=0
no_pipefail=0
no_execbit=0

for f in tests/*.sh; do
    [[ -f "$f" ]] || continue
    checked=$((checked + 1))
    local_ok=1

    # 1. Shebang on line 1.
    if ! head -1 "$f" | grep -qE '^#!/usr/bin/env bash$|^#!/(usr/)?bin/bash'; then
        first=$(head -1 "$f")
        echo "FAIL  $f: no bash shebang on line 1 (got: $first)"
        no_shebang=$((no_shebang + 1))
        local_ok=0
        ok=0
    fi

    # 2. `set -uo pipefail` (or any pipefail-bearing set) somewhere
    #    in the first 60 lines.
    if ! head -60 "$f" | grep -qE '^set .*pipefail'; then
        echo "FAIL  $f: no \`set ... pipefail\` directive in first 60 lines"
        no_pipefail=$((no_pipefail + 1))
        local_ok=0
        ok=0
    fi

    # 3. Executable bit.
    if [[ ! -x "$f" ]]; then
        echo "FAIL  $f: missing executable bit (chmod +x)"
        no_execbit=$((no_execbit + 1))
        local_ok=0
        ok=0
    fi

    [[ $local_ok -eq 1 ]] && echo "PASS  $f"
done

echo "---"
echo "Summary: $checked tests/*.sh checked"
echo "  $no_shebang missing shebang"
echo "  $no_pipefail missing \`set ... pipefail\`"
echo "  $no_execbit missing executable bit"

[[ $ok -eq 1 ]] && exit 0 || exit 1
