return {
	"mistricky/codesnap.nvim",
	build = "make",
	keys = {
		{ "<leader>csc", "<esc><cmd>CodeSnap<cr>", mode = "x", desc = "To clipboard" },
		{ "<leader>css", "<esc><cmd>CodeSnapSave<cr>", mode = "x", desc = "Save to ~/Desktop" },
		{ "<leader>csvc", "<esc><cmd>CodeSnapHighlight<cr>", mode = "x", desc = "To clipboard with highlight" },
		{
			"<leader>csvs",
			"<esc><cmd>CodeSnapSaveHighlight<cr>",
			mode = "x",
			desc = "Save to ~/Desktop with highlight",
		},
		{ "<leader>csa", "<esc><cmd>CodeSnapASCII<cr>", mode = "x", desc = "Copy as text" },
	},
	opts = {
		mac_window_bar = false,
		code_font_family = "CommitMono Nerd Font Mono",
		watermark = "Necrom",
		bg_theme = "default",
		breadcrumbs_separator = "/",
		has_breadcrumbs = true,
		has_line_number = true,
		show_workspace = true,
		bg_padding = 0,
		save_path = "~/Desktop",
	},
}
