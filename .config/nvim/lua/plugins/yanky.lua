return {
	"gbprod/yanky.nvim",
	keys = {
		{ "<leader>p", mode = { "n", "x" }, false },
		{ ">p", false },
		{ "<p", false },
		{ ">P", false },
		{ "<P", false },
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
		{ "g>p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
		{ "g<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
		{ "g>P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
		{ "g<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
	},
}
