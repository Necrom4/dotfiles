return {
	"tpope/vim-abolish",
	init = function()
		vim.g.abolish_no_mappings = true
	end,
	cmd = { "Abolish", "Subvert", "S" },
}
