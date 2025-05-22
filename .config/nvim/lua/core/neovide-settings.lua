if vim.g.neovide then
	-- Window settings
	vim.g.neovide_opacity = 0.75
	vim.g.neovide_window_blurred = true

	-- Copy paste
	vim.g.neovide_input_use_logo = true
	vim.keymap.set("n", "<D-v>", '"+p', { noremap = true, silent = true })
	vim.keymap.set("i", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	vim.keymap.set("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
	vim.keymap.set("v", "<D-c>", '"+y<CR>', { noremap = true, silent = true })
end
