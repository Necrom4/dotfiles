return {
	"max397574/better-escape.nvim",
	opts = {
		timeout = vim.o.timeoutlen,
		default_mappings = true,
		mappings = {
			i = {
				j = {
					k = "<Esc>",
				},
			},
			c = {
				j = {
					k = "<C-c>",
				},
			},
			t = {
				j = {
					k = "<C-\\><C-n>",
				},
			},
			s = {
				j = {
					k = "<Esc>",
				},
			},
		},
	},
}
