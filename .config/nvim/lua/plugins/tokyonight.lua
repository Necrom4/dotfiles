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
			hl.BlinkCmpKindDBee = {
				fg = "#FCA7EA",
			}
			hl.BlinkCmpKindFile = {
				link = "BlinkCmpKindFolder",
			}
			hl.CursorLine = {
				bg = "none",
			}
			hl.FlashLabel = {
				fg = "#000000",
				bg = "#FF966C",
				bold = true,
			}
			hl.HauntAnnotation = {
				fg = "#FCA7EA",
				bg = "#383148",
				italic = true,
			}
			hl.TreesitterContext = {
				bg = "none",
			}
			hl.TreesitterContextBottom = {
				underline = true,
				sp = "#636DA6",
			}
			hl.UfoFoldedEllipsis = {
				link = "FoldColumn",
			}
			hl.WhichKeyNormal = {
				bg = "none",
			}
			hl.WinSeparator = {
				fg = "#C8D3F5",
			}
			hl["@markup.quote"] = {
				fg = "#787E93",
			}
			hl["@neorg.markup.verbatim"] = {
				bg = "#444A73",
				fg = "#82AAFF",
			}
		end,
	},
}
