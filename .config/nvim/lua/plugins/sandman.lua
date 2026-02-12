return {
	"stasfilin/nvim-sandman",
	-- disabled for now, sometimes blocks allowed plugins
	enabled = false,
	opts = {
		enabled = true,
		mode = "block_all",
		allow = {
			"blink-cmp-git",
			"blink.cmp",
			"camouflage.nvim",
			"gitsigns.nvim",
			"lazy.nvim",
			"mason-lspconfig.nvim",
			"mason.nvim",
			"snacks.nvim",
			"thanks.nvim",
			-- to block whenever feature to ignore their notifications is available
			"conform.nvim",
			"haunt.nvim",
			"plenary.nvim",
		},
	},
}
