#!/usr/bin/env bash
set -euo pipefail

YADM_SCRIPTS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../scripts" &>/dev/null && pwd)
source "${YADM_SCRIPTS}/colors.sh"
T_OK="${GREEN}${BOLD}"
T_WARNING="${YELLOW}${BOLD}"
T_ERROR="${RED}${BOLD}"
T_PROGRAM="${CYAN}${BOLD}"

CONTINUE_ALL=""

update_tool() {
  local name="$1"
  local tool="$2"
  shift 2
  local found=false
  if [[ "$tool" == */* || "$tool" == "~"* ]]; then
    if [ -d "$tool" ]; then
      found=true
    fi
  else
    if command -v "$tool" &>/dev/null; then
      found=true
    fi
  fi

  if [ "$found" = true ]; then
    if [ -z "$CONTINUE_ALL" ]; then
      while true; do
        printf "Update ${T_PROGRAM}%s${NC}? [${T_OK}Y${NC}es/${T_OK}A${NC}ll/${T_WARNING}N${NC}o/${T_ERROR}C${NC}ancel]" "$name"
        read -r -n 1 input
        case "$input" in
        [yY]*)
          printf "\n"
          break
          ;;
        [aA]*)
          CONTINUE_ALL="true"
          printf "\n"
          break
          ;;
        [nN]*)
          printf "\n[${T_WARNING}SKIPPING${NC}]\n"
          return 0
          ;;
        [cC]*)
          printf "\n[${T_ERROR}CANCELLED${NC}]\n"
          exit 1
          ;;
        *)
          printf "Invalid input. Please enter Y, A, N or C.\n"
          ;;
        esac
      done
    else
      printf "Updating ${T_PROGRAM}%s${NC}\n" "$name"
    fi

    for cmd in "$@"; do
      eval "$cmd"
    done
    printf "[${T_OK}SUCCEEDED${NC}]\n"
  else
    printf "[${T_WARNING}SKIPPING${NC}] ${T_PROGRAM}%s${NC} not found.\n" "$name"
  fi
}

update_tool "Homebrew" "brew" "brew update" "brew upgrade"

update_tool "Mise" "mise" "mise plugins update" "mise upgrade"

update_tool "Ruby gems" "gem" "bundle update --gemfile=~/.config/yadm/scripts/Gemfile"

# update_tool "neovim plugins" "nvim" \
#   "nvim --headless '+Lazy! sync' +qa"
#
# update_tool "neovim mason" "nvim" \
#   "nvim --headless '+MasonUpdate' +qa"

update_tool "Oh My Zsh" "${ZSH:-$HOME/.oh-my-zsh}" "zsh -i -c 'omz update'"

update_tool "Powerlevel10k" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" "git -C \"${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k\" pull"

update_tool "TLDR" "tldr" "tldr --update"

update_tool "Yazi packages" "ya" \
  "rm -rf ~/.config/yazi/plugins/* ~/.config/yazi/flavors/*" \
  "yadm checkout -- ~/.config/yazi/" \
  "ya pkg upgrade" \
  "git clone https://gitlab.com/WhoSowSee/whoosh.yazi.git ~/.config/yazi/plugins/whoosh.yazi"
