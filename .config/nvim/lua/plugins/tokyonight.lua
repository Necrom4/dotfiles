return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		style = "moon",
		transparent = true,
		styles = {
			floats = "transparent",
		},
		lualine_bold = true,
		on_highlights = function(hl, c)
			hl.CursorLine = {
				bg = "none",
			}
			hl.WinSeparator = {
				fg = "#C8D3F5",
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
			hl["@neorg.markup.verbatim"] = {
				bg = "#444A73",
				fg = "#82AAFF",
			}
		end,
	},
}
