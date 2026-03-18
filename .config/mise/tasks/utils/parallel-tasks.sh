#!/usr/bin/env bash
# utils/parallel-tasks.sh — shared logic for interactive task selection + parallel tmux panes
#
# Expected variables (set by caller before sourcing):
#   PREFIX       — task prefix, e.g. "update" or "clean"
#   MENU_TITLE   — title shown in the selection box, e.g. "Select updates to run"
#   TMUX_WINDOW  — tmux window/session name, e.g. "mise-updates"
#
# Optional overrides (define before sourcing):
#   check_exists()      — custom existence check; default: command -v
#   check_needs_sudo()  — sets needs_sudo=1 if sudo is required; default: noop

source "$(cd "$(dirname "$0")" && pwd)/utils/colors.sh"

T_OK="${GREEN}${BOLD}"
T_WARNING="${YELLOW}${BOLD}"
T_ERROR="${RED}${BOLD}"
T_PROGRAM="${CYAN}${BOLD}"

die() {
  printf "${T_ERROR}%s${NC}\n" "$1" >&2
  exit 1
}

# Default check_exists if caller didn't define one
if ! declare -f check_exists >/dev/null 2>&1; then
  check_exists() { command -v "$1" >/dev/null 2>&1; }
fi

# Default check_needs_sudo if caller didn't define one
if ! declare -f check_needs_sudo >/dev/null 2>&1; then
  check_needs_sudo() { needs_sudo=0; }
fi

# ── Gather available tasks ───────────────────────────────────────────────────

mapfile -t all_tasks < <(mise tasks ls --raw | awk -v p="^${PREFIX}:.+" '$1 ~ p && $1 != "'"${PREFIX}"'" {print $1}')

available=()
for task in "${all_tasks[@]}"; do
  name="${task#${PREFIX}:}"
  if check_exists "$name"; then
    available+=("$task")
  else
    printf "${T_WARNING}[%s]${NC} not found, skipping.\n" "$task"
  fi
done

[[ ${#available[@]} -eq 0 ]] && die "No ${PREFIX} tasks found."

# ── Interactive selection ────────────────────────────────────────────────────

declare -A selected
for task in "${available[@]}"; do selected["$task"]=1; done

cursor=0
needs_sudo=0
sudo_pass=""

cleanup_screen() { tput rmcup 2>/dev/null || printf '\033[?1049l'; }
tput smcup 2>/dev/null || printf '\033[?1049h'
tput civis 2>/dev/null
trap cleanup_screen EXIT

print_menu() {
  local el=$'\033[K'
  local buf='\033[H'

  buf+="${BOLD}╭─────────────────────────────────────────╮${NC}${el}\n"
  buf+="${BOLD}│        ${MENU_TITLE}${NC}${el}\n"
  buf+="${BOLD}╰─────────────────────────────────────────╯${NC}${el}\n${el}\n"

  local i=0
  for task in "${available[@]}"; do
    local name="${task#${PREFIX}:}"
    if [[ $i -eq $cursor ]]; then
      if [[ ${selected["$task"]} -eq 1 ]]; then
        buf+="  ${BOLD}▸${NC} ${T_PROGRAM}󰡖${NC} ${name}${el}\n"
      else
        buf+="  ${BOLD}▸${NC} ${T_ERROR}󰄱${NC} ${name}${el}\n"
      fi
    else
      if [[ ${selected["$task"]} -eq 1 ]]; then
        buf+="    ${T_PROGRAM}󰡖${NC} ${name}${el}\n"
      else
        buf+="    ${T_ERROR}󰄱${NC} ${name}${el}\n"
      fi
    fi
    ((i++)) || true
  done

  check_needs_sudo

  buf+="${el}\n"
  if [[ $needs_sudo -eq 1 ]]; then
    buf+="  ${T_WARNING}sudo required${NC} - password will be requested${el}\n"
  fi
  buf+="${el}\n"

  buf+="  ${BOLD}Space${NC}) Toggle    "
  buf+="${BOLD}a${NC}) Toggle all    "
  buf+="${T_OK}${BOLD}Enter${NC}) Confirm    "
  buf+="${T_ERROR}q${NC}) Quit${el}"
  buf+='\033[J'

  printf '%b' "$buf"
}

read_key() {
  local key
  IFS= read -rsn1 key
  if [[ "$key" == $'\033' ]]; then
    local seq
    IFS= read -rsn1 -t 0.01 seq
    if [[ "$seq" == "[" ]]; then
      IFS= read -rsn1 -t 0.01 seq
      case "$seq" in
      A) key="UP" ;; B) key="DOWN" ;; *) key="ESC" ;;
      esac
    else
      key="ESC"
    fi
  fi
  printf '%s' "$key"
}

