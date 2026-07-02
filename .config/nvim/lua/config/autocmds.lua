local utils = require("utils.general")

-- Persistent undo
vim.opt.undofile = true
local vimrc_undofile_augroup = vim.api.nvim_create_augroup("vimrc_undofile", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "/tmp/*",
	group = vimrc_undofile_augroup,
	command = "setlocal noundofile",
})

-- Custom Treesitter parsers
vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		require("nvim-treesitter.parsers").lua_patterns = {
			install_info = {
				url = "https://github.com/OXY2DEV/tree-sitter-lua_patterns",
			},
		}
	end,
})
