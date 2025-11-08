return {
	"necrom4/convy.nvim",
	-- dir = "~/Documents/Code/Personal/convy.nvim",
	cmd = { "Convy", "ConvySeparator" },
	opts = {
		notifications = true,
	},
	keys = {
		{
			"<leader>cc",
			":Convy<cr>",
			desc = "Convert (interactive selection)",
			mode = { "n", "v" },
			silent = true,
		},
	},
}
