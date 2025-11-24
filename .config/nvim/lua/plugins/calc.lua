return {
	{
		"necrom4/calcium.nvim",
		-- dir = "/Users/diogopombeiro/Code/Personal/calcium.nvim",
		opts = {},
		cmd = { "Calcium" },
		keys = {
			{ "<leader>cca", ":Calcium append<CR>", mode = { "n", "v" }, desc = "Calculate (append)" },
			{ "<leader>ccr", ":Calcium replace<CR>", mode = { "n", "v" }, desc = "Calculate (replace)" },
		},
	},
	{

		"necrom4/convy.nvim",
		-- dir = "~/Documents/Code/Personal/convy.nvim",
		cmd = { "Convy", "ConvySeparator" },
		opts = {
			notifications = true,
		},
		keys = {
			{
				"<leader>ccc",
				":Convy<cr>",
				desc = "Convert (interactive selection)",
				mode = { "n", "v" },
				silent = true,
			},
		},
	},
}
