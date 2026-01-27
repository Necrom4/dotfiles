local config_src="$HOME/.config/neovide/config.toml"
local win_user=$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r')

[[ -z "$win_user" || ! -f "$config_src" ]] && return

local config_dest="/mnt/c/Users/$win_user/AppData/Roaming/neovide/config.toml"

if (( $+commands[neovide.exe] )); then
  export EDITOR="neovide.exe"
fi

[[ -d "${config_dest:h}" ]] || mkdir -p "${config_dest:h}"

# Read source, filter out existing wsl lines, and prepend 'wsl = true'
# We use a temporary string to avoid corrupting the file if the pipe fails
local new_content="wsl = true\n$(grep -v 'wsl =' "$config_src")"

# Only write if the content is actually different to prevent unnecessary disk writes
if [[ "$new_content" != "$(< $config_dest 2>/dev/null)" ]]; then
  echo -e "$new_content" > "$config_dest"
fi
