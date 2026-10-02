return {
	"kevalin/mermaid.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("mermaid").setup()
	end,
}
