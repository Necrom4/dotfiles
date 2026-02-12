alias c := clean
alias i := install
alias u := update

host := `uname -s`

@default:
    just --list

@brew-dump:
    brew bundle dump --file=$HOME/.config/yadm/scripts/Brewfile --describe --force

@brew-dump-clean:
    brew bundle cleanup --file=$HOME/.config/yadm/scripts/Brewfile --force

clean: clean-apt clean-brew clean-mise clean-gems

clean-apt:
    #!/usr/bin/env bash
    set -euo pipefail
    [[ "{{ host }}" != "Linux" ]] && exit 0
    sudo apt autoremove -y
    sudo apt autoclean

@clean-brew:
    brew cleanup -s
    brew cleanup --prune=all

@clean-gems:
    gem cleanup

@clean-mise:
    mise prune
    mise cache clear
    mise cache prune

@install:
    yadm bootstrap

@update:
    $HOME/.config/yadm/scripts/update.sh

@pull:
    yadm fetch
    yadm reset --hard origin/master
