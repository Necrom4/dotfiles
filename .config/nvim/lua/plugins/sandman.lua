return {
	"stasfilin/nvim-sandman",
	opts = {
		enabled = true,
		mode = "block_all",
		env_block = false,
		allow = {
			"blink-cmp-git",
			"camouflage.nvim",
			"conform.nvim",
			"lazy.nvim",
			"mason-lspconfig.nvim",
			"mason.nvim",
			"snacks.nvim",
			"thanks.nvim",
			"plenary.nvim",
		},
		ignore_notifications = {
			"gitsigns.nvim",
			"haunt.nvim",
			"mason-lspconfig.nvim",
			"mason.nvim",
		},
	},
}
