return {
	{
		"echasnovski/mini.animate",
		cond = vim.g.neovide == nil,
		opts = {
			cursor = {
				enable = false,
			},
			scroll = {
				enable = false,
			},
		},
	},
	{
		"dstein64/vim-win",
		keys = {
			{ "<c-w><enter>", ":Win<CR>", desc = "Open Win Manager", silent = true },
		},
	},
}
