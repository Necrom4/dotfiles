return {
	{
		"rcarriga/nvim-notify",
		lazy = true,
		opts = {},
	},
	{
		"folke/noice.nvim",
		dependencies = { "rcarriga/nvim-notify" },
	},
}
