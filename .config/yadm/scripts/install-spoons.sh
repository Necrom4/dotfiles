#!/usr/bin/env bash
#
# Install/update the Hammerspoon Spoons directly under ~/.hammerspoon/Spoons/,
# as real <name>.spoon directories (no symlinks, no staging dirs).
#
# Each repo is fetched into a temporary clone, the actual Spoon directory (the
# one containing init.lua) is located, and its contents are copied into
# ~/.hammerspoon/Spoons/<name>.spoon. This handles repos that keep init.lua at
# the root (e.g. ClipboardHistory) as well as those that nest it in a
# subdirectory (e.g. GridTile has GridTile.spoon/init.lua). The destination is
# replaced on every run, so it works whether the Spoon is missing, present and
# up to date, or outdated.
#
# Usage:
#   install-spoons.sh          # install missing Spoons and update existing ones
#   install-spoons.sh --clone  # only install Spoons that are missing

set -euo pipefail

spoons_dir="$HOME/.hammerspoon/Spoons"
clone_only=false
[ "${1:-}" = "--clone" ] && clone_only=true

# Print the directory (within a cloned repo) that contains the Spoon's
# init.lua, preferring the repo root, then a "<name>.spoon" subdir, then any
# other init.lua (excluding demo/example dirs).
find_spoon_dir() {
  local repo="$1" name="$2"

  if [ -f "$repo/init.lua" ]; then
    echo "$repo"
    return 0
  fi
  if [ -f "$repo/$name.spoon/init.lua" ]; then
    echo "$repo/$name.spoon"
    return 0
  fi

  local init_path
  init_path=$(find "$repo" -name init.lua -not -path '*/.git/*' \
    -not -path '*/demo/*' -not -path '*/example*/*' -print -quit 2>/dev/null || true)
  [ -n "$init_path" ] && dirname "$init_path"
}

# sync <name> <git-url>
sync() {
  local name="$1" url="$2"
  local dest="$spoons_dir/$name.spoon"

  if [ -d "$dest" ] && [ "$clone_only" = true ]; then
    return 0
  fi

  if [ -d "$dest" ]; then
    echo "Updating $name..."
  else
    echo "Installing $name..."
  fi

  local tmp
  tmp=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN

  git clone --depth 1 "$url" "$tmp/repo" >/dev/null 2>&1

  local spoon_dir
  spoon_dir=$(find_spoon_dir "$tmp/repo" "$name")
  if [ -z "$spoon_dir" ]; then
    echo "  ! Could not find init.lua in $name; skipping" >&2
    return 0
  fi

  mkdir -p "$spoons_dir"
  rm -rf "$dest"
  mkdir -p "$dest"
  # Copy the Spoon's files, dropping git metadata.
  (cd "$spoon_dir" && tar --exclude='.git' -cf - .) | (cd "$dest" && tar -xf -)
}

sync GridTile https://github.com/ujwalnk/GridTile
sync ClipboardHistory https://github.com/necrom4/ClipboardHistory.spoon
sync Coffee https://github.com/necrom4/Coffee.spoon
