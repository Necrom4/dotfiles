#!/usr/bin/env sh

echo "Updating the yadm repo origin URL"
yadm remote set-url origin "https://github.com/Necrom4/dotfiles.git"

ssh -o ConnectTimeout=3 -T git@github.com >/dev/null 2>&1
ssh_status=$?

if [ "$ssh_status" -eq 1 ] || [ "$ssh_status" -eq 0 ]; then
  yadm remote set-url --push origin "git@github.com:Necrom4/dotfiles.git"
else
  yadm remote set-url --push origin "https://github.com/Necrom4/dotfiles.git"
fi
