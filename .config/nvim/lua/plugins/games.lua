return {
	{
		"Eandrju/cellular-automaton.nvim",
		cmd = "CellularAutomaton",
		config = function() end,
	},
	{
		"gisketch/triforce.nvim",
		dependencies = {
			"nvzone/volt",
		},
		config = function()
			require("triforce").setup({})
		end,
	},
	{
		"nvzone/typr",
		dependencies = "nvzone/volt",
		opts = {},
		cmd = { "Typr", "TyprStats" },
	},
}
