return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		transparent = true,
		styles = {
			floats = "transparent",
		},
		lualine_bold = true,
		on_highlights = function(hl, c)
			hl.WinSeparator = {
				fg = "#C0CAF5",
			}
			hl.WhichKeyNormal = {
				bg = "none",
			}
		end,
	},
}
