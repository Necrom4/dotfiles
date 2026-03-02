return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			checkbox = {
				enabled = true,
				right_pad = 1,
				unchecked = {
					icon = "    󰄱",
					highlight = "RenderMarkdownUnchecked",
					scope_highlight = nil,
				},
				checked = {
					icon = "    󰡖",
					highlight = "RenderMarkdownChecked",
					scope_highlight = nil,
				},
				custom = {
					todo = {
						rendered = "    󰥔",
					},
					important = {
						raw = "[!]",
						rendered = "    ",
						highlight = "Error",
					},
					delete = {
						raw = "[_]",
						rendered = "    ",
						highlight = "NonText",
					},
					pause = {
						raw = "[=]",
						rendered = "    ",
						highlight = "String",
					},
					redo = {
						raw = "[+]",
						rendered = "    ",
						highlight = "@keyword",
					},
					unsure = {
						raw = "[?]",
						rendered = "    ",
						highlight = "@boolean",
					},
				},
			},
			heading = {
				icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
			},
		},
	},
}
