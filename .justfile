@default:
  just --list

@pull:
  yadm fetch
  yadm reset --hard origin/master

@install:
  yadm bootstrap

@update:
  $HOME/.config/yadm/scripts/update.sh

@cleanup:
  brew cleanup -s
  brew cleanup --prune=all
  gem cleanup

@brew-dump:
  brew bundle dump --file=$HOME/.config/yadm/scripts/Brewfile --describe --force

@brew-dump-clean:
  brew bundle cleanup --file=$HOME/.config/yadm/scripts/Brewfile --force
