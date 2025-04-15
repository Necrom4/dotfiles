return {
	"gbprod/yanky.nvim",
	keys = {
		{
			"<leader>hy",
			function()
				if LazyVim.pick.picker.name == "telescope" then
					require("telescope").extensions.yank_history.yank_history({})
				else
					vim.cmd([[YankyRingHistory]])
				end
			end,
			mode = { "n", "x" },
			desc = "Yank History",
		},
	},
}
