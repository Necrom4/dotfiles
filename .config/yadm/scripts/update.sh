#!/usr/bin/env bash
set -euo pipefail

YADM_SCRIPTS=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../scripts" &>/dev/null && pwd)
source "${YADM_SCRIPTS}/colors.sh"
T_OK="${GREEN}${BOLD}"
T_WARNING="${YELLOW}${BOLD}"
T_ERROR="${RED}${BOLD}"
T_PROGRAM="${CYAN}${BOLD}"

CONTINUE_ALL=""

# Universal update function
# Usage: update_tool "Name" "check_type:value" "command1" "command2" ...
#
# Check types:
#   cmd:name     - Check if command 'name' exists
#   dir:path     - Check if directory exists
#   file:path    - Check if file exists
#   always       - Always run (no check needed)
#
# Command prefixes:
#   zsh:command  - Run command in zsh (for zsh plugins/functions)
#   git:path     - Run 'git pull' in the specified directory
#   (no prefix)  - Run command in bash
#
update_tool() {
  local name="$1"
  local check="$2"
  shift 2
  local found=false

  local check_type="${check%%:*}"
  local check_value="${check#*:}"

  # Expand ~ in paths
  check_value="${check_value/#\~/$HOME}"

  case "$check_type" in
  cmd)
    command -v "$check_value" &>/dev/null && found=true
    ;;
  dir)
    [ -d "$check_value" ] && found=true
    ;;
  file)
    [ -f "$check_value" ] && found=true
    ;;
  always)
    found=true
    ;;
  *)
    # Backwards compatibility: treat as command if no type specified
    command -v "$check" &>/dev/null && found=true
    ;;
  esac

  if [ "$found" = false ]; then
    printf "[${T_WARNING}SKIPPING${NC}] ${T_PROGRAM}%s${NC} not found.\\n" "$name"
    return 0
  fi

  # Prompt user
  if [ -z "$CONTINUE_ALL" ]; then
    while true; do
      printf "Update ${T_PROGRAM}%s${NC}? [${T_OK}Y${NC}es/${T_OK}A${NC}ll/${T_WARNING}N${NC}o/${T_ERROR}C${NC}ancel] " "$name"
      read -r -n 1 input
      case "$input" in
      [yY]*)
        printf "\\n"
        break
        ;;
      [aA]*)
        CONTINUE_ALL="true"
        printf "\\n"
        break
        ;;
      [nN]*)
        printf "\\n[${T_WARNING}SKIPPING${NC}]\\n"
        return 0
        ;;
      [cC]*)
        printf "\\n[${T_ERROR}CANCELLED${NC}]\\n"
        exit 1
        ;;
      *)
        printf "\\nInvalid input. Please enter Y, A, N or C.\\n"
        ;;
      esac
    done
  else
    printf "Updating ${T_PROGRAM}%s${NC}\\n" "$name"
  fi

  # Execute commands
  for cmd in "$@"; do
    local cmd_type="${cmd%%:*}"
    local cmd_value="${cmd#*:}"

    # Expand ~ in command values
    cmd_value="${cmd_value/#\~/$HOME}"

    case "$cmd_type" in
    zsh)
      # Run in zsh (source zshrc to load plugins, NO_HUP prevents killing background jobs on exit)
      zsh -c "setopt NO_HUP; source \"\$HOME/.zshrc\"; $cmd_value"
      ;;
    git)
      # Git pull in directory
      git -C "$cmd_value" pull
      ;;
    *)
      # Default: run as bash command
      eval "$cmd"
      ;;
    esac
  done

  printf "[${T_OK}SUCCEEDED${NC}]\\n"
}

# =============================================================================
# Tool Updates
# =============================================================================

update_tool "System packages (apt)" "cmd:apt" \
  "sudo apt update" \
  "sudo apt upgrade -y"

update_tool "Homebrew" "cmd:brew" \
  "brew update" \
  "brew upgrade"

update_tool "Mise" "cmd:mise" \
  "mise plugins update" \
  "mise upgrade"

update_tool "Zinit" "dir:~/.local/share/zinit/zinit.git" \
  "zsh:zinit self-update"

update_tool "Zinit plugins" "dir:~/.local/share/zinit/zinit.git" \
  "zsh:zinit update --parallel"

update_tool "TLDR" "cmd:tldr" \
  "tldr --update"

update_tool "Yazi packages" "cmd:ya" \
  "rm -rf ~/.config/yazi/plugins/* ~/.config/yazi/flavors/*" \
  "yadm checkout -- ~/.config/yazi/" \
  "ya pkg upgrade" \
  "git clone https://gitlab.com/WhoSowSee/whoosh.yazi.git ~/.config/yazi/plugins/whoosh.yazi"

update_tool "Tmux TPM" "dir:$HOME/.config/tmux/plugins/tpm" \
  "$HOME/.config/tmux/plugins/tpm/bin/update_plugins all"
