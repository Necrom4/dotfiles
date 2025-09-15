#!/usr/bin/env sh

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

if [ -f "$gemfile" ]; then
  echo "Installing Ruby gems..."
  bundle install --gemfile="$gemfile"
fi

if [[ ! -d "${HOME}/.oh-my-zsh/" ]]; then
  echo "Installing Oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
