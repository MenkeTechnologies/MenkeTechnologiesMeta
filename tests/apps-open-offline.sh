#!/usr/bin/env bash
# Every Tauri desktop app must be able to open with no network.
#
# Why this gate exists: twelve of the apps shipped an index.html that opened with
#
#     <link rel="preconnect" href="https://fonts.googleapis.com">
#     <link href="https://fonts.googleapis.com/css2?family=Orbitron..." rel="stylesheet">
#
# and a CSP that whitelisted fonts.googleapis.com / fonts.gstatic.com to let it through. A
# render-blocking stylesheet against a CDN is a network dependency on the boot path: offline it
# fails, and behind a captive portal or slow DNS it stalls first paint. zgui-core already vendors
# Orbitron + Share Tech Mono as @font-face rules over .ttf files it ships, so the CDN bought
# nothing. zphoto / zthrottle / ztranslator had already been fixed by hand; the other twelve had
# not, and nothing stopped the pattern from being copied into the next app.
#
# Two invariants pinned, both derived from the fleet rather than a hardcoded app list:
#
#   1. Markup. No tracked HTML/CSS the app actually serves may pull a resource from an external
#      host — no <script src>, <link href>, <img src>, or @import against http(s)://<host>.
#      Anchor hrefs are out of scope: a link the user clicks is not a load the window waits on.
#
#   2. CSP. The app's csp string may not name a remote host. Loopback and the tauri-internal
#      pseudo-hosts (ipc.localhost, asset.localhost, <scheme>.localhost) are fine — they never
#      leave the machine. A bare `https:` / `http:` scheme token is also allowed: zemail needs it
#      for remote images inside a message, which is user content fetched long after the window
#      opened. What is rejected is a named external origin, which is what a CDN dependency is.
#
# Scope is the served frontend of each app plus the webui/frontend of its *-core engines, which
# are copied into that frontend at build time by the app's copy-webui.mjs. Vendored copies under
# lib/ and vendor/ regenerate from their own repo and are checked there.
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root" || exit
ok=1

# Submodule paths, so an app is only checked when its worktree is actually present.
paths=()
while IFS= read -r line; do
    paths+=("${line#$'\tpath = '}")
done < <(grep $'^\tpath = ' .gitmodules)

# An app is a submodule containing a tauri.conf.json within three levels (src-tauri/ at the repo
# root, or app/src-tauri/ in the two-level layout). Nested copies of another app are skipped.
confs=()
for p in "${paths[@]}"; do
    [[ -d "$p" ]] || continue
    while IFS= read -r c; do
        confs+=("$c")
    done < <(find "$p" -maxdepth 3 -name tauri.conf.json -not -path '*/target/*' -not -path '*/node_modules/*' 2>/dev/null | sort)
done

if [[ ${#confs[@]} -eq 0 ]]; then
    echo "SKIP  no app tauri.conf.json found (need git submodule update --init)"
    exit 0
fi

# perl (never sed): the external hosts a CSP names, one per line, minus everything that stays on
# this machine.
csp_remote_hosts() {
    perl -0777 -ne '
        exit unless /"csp"\s*:\s*"((?:[^"\\]|\\.)*)"/s;
        my $csp = $1;
        my %seen;
        while ($csp =~ m{(?:https?|wss?)://([A-Za-z0-9._*-]+)}g) {
            my $h = $1;
            next if $h =~ /(^|\.)localhost$/;
            next if $h eq "127.0.0.1" || $h eq "::1";
            print "$h\n" unless $seen{$h}++;
        }
    ' "$1"
}

# The external resource loads in a markup/style file: src=/href= on a loading element, or an
# @import. <a href> is deliberately not matched — the pattern requires a loading tag before it.
grep_remote_assets() {
    grep -nIE '<(script|link|img|iframe|source|video|audio|embed)[^>]+(src|href)[[:space:]]*=[[:space:]]*["'"'"']?https?://|@import[[:space:]]+url\([[:space:]]*["'"'"']?https?://' "$1" 2>/dev/null
}

checked=0
bad_apps=0
for conf in "${confs[@]}"; do
    tauri_dir="$(dirname "$conf")"          # .../src-tauri
    app_dir="$(dirname "$tauri_dir")"       # .../app  or the repo root
    repo="${conf%%/*}"
    name="$(basename "$repo")"
    checked=$((checked + 1))
    app_bad=0

    # (1) CSP names no external origin.
    while IFS= read -r host; do
        [[ -z "$host" ]] && continue
        echo "FAIL  $conf: csp names the external host '$host'"
        app_bad=1
    done < <(csp_remote_hosts "$conf")

    # (2) The served markup pulls nothing from an external host. frontendDist is relative to the
    #     src-tauri dir; the *-core engines feed that same tree through copy-webui.mjs.
    dist="$(perl -0777 -ne 'print $1 if /"frontendDist"\s*:\s*"([^"]*)"/' "$conf")"
    scan_dirs=()
    [[ -n "$dist" ]] && scan_dirs+=("$(cd "$tauri_dir" && cd "$dist" 2>/dev/null && pwd)")
    while IFS= read -r d; do
        [[ -n "$d" ]] && scan_dirs+=("$d")
    done < <(find "$app_dir/../crates" "$app_dir/crates" -maxdepth 2 \( -name webui -o -name frontend \) -type d 2>/dev/null | sort -u)

    for d in "${scan_dirs[@]}"; do
        [[ -n "$d" && -d "$d" ]] || continue
        rel="${d#$root/}"
        sub="${rel%%/*}"
        # Only tracked files: the generated frontends are gitignored copies of these same sources.
        while IFS= read -r f; do
            case "$f" in
                */lib/*|*/vendor/*|*/node_modules/*|*/docs/*|*/scripts/*) continue ;;
            esac
            hits="$(grep_remote_assets "$sub/$f")"
            [[ -z "$hits" ]] && continue
            while IFS= read -r h; do
                echo "FAIL  $sub/$f:${h%%:*} loads an external resource on the boot path"
                app_bad=1
            done <<< "$hits"
        done < <(git -C "$sub" ls-files -- "${rel#$sub/}/*.html" "${rel#$sub/}/*.css" 2>/dev/null)
    done

    if [[ $app_bad -eq 1 ]]; then
        bad_apps=$((bad_apps + 1))
        ok=0
    else
        echo "ok    $name opens offline"
    fi
done

echo "---"
echo "Summary: $checked apps checked, $bad_apps with a network dependency on open"

[[ $ok -eq 1 ]] && exit 0 || exit 1
