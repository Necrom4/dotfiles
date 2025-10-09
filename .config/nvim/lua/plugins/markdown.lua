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
			},
			heading = {
				icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
			},
		},
	},
}
