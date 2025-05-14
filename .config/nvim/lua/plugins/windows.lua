return {
	{
		"echasnovski/mini.animate",
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
	{
		"nvim-zh/colorful-winsep.nvim",
		opts = {
			hi = {
				bg = "none",
				fg = "#86E1FC",
			},
			symbols = { "─", "│", "┌", "┐", "└", "┘" },
			only_line_seq = false,
		},
		event = { "WinLeave" },
	},
}
