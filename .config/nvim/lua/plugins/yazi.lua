return {
	"mikavilpas/yazi.nvim",
	opts = {
		floating_window_scaling_factor = 0.7,
		yazi_floating_window_winblend = 20,
	},
	keys = {
		{ "<leader>xf", mode = { "n", "v" }, "<cmd>Yazi toggle<cr>", desc = "Floating" },
	},
}
