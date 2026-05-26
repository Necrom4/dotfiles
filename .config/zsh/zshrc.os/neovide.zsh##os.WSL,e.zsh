local config_src="$HOME/.config/neovide/config.toml"
local config_dest_dir

# Cache the Windows username — it never changes
if [[ -z "$WIN_USER" ]]; then
  if [[ -r "$HOME/.cache/win_user" ]]; then
    WIN_USER=$(<"$HOME/.cache/win_user")
  else
    WIN_USER=$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    [[ -n "$WIN_USER" ]] && {
      mkdir -p "$HOME/.cache"
      print -r -- "$WIN_USER" > "$HOME/.cache/win_user"
    }
  fi
  export WIN_USER
fi

[[ -z "$WIN_USER" || ! -f "$config_src" ]] && return

local config_dest="/mnt/c/Users/$WIN_USER/AppData/Roaming/neovide/config.toml"

if (( $+commands[neovide.exe] )); then
  export EDITOR="neovide.exe"
fi

# Fast bail: only sync if source is newer than dest (mtime check is one stat each)
if [[ "$config_src" -nt "$config_dest" ]]; then
  [[ -d "${config_dest:h}" ]] || mkdir -p "${config_dest:h}"
  local new_content="wsl = true"$'\n'"$(grep -v 'wsl =' "$config_src")"
  print -r -- "$new_content" > "$config_dest"
fi