while true; do
  print_menu
  key="$(read_key)"

  case "$key" in
  k | UP) ((cursor > 0)) && ((cursor--)) || true ;;
  j | DOWN) ((cursor < ${#available[@]} - 1)) && ((cursor++)) || true ;;
  " " | TAB)
    task="${available[$cursor]}"
    if [[ ${selected["$task"]} -eq 1 ]]; then
      selected["$task"]=0
    else
      selected["$task"]=1
    fi
    ;;
  a | A)
    all_on=1
    for task in "${available[@]}"; do
      [[ ${selected["$task"]} -eq 0 ]] && all_on=0 && break
    done
    for task in "${available[@]}"; do
      selected["$task"]=$((all_on ? 0 : 1))
    done
    ;;
  q | ESC)
    tput cnorm 2>/dev/null
    cleanup_screen
    trap - EXIT
    printf "${T_ERROR}Cancelled.${NC}\n"
    exit 1
    ;;
  "")
    check_needs_sudo
    if [[ $needs_sudo -eq 1 ]]; then
      tput cnorm 2>/dev/null
      printf "\n\n  ${T_ERROR}sudo${NC} password: "
      read -rs sudo_pass
      if [[ -z "$sudo_pass" ]]; then
        tput civis 2>/dev/null
        continue
      fi
    fi
    break
    ;;
  esac
done

tput cnorm 2>/dev/null
cleanup_screen
trap - EXIT

# ── Build chosen list ────────────────────────────────────────────────────────

chosen=()
for task in "${available[@]}"; do
  [[ ${selected["$task"]} -eq 1 ]] && chosen+=("$task")
done
[[ ${#chosen[@]} -eq 0 ]] && die "Nothing selected."

# ── Launch tmux panes ────────────────────────────────────────────────────────

make_cmd() {
  local task="$1"
  local name="${task#${PREFIX}:}"
  local cmd=""

  if [[ "$name" == "apt" ]] && [[ -n "$sudo_pass" ]]; then
    cmd="printf '%s\n' '$(printf '%s' "$sudo_pass" | sed "s/'/'\\\\''/g")' | sudo -S true 2>/dev/null; "
    cmd+="mise run $task"
  else
    cmd="mise run $task"
  fi

  printf 'printf "\\n\\033[1;36m── %s ──\\033[0m\\n"; %s && printf "\\n\\033[1;32m✓ %s succeeded\\033[0m\\n" || printf "\\n\\033[1;31m✗ %s failed\\033[0m\\n"; printf "\\n(press any key to close)"; read -r -n 1' \
    "$name" "$cmd" "$name" "$name"
}

inside_tmux=false
[[ -n "${TMUX:-}" ]] && inside_tmux=true

if $inside_tmux; then
  current_session="$(tmux display-message -p '#S')"
  tmux new-window -t "$current_session" -n "$TMUX_WINDOW" "$(make_cmd "${chosen[0]}")"
  target="$current_session:$TMUX_WINDOW"
else
  tmux kill-session -t "$TMUX_WINDOW" 2>/dev/null || true
  tmux new-session -d -s "$TMUX_WINDOW" -x "$(tput cols)" -y "$(tput lines)" \
    "$(make_cmd "${chosen[0]}")"
  target="$TMUX_WINDOW"
fi

for task in "${chosen[@]:1}"; do
  tmux split-window -t "$target" "$(make_cmd "$task")"
  tmux select-layout -t "$target" tiled >/dev/null
done

tmux select-layout -t "$target" tiled >/dev/null
tmux select-pane -t "$target.{top-left}"
sudo_pass=""

if $inside_tmux; then
  tmux select-window -t "$target"
else
  tmux attach-session -t "$TMUX_WINDOW"
fi
