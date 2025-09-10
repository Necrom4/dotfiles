return {
	{
		"echasnovski/mini.animate",
		cond = vim.g.neovide == nil,
		opts = {
			cursor = {
				enable = false,
			},
			scroll = {
				enable = false,
			},
		},
	},
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		version = "2.*",
		opts = {
			hint = "floating-big-letter",
			selection_chars = "JHKLFDSA",
			show_prompt = false,
			filter_rules = {
				include_current_win = false,
				bo = {
					filetype = { "NvimTree", "neo-tree", "notify" },
				},
			},
		},
		keys = {
			{
				"<C-w>n",
				function()
					local picked_window_id = require("window-picker").pick_window()
					if picked_window_id then
						vim.api.nvim_set_current_win(picked_window_id)
					end
				end,
				desc = "Navigate",
			},
		},
	},
	{
		"sindrets/winshift.nvim",
		opts = {
			window_picker = function()
				return require("window-picker").pick_window()
			end,
		},
		keys = {
			{ "<c-w><cr>", "<cmd>WinShift<cr>", desc = "Tiling manager", silent = true },
			{ "<c-w>S", "<cmd>WinShift swap<cr>", desc = "Swap", silent = true },
		},
	},
}
