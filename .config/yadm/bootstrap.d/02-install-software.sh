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

if [[ ! -d "${HOME}/.oh-my-zsh/" ]]; then
  echo "Installing Oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if brew list | grep tmux >/dev/null 2>&1; then
  echo "Installing TMUX Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$XDG_CONFIG_HOME/tmux/plugins/tpm"
fi
