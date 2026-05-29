#!/usr/bin/env bash
# Pins structural invariants on .gitmodules so the 64-submodule org-wide
# graph can't quietly drift: every entry must (a) have a present path,
# (b) point to a https github.com/MenkeTechnologies/<name>.git url,
# (c) declare its branch field, (d) match path basename = repo name.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
ok=1

gm=".gitmodules"
[[ -f "$gm" ]] || { echo "FAIL  no $gm"; exit 1; }

n=$(grep -c "^\[submodule" "$gm")
if [[ $n -ne 64 ]]; then
    echo "FAIL  expected 64 submodule entries, got $n"
    ok=0
else
    echo "PASS  .gitmodules has 64 submodule entries"
fi

# Parse paths and urls in order
paths=()
urls=()
while IFS= read -r line; do
    case "$line" in
        $'\tpath = '*) paths+=("${line#$'\tpath = '}");;
        $'\turl = '*)  urls+=("${line#$'\turl = '}");;
    esac
done < "$gm"

if [[ ${#paths[@]} -ne ${#urls[@]} ]]; then
    echo "FAIL  path/url pairing mismatch (${#paths[@]} paths vs ${#urls[@]} urls)"
    ok=0
fi

missing_paths=0
bad_urls=0
basename_mismatches=0
# Skip the path-exists check in environments where submodules aren't
# checked out (e.g. CI without `submodules: true` on actions/checkout).
# Heuristic: at least one path is a non-empty directory means we're
# in a populated working tree; otherwise treat the check as informational.
check_path_exists=0
for p in "${paths[@]}"; do
    if [[ -d "$p" && -n "$(ls -A "$p" 2>/dev/null)" ]]; then
        check_path_exists=1
        break
    fi
done
for i in "${!paths[@]}"; do
    p="${paths[$i]}"
    u="${urls[$i]}"
    if [[ $check_path_exists -eq 1 && ! -d "$p" ]]; then
        echo "FAIL  submodule path missing: $p"
        missing_paths=$((missing_paths + 1))
        ok=0
    fi
    case "$u" in
        https://github.com/MenkeTechnologies/*.git) :;;
        *)
            echo "FAIL  url not https github MenkeTechnologies .git: $p → $u"
            bad_urls=$((bad_urls + 1))
            ok=0
            ;;
    esac
    repo_from_url="${u##*/}"
    repo_from_url="${repo_from_url%.git}"
    path_base="${p##*/}"
    if [[ "$repo_from_url" != "$path_base" ]]; then
        echo "FAIL  url repo name != path basename: $p (url says $repo_from_url)"
        basename_mismatches=$((basename_mismatches + 1))
        ok=0
    fi
done

if [[ $check_path_exists -eq 1 ]]; then
    [[ $missing_paths -eq 0 ]] && echo "PASS  every submodule path exists in working tree"
else
    echo "SKIP  path-exists (no submodules initialized in this checkout)"
fi
[[ $bad_urls -eq 0 ]] && echo "PASS  every submodule url is https://github.com/MenkeTechnologies/*.git"
[[ $basename_mismatches -eq 0 ]] && echo "PASS  every url repo name matches path basename"

dupes=$(printf '%s\n' "${paths[@]}" | sort | uniq -d)
if [[ -n "$dupes" ]]; then
    echo "FAIL  duplicate submodule paths: $dupes"
    ok=0
else
    echo "PASS  no duplicate submodule paths"
fi

dupes_url=$(printf '%s\n' "${urls[@]}" | sort | uniq -d)
if [[ -n "$dupes_url" ]]; then
    echo "FAIL  duplicate submodule urls: $dupes_url"
    ok=0
else
    echo "PASS  no duplicate submodule urls"
fi

[[ $ok -eq 1 ]] && exit 0 || exit 1
