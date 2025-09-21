return {
	"uga-rosa/ccc.nvim",
	event = { "VeryLazy" },
	opts = {
		highlighter = {
			auto_enable = false,
			lsp = true,
		},
	},
	cmd = {
		"CccConvert",
		"CccHighlighterToggle",
		"CccPick",
	},
	keys = {
		{ "<leader>cC", "<cmd>CccPick<cr>", desc = "Color Picker", silent = true },
	},
}
