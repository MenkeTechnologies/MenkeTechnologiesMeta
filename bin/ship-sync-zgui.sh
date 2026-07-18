#!/usr/bin/env bash
# ship-sync-zgui.sh — pin every zgui-core worktree under an app checkout to a target
# commit before the app is built.
#
# Why: most apps assemble their served frontend (copy-webui) from an *engine-core*
# submodule (zpdf-core, zemail-core, …) whose NESTED frontend/lib/zgui-core the
# ship-apps git phase never reaches — it only bumps the app's own declared zgui-core
# submodule. So a plain `tauri build` embeds a stale zgui-core. Running this first pins
# ALL zgui-core worktrees (top-level AND nested-in-engine-core) to the target, so the
# built artifact actually contains latest zgui-core.
#
# Safety: a zgui-core worktree carrying uncommitted WIP (a concurrent session) makes
# `git checkout` refuse — that worktree is reported and left untouched, never clobbered.
#
# Usage: ship-sync-zgui.sh <app-checkout-dir> <target-zgui-sha>
set -u
app_dir="${1:?usage: ship-sync-zgui.sh <app-dir> <target-sha>}"
target="${2:?usage: ship-sync-zgui.sh <app-dir> <target-sha>}"
[ -d "$app_dir/.git" ] || [ -f "$app_dir/.git" ] || { echo "  ship-sync-zgui: $app_dir is not a git checkout — skip"; exit 0; }

# Make sure nested submodules are on disk so their zgui-core can be pinned.
git -C "$app_dir" submodule update --init --recursive >/dev/null 2>&1 || true

# Every zgui-core worktree under the app (recursive lists nested-in-engine-core too).
git -C "$app_dir" submodule status --recursive 2>/dev/null | awk '{print $2}' | grep 'zgui-core$' | while read -r zg; do
  wt="$app_dir/$zg"
  [ -d "$wt" ] || continue
  cur="$(git -C "$wt" rev-parse HEAD 2>/dev/null)"
  [ "$cur" = "$target" ] && { echo "  zgui ok:   $zg already at ${target:0:9}"; continue; }
  git -C "$wt" fetch -q origin 2>/dev/null || true
  if git -C "$wt" checkout -q "$target" 2>/dev/null; then
    echo "  zgui sync: $zg ${cur:0:9} -> ${target:0:9}"
  else
    echo "  zgui SKIP: $zg dirty/unavailable — left untouched (not clobbered)"
  fi
done

# --- npm-sourced zgui-core (package.json github dep) -----------------------
# Some apps don't use a git submodule at all — they pull zgui-core as an npm
# git-dependency ("zgui-core": "github:MenkeTechnologies/zgui-core#<ref>") and a
# copy-zgui-core step bundles it from node_modules. Repoint every such ref to the
# target commit and refresh the install so the bundled copy is latest too.
repin_dir=""
while IFS= read -r pj; do
  grep -q '"zgui-core"[[:space:]]*:[[:space:]]*"github:MenkeTechnologies/zgui-core#' "$pj" || continue
  # perl (portable in-place; sed -i differs BSD/GNU)
  perl -i -pe 's{("zgui-core"\s*:\s*"github:MenkeTechnologies/zgui-core)#[^"]+"}{${1}#'"$target"'"}g' "$pj"
  echo "  zgui npm:  repinned ${pj#$app_dir/} -> #${target:0:9}"
  # the dir with the lockfile is where install must run; prefer the one holding pnpm-lock.yaml
  [ -f "$(dirname "$pj")/pnpm-lock.yaml" ] && repin_dir="$(dirname "$pj")"
  [ -z "$repin_dir" ] && repin_dir="$(dirname "$pj")"
done < <(find "$app_dir" -maxdepth 3 -name package.json -not -path '*/node_modules/*' 2>/dev/null)

if [ -n "$repin_dir" ]; then
  echo "  zgui npm:  pnpm install to refresh node_modules ($repin_dir)…"
  # no --frozen-lockfile: the spec changed, the lock must re-resolve to the new commit.
  if ( cd "$repin_dir" && pnpm install --no-frozen-lockfile >/dev/null 2>&1 ); then
    echo "  zgui npm:  node_modules refreshed"
  else
    echo "  zgui npm:  pnpm install FAILED — node_modules may be stale"
  fi
fi
exit 0
