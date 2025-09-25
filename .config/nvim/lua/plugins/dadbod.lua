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
					{ key = "R", mode = "n", action = "refresh" },
					{ key = "z", mode = "n", action = "toggle" },
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
					{ key = "K", mode = "", action = "page_last" },
					{ key = "J", mode = "", action = "page_first" },
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
