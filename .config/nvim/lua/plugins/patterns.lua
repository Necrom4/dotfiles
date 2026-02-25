return {
	"OXY2DEV/patterns.nvim",
	opts = {
		keymaps = {
			explain_preview = {
				["<CR>"] = {
					callback = "mode_change",
				},
			},
		},
	},
	cmd = "Patterns",
}
