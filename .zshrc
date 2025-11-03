if [[ "$(uname)" == "Linux" && -f "$HOME/.zprofile" ]]; then
  source "$HOME/.zprofile"
fi
source ~/.config/zsh/zshrc
