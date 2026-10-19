return {
	"esmuellert/codediff.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		explorer = {
			view_mode = "tree",
		},
		history = {
			view_mode = "tree",
		},
		keymaps = {
			explorer = {
				hover = "gK",
			},
			view = {
				next_hunk = "]g",
				prev_hunk = "[g",
			},
		},
	},
	cmd = "CodeDiff",
	keys = {
		{ "<leader>df", "<cmd>CodeDiff<cr>", mode = "n", desc = "Files", silent = true },
		{ "<leader>dh", "<cmd>CodeDiff history %<cr>", mode = "n", desc = "File history", silent = true },
		{ "<leader>dh", ":'<,'>CodeDiff history<cr>", mode = "v", desc = "Range history", silent = true },
	},
}
