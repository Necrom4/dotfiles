return {
	{
		"Eandrju/cellular-automaton.nvim",
		cmd = "CellularAutomaton",
		config = function() end,
	},
	{
		"seandewar/actually-doom.nvim",
		cmd = "Doom",
		opts = {},
	},
	{
		"seandewar/killersheep.nvim",
		cmd = "KillKillKill",
		opts = {},
	},
	{
		"alec-gibson/nvim-tetris",
		cmd = "Tetris",
		config = function() end,
	},
	{
		"NStefan002/speedtyper.nvim",
		branch = "v2",
		cmd = "Speedtyper",
	},
	{
		"jim-fx/sudoku.nvim",
		cmd = "Sudoku",
		config = function()
			require("sudoku").setup({})
		end,
	},
	{
		"seandewar/nvimesweeper",
		cmd = "Nvimesweeper",
		opts = {},
	},
}
