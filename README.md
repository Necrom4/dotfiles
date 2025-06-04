<center>

# DOTFILES

Configuration files for my personal work environment

</center>

- [Installation](#installation)
- [Requirements](#requirements)
- [Bootstrap](#bootstrap)

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

### Reinstalling over and existing Repository

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
