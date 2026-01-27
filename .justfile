@default:
    just --list

@pull:
    yadm fetch
    yadm reset --hard origin/master

@install:
    yadm bootstrap

@update:
    $HOME/.config/yadm/scripts/update.sh

cleanup: clean-brew clean-mise clean-gems

@clean-brew:
    brew cleanup -s
    brew cleanup --prune=all

@clean-mise:
    mise cache clear
    mise cache prune
    mise prune

@clean-gems:
    gem cleanup

@brew-dump:
    brew bundle dump --file=$HOME/.config/yadm/scripts/Brewfile --describe --force

@brew-dump-clean:
    brew bundle cleanup --file=$HOME/.config/yadm/scripts/Brewfile --force
