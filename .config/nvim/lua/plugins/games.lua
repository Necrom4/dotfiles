return {
	{
		"alec-gibson/nvim-tetris",
		cmd = "Tetris",
		config = function() end,
	},
	{
		"Eandrju/cellular-automaton.nvim",
		cmd = "CellularAutomaton",
		config = function() end,
	},
	{
		"jim-fx/sudoku.nvim",
		cmd = "Sudoku",
		config = function()
			require("sudoku").setup({})
		end,
	},
	{
		"seandewar/killersheep.nvim",
		cmd = "KillKillKill",
		opts = {},
	},
	{
		"seandewar/nvimesweeper",
		cmd = "Nvimesweeper",
		opts = {},
	},
}
