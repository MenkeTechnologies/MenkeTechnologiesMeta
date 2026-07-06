#!/usr/bin/env bash
# Per the README convention claim (line 82):
#   "The set of MenkeTechnologies projects that share the unified
#    strykelang-authored documentation template (README header, ToC
#    convention [0xNN], docs/index.html chrome, docs/report.html
#    engineering report, man/man1/<name>.1 + <name>all.1 man pages)."
#
# Pin that every Tier 1 Rust BINARY submodule (excludes fusevm which is
# a library, excludes Audio-Haxor/traderview which are GUI apps with
# in-app help instead of man pages, excludes zpwr which uses zpwrhelp
# convention instead) ships:
#   man/man1/<binary>.1       — the standard man page
#   man/man1/<binary>all.1    — the "everything" cheatsheet variant
#
# Catches: a new binary added to Tier 1 that forgets man pages, OR an
# existing binary that loses its man pages between releases. For binaries
# that ship multiple sub-binaries (e.g. powerliners ships 5: powerline,
# powerline-daemon, etc.), at minimum the primary binary name must have
# both files present.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

init_count=0
for p in "${paths[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] && init_count=$((init_count + 1))
done
if [[ $init_count -eq 0 ]]; then
    echo "SKIP  no submodules initialized"
    exit 0
fi

# Tier 1 Rust binaries that DO follow the man-page convention.
# fusevm (lib), Audio-Haxor + traderview (GUI), zpwr (uses zpwrhelp).
# powerliners ships multiple binaries; the primary is `powerline`.
declare -A primary_bin
primary_bin[strykelang]="stryke"
primary_bin[zshrs]="zshrs"
primary_bin[lsofrs]="lsofrs"
primary_bin[temprs]="temprs"
primary_bin[awkrs]="awkrs"
primary_bin[iftoprs]="iftoprs"
primary_bin[nmaprs]="nmaprs"
primary_bin[powerliners]="powerline"
primary_bin[storageshower]="storageshower"
primary_bin[ztmux]="ztmux"
primary_bin[htoprs]="htoprs"
primary_bin[zemacs]="zemacs"

checked=0
missing=0

for p in "${!primary_bin[@]}"; do
    [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]] || continue
    bin="${primary_bin[$p]}"
    checked=$((checked + 1))
    main_man="$p/man/man1/${bin}.1"
    all_man="$p/man/man1/${bin}all.1"
    miss_main=0
    miss_all=0
    [[ -f "$main_man" ]] || miss_main=1
    [[ -f "$all_man" ]] || miss_all=1
    if [[ $miss_main -eq 0 && $miss_all -eq 0 ]]; then
        echo "PASS  $p: man/man1/${bin}.1 + ${bin}all.1 both present"
    else
        msg=""
        [[ $miss_main -eq 1 ]] && msg="$msg missing ${bin}.1;"
        [[ $miss_all -eq 1 ]] && msg="$msg missing ${bin}all.1;"
        echo "FAIL  $p:$msg"
        missing=$((missing + 1))
        ok=0
    fi
done

echo "---"
echo "Summary: $checked Tier 1 Rust binaries checked, $missing missing man pages"

[[ $ok -eq 1 ]] && exit 0 || exit 1
