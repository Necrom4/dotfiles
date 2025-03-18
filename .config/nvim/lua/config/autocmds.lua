-- AUTOCMDS --

-- PERSISTENT UNDO
vim.opt.undofile = true
local vimrc_undofile_augroup = vim.api.nvim_create_augroup("vimrc_undofile", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "/tmp/*",
	group = vimrc_undofile_augroup,
	command = "setlocal noundofile",
})

-- YANK TO NUMBER REGISTERS AND SYNC SYSTEM CLIPBOARD (WITH CLEANUP)
vim.api.nvim_create_autocmd({ "TextYankPost", "FocusGained" }, {
	callback = function()
		local clipboard_content = vim.fn.getreg("+") -- Get system clipboard content
		if clipboard_content and clipboard_content ~= "" then
			-- Remove carriage returns (^M) from the clipboard content
			clipboard_content = clipboard_content:gsub("\r", "")

			-- Shift registers "9" to "2" down
			for i = 9, 2, -1 do
				vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
			end
			-- Store cleaned clipboard content in register "1"
			vim.fn.setreg("1", clipboard_content)
		end
	end,
})

-- TOGGLE COLUMN NUMBER DISPLAY ON MODE SWITCH
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	callback = function()
		vim.opt_local.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		vim.opt_local.relativenumber = true
	end,
})

-- Set embedded templating languages
vim.cmd([[
  autocmd BufRead,BufNewFile *.tpl.yaml set filetype=helm
]])
