return {
	"folke/trouble.nvim",
	keys = {
		{ "<leader>xx", false },
		{ "<leader>xX", false },
		{ "<leader>xL", false },
		{ "<leader>xQ", false },
		{ "<leader>Xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>XX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
		{ "<leader>XL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
		{ "<leader>XQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
	},
}
