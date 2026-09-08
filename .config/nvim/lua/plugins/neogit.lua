return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"esmuellert/codediff.nvim",
		"folke/snacks.nvim",
	},
	opts = {
		graph_style = "unicode",
		process_spinner = true,
		signs = {
			hunk = { "", "" },
			item = { "", "" },
			section = { "", "" },
		},
		treesitter_diff_highlight = true,
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
	},
}
