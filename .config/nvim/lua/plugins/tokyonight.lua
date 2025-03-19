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
			hl.TreesitterContext = {
				bg = "none",
			}
			hl.TreesitterContextBottom = {
				underline = true,
				sp = "#636DA6",
			}
			hl.FlashLabel = {
				fg = "#000000",
				bg = "#4FD6BE",
				bold = true,
			}
		end,
	},
}
