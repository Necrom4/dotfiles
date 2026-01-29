alias c := cleanup
alias i := install
alias u := update

host := `uname -s`

@default:
    just --list

@pull:
    yadm fetch
    yadm reset --hard origin/master

@install:
    yadm bootstrap

@update:
    $HOME/.config/yadm/scripts/update.sh

cleanup: clean-apt clean-brew clean-mise clean-gems

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
    mise cache clear
    mise cache prune
    mise prune

@brew-dump:
    brew bundle dump --file=$HOME/.config/yadm/scripts/Brewfile --describe --force

@brew-dump-clean:
    brew bundle cleanup --file=$HOME/.config/yadm/scripts/Brewfile --force
