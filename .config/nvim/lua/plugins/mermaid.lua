return {
	"kevalin/mermaid.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function(_, opts)
		require("mermaid").setup(opts)

		-- mermaid.nvim always opens its control panel, with no option to disable it.
		require("mermaid.panel").open = function() end
	end,
}
