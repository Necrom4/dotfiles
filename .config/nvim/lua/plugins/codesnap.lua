return {
	"mistricky/codesnap.nvim",
	build = "make build_generator",
	keys = {
		{ "<leader>.s", "<esc><cmd>CodeSnap<cr>", mode = "x", desc = "Save snaped code into clipboard" },
		{ "<leader>.S", "<esc><cmd>CodeSnapSave<cr>", mode = "x", desc = "Save snaped code to ~/Desktop" },
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
