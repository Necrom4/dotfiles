return {
	"OXY2DEV/patterns.nvim",
	events = "VeryLazy",
	opts = {
		keymaps = {
			explain_preview = {
				["<CR>"] = {
					callback = "mode_change",
				},
			},
		},
	},
}
