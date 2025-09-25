return {
	"folke/tokyonight.nvim",
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
				bg = "#FF966C",
				bold = true,
			}
			hl.BlinkCmpKindFile = {
				link = "BlinkCmpKindFolder",
			}
			hl.BlinkCmpKindDBee = {
				fg = "#FCA7EA",
			}
			hl["@neorg.markup.verbatim"] = {
				bg = "#444A73",
				fg = "#82AAFF",
			}
		end,
	},
}
