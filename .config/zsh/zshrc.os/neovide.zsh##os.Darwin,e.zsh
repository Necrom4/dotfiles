# Set Neovide as EDITOR if available
if (( $+commands[neovide] )); then
  export EDITOR="neovide"
fi
