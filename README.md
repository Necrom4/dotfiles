<center>

# DOTFILES

Configuration files for my personal work environment

</center>

<img width="1840" height="1195" alt="Screenshot 2025-10-28 at 13 08 38" src="https://github.com/user-attachments/assets/0b752d72-c06f-454f-9b6c-0d5a493f5c6c" />

## Installation

### Installing `yadm`

> Yadm manages the dotfiles repository.

#### 🍏 <ins>MacOS</ins>

Install [yadm](https://yadm.io) using [Brew](https://brew.sh)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install yadm
```

#### 🐧 <ins>Linux</ins>

Install [yadm](https://yadm.io) using `apt`

```sh
sudo apt update && sudo apt install -y yadm
```

### Cloning the Repository

```sh
yadm clone https://github.com/Necrom4/dotfiles.git
```

### Reinstalling over an existing Repository

```sh
yadm reset --hard
yadm clean -fdx
yadm bootstrap
```

`yadm` will request to execute the **bootstrap** scripts, which install the prerequisites. If no prompt appears, execute

```sh
yadm bootstrap
```

### Terminal settings

- Change the colors to match the Neovim `Tokyonight-moon` theme
- Add the fonts `CommitMono Nerd Font Mono` and `LegacyComputing` (secondary)

## Useful `just` commands

```sh
just list # lists all just commands
just install # sets up tools
just update # updates packages
just pull # pull latest version of dotfiles repo
just cleanup # clean brew and gems
just brew-dump  # Write all installed packages into the Brewfile
just brew-dump-clean # Uninstall all dependencies not present in the Brewfile
```
