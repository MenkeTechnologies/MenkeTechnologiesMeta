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
exit 0
