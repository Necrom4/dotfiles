return {
	"MagicDuck/grug-far.nvim",
	opts = {},
	cmd = {
		"GrugFarWithin",
	},
	keys = {
		{
			"<leader>sr",
			function()
				local grug = require("grug-far")
				local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
				local buf_path = vim.api.nvim_buf_get_name(0)
				local rel_path = (buf_path ~= "" and vim.fn.filereadable(buf_path) == 1)
						and vim.fn.fnamemodify(buf_path, ":.")
					or nil
				grug.open({
					transient = true,
					prefills = {
						filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						paths = rel_path and rel_path ~= "" and rel_path or nil,
					},
				})
			end,
			mode = { "n", "v" },
			desc = "Search and Replace",
			silent = true,
		},
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
