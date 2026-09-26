return {
	"uga-rosa/ccc.nvim",
	opts = {
		highlighter = {
			auto_enable = false,
			lsp = false,
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
