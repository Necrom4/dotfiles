@default: pull update

@pull:
  yadm fetch
  yadm reset --hard origin/master

@install:
  yadm bootstrap

@update:
  ~/.config/yadm/scripts/update.sh

@brew-dump:
  brew bundle dump --file=~/.config/yadm/scripts/Brewfile --describe --force

@brew-cleandump:
  brew bundle cleanup --file=~/.config/yadm/scripts/Brewfile --force

@brew-cleanup:
  brew cleanup -s
  brew cleanup --prune=all
