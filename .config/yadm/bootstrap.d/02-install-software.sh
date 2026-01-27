#!/usr/bin/env bash

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brewfile=$HOME/.config/yadm/scripts/Brewfile

if [ -f "$brewfile" ]; then
  echo "Updating homebrew bundle..."
  brew bundle install --file="$brewfile"
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "Installing mise packages..."
  mise install
fi

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
    print -P "%F{33} %F{34}Installation successful.%f%b" ||
    print -P "%F{160} The clone has failed.%f%b"
fi

if brew list | grep tmux >/dev/null 2>&1 && [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  echo "Installing TMUX Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi
