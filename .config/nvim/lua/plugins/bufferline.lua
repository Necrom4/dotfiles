return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	keys = {
		-- LazyVim's buffer-only actions are misleading in tabpage mode.
		{ "<leader>bp", false },
		{ "<leader>bP", false },
		{ "<leader>br", false },
		{ "<leader>bl", false },
		{ "<leader>bj", false },
	},
	opts = {
		options = {
			mode = "tabs",
			diagnostics = false,
		},
	},
}
