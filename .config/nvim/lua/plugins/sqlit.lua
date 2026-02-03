return {
	"Maxteabag/sqlit.nvim",
	opts = {
		theme = "Tokyonight-moon",
	},
	cmd = "Sqlit",
	keys = {
		{
			"<leader>Ds",
			function()
				require("sqlit").open()
			end,
			desc = "Database",
		},
	},
}
