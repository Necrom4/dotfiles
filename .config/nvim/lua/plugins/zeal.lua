return {
	"paradoxical-dev/zeal.nvim",
	event = "VeryLazy",
	opts = {
		docsets_path = vim.fn.expand("$HOME/.local/share/Zeal/Zeal/docsets"),
		-- Neovim jobs cannot use the interactive Zsh function; use its launcher.
		browser = { "python3", vim.fn.expand("$HOME/.config/elinks/clipboard"), "open" },
	},
	keys = {
		{
			"<leader>sz",
			function()
				require("zeal").search()
			end,
			desc = "Search Zeal docs",
		},
	},
}
