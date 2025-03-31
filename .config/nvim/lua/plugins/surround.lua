return {
	"kylechui/nvim-surround",
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	opts = {
		keymaps = {
			insert = "<C-g>s",
			insert_line = "<C-g>S",
			normal = "gsa",
			normal_cur = "gsaV",
			normal_line = "gsAm",
			normal_cur_line = "gsAl",
			visual = "gsa",
			visual_line = "gsA",
			delete = "gsd",
			change = "gsr",
			change_line = "gsR",
		},
	},
}
