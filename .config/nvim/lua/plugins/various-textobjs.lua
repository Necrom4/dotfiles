return {
	"chrisgrieser/nvim-various-textobjs",
	opts = { keymaps = { useDefaults = false } },
	keys = {
		{ "ie", "<cmd>lua require('various-textobjs').subword('inner')<cr>", mode = { "o", "x" } },
		{ "ae", "<cmd>lua require('various-textobjs').subword('outer')<cr>", mode = { "o", "x" } },
	},
}
