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
	{
		"iamcco/markdown-preview.nvim", -- markdown preview plugin for (neo)vim
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = "markdown",
		cond = function()
			return vim.env.SSH_CONNECTION == nil
		end,
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},
}
