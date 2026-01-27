# Set Neovide as EDITOR if available
if (( $+commands[neovide.exe] )); then
  export EDITOR="neovide.exe"
fi
