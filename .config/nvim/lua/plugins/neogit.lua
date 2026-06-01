return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"esmuellert/codediff.nvim",
		"folke/snacks.nvim",
	},
	opts = {
		treesitter_diff_highlight = true,
		graph_style = "unicode",
		process_spinner = true,
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>g<cr>", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
	},
}
