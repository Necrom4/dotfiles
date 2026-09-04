return {
	"bullets-vim/bullets.nvim",
	ft = { "markdown", "text", "gitcommit", "scratch" },
	opts = {
		enabled_file_types = { "markdown", "text", "gitcommit", "scratch" },
		checkbox_markers = " .oOx",
	},
	keys = {
		{
			"<a-x>",
			"<cmd>ToggleCheckbox<cr>",
			ft = "markdown",
			silent = true,
		},
	},
}
