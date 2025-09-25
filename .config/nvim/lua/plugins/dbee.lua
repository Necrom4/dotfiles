return {
	"kndndrj/nvim-dbee",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	build = function()
		require("dbee").install()
	end,
	config = function()
		require("dbee").setup({
			drawer = {
				disable_help = true,
				mappings = {
					{ key = "r", mode = "n", action = "refresh" },
					{ key = "<CR>", mode = "n", action = "action_1" },
					{ key = "cw", mode = "n", action = "action_2" },
					{ key = "dd", mode = "n", action = "action_3" },
					{ key = "z", mode = "n", action = "toggle" },
					{ key = "<CR>", mode = "n", action = "menu_confirm" },
					{ key = "y", mode = "n", action = "menu_yank" },
					{ key = "<Esc>", mode = "n", action = "menu_close" },
					{ key = "q", mode = "n", action = "menu_close" },
				},
				candies = {
					note = {
						icon = "",
						icon_highlight = "Character",
						text_highlight = "",
					},
					schema = {
						icon = "פּ",
						icon_highlight = "Removed",
						text_highlight = "",
					},
					help = {
						icon = "󰘥",
						icon_highlight = "Title",
						text_highlight = "Title",
					},
					source = {
						icon = "",
						icon_highlight = "MoreMsg",
						text_highlight = "MoreMsg",
					},
				},
			},
			result = {
				mappings = {
					{ key = "L", mode = "", action = "page_next" },
					{ key = "H", mode = "", action = "page_prev" },
					{ key = "K", mode = "", action = "page_last" },
					{ key = "J", mode = "", action = "page_first" },
					{ key = "yaj", mode = "n", action = "yank_current_json" },
					{ key = "yaj", mode = "v", action = "yank_selection_json" },
					{ key = "yaJ", mode = "", action = "yank_all_json" },
					{ key = "yac", mode = "n", action = "yank_current_csv" },
					{ key = "yac", mode = "v", action = "yank_selection_csv" },
					{ key = "yaC", mode = "", action = "yank_all_csv" },
					{ key = "<C-c>", mode = "", action = "cancel_call" },
				},
			},
			editor = {
				mappings = {
					{ key = "<cr>", mode = "v", action = "run_selection" },
					{ key = "<cr>", mode = "n", action = "run_file" },
					{ key = "<cr>", mode = "n", action = "run_under_cursor" },
				},
			},
		})
	end,
	opts = function(_, opts)
		local dbee = require("dbee")

		Snacks.toggle({
			id = "dbee",
			name = "DBee",
			get = function()
				return dbee.is_open()
			end,
			set = function()
				dbee.toggle()
			end,
			icon = {
				enabled = "󰆼",
				disabled = "󰆼 ",
			},
			color = {
				enabled = "green",
				disabled = "yellow",
			},
			wk_desc = {
				enabled = "Close ",
				disabled = "Open ",
			},
		}):map("<leader>D")

		return opts
	end,
	cmd = "Dbee",
	keys = {
		{
			"D",
			function()
				require("dbee").toggle()
			end,
			mode = { "n" },
			silent = true,
			desc = "Open DBee",
		},
	},
}
