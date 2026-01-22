#!/usr/bin/env sh

# Default to HTTPS
yadm remote set-url origin "https://github.com/Necrom4/dotfiles.git"

echo "Testing SSH connectivity to GitHub..."

if
  ssh -T git@github.com >/dev/null 2>&1
  [ $? -eq 1 ] ||
    ssh -T -p 443 git@ssh.github.com >/dev/null 2>&1
  [ $? -eq 1 ]
then
  echo "SSH connection successful. Setting SSH push URL."
  yadm remote set-url --push origin "git@github.com:Necrom4/dotfiles.git"
else
  echo "SSH connection failed or timed out. Falling back to HTTPS for push."
  yadm remote set-url --push origin "https://github.com/Necrom4/dotfiles.git"
fi
