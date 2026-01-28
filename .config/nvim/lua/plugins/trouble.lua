return {
	"folke/trouble.nvim",
	keys = {
		{ "<leader>xx", false },
		{ "<leader>xX", false },
		{ "<leader>xL", false },
		{ "<leader>xQ", false },
		{ "<leader>Qd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
		{ "<leader>QD", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
		{ "<leader>QL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
		{ "<leader>QQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
	},
}
