#!/usr/bin/env sh

# Default to HTTPS
echo "Setting the yadm repo origin URL"
yadm remote set-url origin "https://github.com/Necrom4/dotfiles.git"
yadm remote set-url --push origin "git@github.com:Necrom4/dotfiles.git"
