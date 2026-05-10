return {
	"paradoxical-dev/zeal.nvim",
	event = "VeryLazy",
	opts = {
		docsets_path = vim.fn.expand("$HOME/.local/share/Zeal/Zeal/docsets"),
		browser = "elinks",
	},
	keys = {
		{
			"<leader>sz",
			function()
				require("zeal").search()
			end,
			desc = "Search Zeal docs",
		},
	},
}
