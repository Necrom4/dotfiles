-- EXECUTE TERM CMD
local function term_cmd(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+$", "")
end

-- GET OS
local function get_os()
	local uname = term_cmd("uname")
	if uname == "Linux" then
		local version = term_cmd("cat /proc/version")
		if version:match("Microsoft") or version:match("WSL") then
			return "WSL"
		end
	end
	return uname
end

if vim.g.neovide then
	-- Window settings
	vim.g.neovide_opacity = 0.75
	vim.g.neovide_window_blurred = true
	vim.g.neovide_input_macos_option_key_is_meta = "only_left"
	if get_os() == "Darwin" then
		vim.o.guifont = "CommitMono Nerd Font Mono:h16"
	else
		vim.o.guifont = "CommitMono Nerd Font Mono:h10"
	end
	vim.opt.linespace = 1

	-- Copy paste
	vim.g.neovide_input_use_logo = true
	vim.keymap.set("n", "<D-v>", '"+p', { noremap = true, silent = true })
	vim.keymap.set("i", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	vim.keymap.set("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	vim.keymap.set("v", "<D-c>", '"+y<CR>', { noremap = true, silent = true })
end
