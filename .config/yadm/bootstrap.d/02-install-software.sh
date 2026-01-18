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

gemfile=$HOME/.config/yadm/scripts/Gemfile

if [ -f "$gemfile" ] && [ "$(yadm config local.class)" != "42" ]; then
  echo "Installing Ruby gems..."
  bundle install --gemfile="$gemfile"
fi

# Zinit Installation
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  echo "Installing Zinit..."
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if brew list | grep tmux >/dev/null 2>&1 && [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  echo "Installing TMUX Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi
