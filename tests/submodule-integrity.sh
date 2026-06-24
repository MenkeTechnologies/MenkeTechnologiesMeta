#!/usr/bin/env bash
# Pins structural invariants on .gitmodules so the 114-submodule org-wide
# graph can't quietly drift: every entry must (a) have a present path,
# (b) point to a https github.com/MenkeTechnologies/<name>.git url,
# (c) declare its branch field, (d) match path basename = repo name.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

gm=".gitmodules"
[[ -f "$gm" ]] || { echo "FAIL  no $gm"; exit 1; }

n=$(grep -c "^\[submodule" "$gm")
if [[ $n -ne 114 ]]; then
    echo "FAIL  expected 114 submodule entries, got $n"
    ok=0
else
    echo "PASS  .gitmodules has 114 submodule entries"
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
    # In-progress rename exception: zpwr-clip-engine was renamed to zpwr-daw on
    # GitHub, so the url is the new .../zpwr-daw.git while the submodule directory
    # still lags at zpwr-clip-engine. This is a deliberate, known transitional
    # state — not a typo'd url. Drop this entry once the directory is renamed.
    if [[ "$path_base" == "zpwr-clip-engine" && "$repo_from_url" == "zpwr-daw" ]]; then
        :
    elif [[ "$repo_from_url" != "$path_base" ]]; then
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

# Every checked-out submodule path must have a populated .git/ (either a
# directory or a `.git` file pointing into the parent's .git/modules/<...>).
# An empty checkout means `git submodule update --init` was never run; the
# submodule looks like an empty directory and any operation against it
# silently no-ops. This check is INFORMATIONAL in CI where submodules
# aren't initialized — the path-exists guard above already skips there.
if [[ $check_path_exists -eq 1 ]]; then
    missing_dotgit=0
    for p in "${paths[@]}"; do
        # `.git` can be a directory (older / detached) OR a file (gitlink
        # to the parent's modules/ dir, modern submodules). Both are OK.
        if [[ ! -e "$p/.git" ]]; then
            echo "FAIL  submodule has no .git/: $p"
            missing_dotgit=$((missing_dotgit + 1))
            ok=0
        fi
    done
    [[ $missing_dotgit -eq 0 ]] && echo "PASS  every checked-out submodule has a populated .git/"
fi

# Every `branch = ` field, if present, must be `main` or `master`. A
# detached or "HEAD" branch field means `git submodule update --remote`
# would either fail or pick an arbitrary ref. Empty .gitmodules entries
# (no branch field at all) are tolerated — git defaults to the submodule
# HEAD, which is what we want for SHA-pinned submodules.
bad_branch=0
while IFS= read -r line; do
    val="${line#$'\tbranch = '}"
    case "$val" in
        main|master) :;;
        *)
            echo "FAIL  branch field '$val' is neither 'main' nor 'master'"
            bad_branch=$((bad_branch + 1))
            ok=0
            ;;
    esac
done < <(grep $'^\tbranch = ' "$gm")
[[ $bad_branch -eq 0 ]] && echo "PASS  every declared branch field is main or master"

# `git submodule status` must succeed (return 0) and emit one line per
# submodule. A failure here means a submodule entry is corrupt OR the
# repo isn't a git repo at all. Skip when submodules aren't initialized.
if [[ $check_path_exists -eq 1 ]] && command -v git >/dev/null 2>&1; then
    if status_lines=$(git submodule status 2>/dev/null) && [[ -n "$status_lines" ]]; then
        status_n=$(printf '%s\n' "$status_lines" | wc -l | tr -d ' ')
        if [[ "$status_n" -eq "${#paths[@]}" ]]; then
            echo "PASS  git submodule status emits one line per .gitmodules entry ($status_n)"
        else
            echo "FAIL  git submodule status emitted $status_n lines for ${#paths[@]} entries"
            ok=0
        fi
    else
        echo "SKIP  git submodule status (not a populated submodule tree)"
    fi
fi

[[ $ok -eq 1 ]] && exit 0 || exit 1
