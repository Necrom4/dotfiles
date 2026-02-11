return {
	"zeybek/camouflage.nvim",
	event = "VeryLazy",
	opts = {
		pwned = {
			enabled = false,
		},
	},
	keys = {
		{ "<leader>uct", "<cmd>CamouflageToggle<cr>", desc = "Toggle Camouflage" },
		{ "<leader>ucr", "<cmd>CamouflageReveal<cr>", desc = "Reveal Line" },
		{ "<leader>ucy", "<cmd>CamouflageYank<cr>", desc = "Yank Value" },
		{ "<leader>ucf", "<cmd>CamouflageFollowCursor<cr>", desc = "Follow Cursor" },
	},
}
