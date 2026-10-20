return {
	"petertriho/nvim-scrollbar",
	branch = "refactor/v2", -- drop this line once v2 lands on main (2026-11-16)
	dependencies = { "lewis6991/gitsigns.nvim" },
	event = { "BufNewFile", "BufReadPost" },
	opts = {
		scrollbar = {
			thumb = {
				highlight = "Cursor",
			},
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
		providers = { search = true, gitsigns = true },
		exclude = {
			buftypes = {
				"terminal",
				"nofile",
				"prompt",
				"quickfix",
			},
		},
	},
}
