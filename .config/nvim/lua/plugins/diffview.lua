return {
	"sindrets/diffview.nvim",
	opts = {},
	keys = {
		{ "<leader>di", ":DiffviewOpen<CR>", mode = "n", desc = "Index", silent = true },
		{ "<leader>dh", ":DiffviewFileHistory %<CR>", mode = "n", desc = "History", silent = true },
		{
			"<leader>dh",
			":'<,'>DiffviewFileHistory<CR>",
			mode = "x",
			desc = "History",
			silent = true,
		},
		{ "<leader>dq", ":DiffviewClose<CR>", desc = "Close Diffview", silent = true },
	},
}
