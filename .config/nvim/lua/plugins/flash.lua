return {
	"folke/flash.nvim",
	opts = {
		highlight = { groups = { current = "FlashMatch" } },
	},
	keys = {
		{
			"S",
			mode = { "n", "o", "x" },
			function()
				require("flash").treesitter({
					actions = {
						["]"] = "next",
						["["] = "prev",
					},
				})
			end,
			desc = "Flash Treesitter",
		},
	},
}
