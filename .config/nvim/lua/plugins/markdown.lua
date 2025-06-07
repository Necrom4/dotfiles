return {
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
