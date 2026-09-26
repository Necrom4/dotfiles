return {
	"petertriho/nvim-scrollbar",
	dependencies = { "kevinhwang91/nvim-hlslens", "lewis6991/gitsigns.nvim" },
	event = { "BufNewFile", "BufReadPost" },
	opts = {
		handle = {
			highlight = "Cursor",
		},
		marks = {
			Cursor = { text = "▒" },
			Search = { text = { "", "󰇙" }, highlight = "ScrollBarSearch" },
			Error = { text = { "━", "═" }, highlight = "ScrollBarError" },
			Warn = { text = { "━", "═" }, highlight = "ScrollBarWarn" },
			Info = { text = { "━", "═" }, highlight = "ScrollBarInfo" },
			Hint = { text = { "━", "═" }, highlight = "ScrollBarHint" },
			Misc = { text = { "━", "═" }, highlight = "ScrollBarMisc" },
			GitAdd = { text = "┃", highlight = "ScrollbarGitAdd" },
			GitChange = { text = "┃", highlight = "ScrollbarGitChange" },
			GitDelete = { highlight = "ScrollbarGitDelete" },
		},
		handlers = { search = true, gitsigns = true },
		excluded_buftypes = {
			"terminal",
			"nofile",
			"prompt",
			"quickfix",
		},
	},
}
