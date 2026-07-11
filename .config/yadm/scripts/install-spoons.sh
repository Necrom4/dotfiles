#!/usr/bin/env bash
#
# Clone or update the Hammerspoon Spoons into ~/.hammerspoon/Spoons/<name>.spoon.
#
# Some Spoon repos nest the actual Spoon (the directory containing init.lua) in
# a subdirectory, e.g. GridTile has GridTile.spoon/init.lua at the repo root.
# After cloning, this script "flattens" such repos so that init.lua ends up
# directly at ~/.hammerspoon/Spoons/<name>.spoon/init.lua, keeping the .git
# directory alongside it so future `git pull`s still work.
#
# Usage:
#   install-spoons.sh          # clone if missing, then pull to update
#   install-spoons.sh --clone  # only clone if missing (used by bootstrap)

set -euo pipefail

spoons_dir="$HOME/.hammerspoon/Spoons"
clone_only=false
[ "${1:-}" = "--clone" ] && clone_only=true

# Flatten a freshly-cloned repo so init.lua sits at the Spoon root. Moves the
# repo's .git into the nested Spoon dir, then replaces the destination with it.
flatten_spoon() {
  local dest="$1"

  # Already flat: init.lua at the root, nothing to do.
  [ -f "$dest/init.lua" ] && return 0

  # Find the directory containing init.lua (excluding demo/example dirs).
  local init_path
  init_path=$(find "$dest" -name init.lua -not -path '*/.git/*' \
    -not -path '*/demo/*' -not -path '*/example*/*' -print -quit 2>/dev/null || true)

  if [ -z "$init_path" ]; then
    echo "  ! Could not find init.lua in $dest; leaving as-is" >&2
    return 0
  fi

  local spoon_src
  spoon_src=$(dirname "$init_path")

  # Keep git history: move .git into the nested Spoon dir, then swap dirs.
  mv "$dest/.git" "$spoon_src/.git"
  local tmp="${dest}.flatten.$$"
  mv "$spoon_src" "$tmp"
  rm -rf "$dest"
  mv "$tmp" "$dest"
}

# sync <name> <git-url>
sync() {
  local name="$1" url="$2"
  local dest="$spoons_dir/$name.spoon"

  if [ -d "$dest/.git" ]; then
    if [ "$clone_only" = true ]; then
      return 0
    fi
    echo "Updating $name..."
    git -C "$dest" pull --ff-only
  else
    echo "Cloning $name..."
    mkdir -p "$spoons_dir"
    git clone "$url" "$dest"
    flatten_spoon "$dest"
  fi
}

sync GridTile https://github.com/ujwalnk/GridTile
# sync ClipboardHistory https://github.com/necrom4/ClipboardHistory.spoon
