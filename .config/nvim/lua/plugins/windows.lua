return {
	{
		"nvim-mini/mini.animate",
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
		"nvim-zh/colorful-winsep.nvim",
		event = { "WinLeave" },
		opts = {
			border = "rounded",
			animate = {
				enabled = "progressive",
				progressive = {
					vertical_delay = 20,
					horizontal_delay = 2,
				},
			},
			indicator_for_2wins = {
				symbols = {
					start_left = "󰄾",
					end_left = "",
					start_down = "",
					end_down = "",
					start_up = "",
					end_up = "",
					start_right = "",
					end_right = "",
				},
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
