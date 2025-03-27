return {
	"crnvl96/lazydocker.nvim",
	cmd = { "LazyDocker" },
	keys = {
		{ "<leader>D", "<cmd>LazyDocker<cr>", mode = "n", desc = "Open Lazydocker" },
	},
	opts = {
		popup_window = {
			relative = "editor",
		},
	},
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
}
