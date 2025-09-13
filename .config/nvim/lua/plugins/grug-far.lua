return {
	"MagicDuck/grug-far.nvim",
	opts = {},
	cmd = {
		"GrugFarWithin",
	},
	keys = {
		{
			"<leader>sR",
			function()
				local grug = require("grug-far")
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
				grug.open({
					transient = true,
					prefills = {
						filesFilter = ext and ext ~= "" and "*." .. ext or nil,
					},
					visualSelectionUsage = "operate-within-range",
				})
			end,
			mode = { "v" },
			desc = "Search and Replace (within)",
			silent = true,
		},
	},
}
