return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = {
		{
			"<leader>um",
			":RenderMarkdown buf_toggle<cr>",
			desc = "Toggle buffer Markdown Render",
			silent = true,
		},
	},
}
