local utils = require("utils.general")
local system_type = utils.system_type()

if vim.g.neovide then
	-- Window
	vim.g.neovide_opacity = 0.85
	vim.g.neovide_window_blurred = true
	-- Floating windows
	vim.g.neovide_floating_shadow = false
	-- Text
	if system_type == "darwin" then
		vim.o.guifont = "CommitMono Nerd Font Mono,LegacyComputing:h16"
	else
		vim.o.guifont = "CommitMono Nerd Font Mono,LegacyComputing:h10"
	end
	vim.opt.linespace = 1

	-- KEYMAPS
	vim.g.neovide_input_macos_option_key_is_meta = "only_left"
	-- Copy paste
	local c_c = "<C-c>"
	local c_v = "<C-v>"

	if system_type == "darwin" then
		vim.g.neovide_input_use_logo = true
		c_c = "<D-c>"
		c_v = "<D-v>"
	end

	local function paste_in_prompt()
		local keys = vim.fn.getreg("+")
		keys = vim.fn.escape(keys, [["\]])
		local termcodes = vim.api.nvim_replace_termcodes(keys, true, true, true)
		vim.api.nvim_feedkeys(termcodes, "c", false)
	end

	vim.keymap.set("n", c_v, '"+p', { noremap = true, silent = true })
	vim.keymap.set("i", c_v, '<ESC>"+pli', { noremap = true, silent = true })
	vim.keymap.set("c", c_v, paste_in_prompt, { noremap = true, silent = true })
	vim.keymap.set("t", c_v, paste_in_prompt, { noremap = true, silent = true })
	vim.keymap.set("v", c_c, '"+y', { noremap = true, silent = true })
end
