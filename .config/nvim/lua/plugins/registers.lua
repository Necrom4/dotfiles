return {
	"tversteeg/registers.nvim",
	cmd = "Registers",
	opts = {
		show = '"*+0123456789abcdefghijklmnopqrstuvwxyz:%#_=-/.',
		show_empty = false,
		symbols = {
			register_type_charwise = "",
			register_type_linewise = "",
			register_type_blockwise = "󰹹",
		},
		window = {
			border = "rounded",
		},
	},
	keys = {
		{ '"', mode = { "n", "v" } },
		{ "<C-R>", mode = "i" },
	},
}
