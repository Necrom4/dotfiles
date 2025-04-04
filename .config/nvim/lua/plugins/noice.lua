return {
	"folke/noice.nvim",
	opts = {
		lsp = {
			progress = { enabled = false },
		},
	},
	keys = {
		{
			"<leader>hN",
			function()
				require("noice").cmd("last")
			end,
			desc = "Last Notification",
		},
		{
			"<leader>hn",
			function()
				require("noice").cmd("history")
			end,
			desc = "Notifications",
		},
		{
			"<leader>un",
			function()
				require("noice").cmd("dismiss")
			end,
			desc = "Dismiss Notifications",
		},
		{
			"<leader>fn",
			function()
				require("noice").cmd("pick")
			end,
			desc = "Notifications",
		},
	},
}
