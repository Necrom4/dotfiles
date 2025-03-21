return {
	"levouh/tint.nvim",
	event = "VeryLazy",
	opts = {
		tint = -75,
	},
	keys = {
		{ "<leader>ut", ":lua require('tint').toggle()<CR>", desc = "Toggle Tint", silent = true },
	},
}
