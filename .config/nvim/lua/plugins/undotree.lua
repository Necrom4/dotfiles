return {
	"XXiaoA/atone.nvim",
	cmd = "Atone",
	keys = {
		{ "<leader>du", "<cmd>Atone toggle<cr>", desc = "Toggle undo tree" },
	},
	opts = {
		auto_attach = { enabled = true },
		diff_cur_node = { enabled = true },
		marks = { persist = true },
	},
}
