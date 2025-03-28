return {
	{ "folke/lazy.nvim", version = false },
	{ "LazyVim/LazyVim", version = false },
	{
		"akinsho/bufferline.nvim",
		opts = {
			options = {
				mode = "tabs",
			},
		},
	},
	{
		"catppuccin/nvim",
		enabled = false,
	},
	{
		"folke/noice.nvim",
		opts = {
			lsp = {
				progress = { enabled = false },
			},
		},
		keys = {
			{ "<leader>n", "", desc = "+noice" },
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>nl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>nh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>na",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>nd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			{
				"<leader>nt",
				function()
					require("noice").cmd("pick")
				end,
				desc = "Noice Picker (Telescope/FzfLua)",
			},
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Forward",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Backward",
				mode = { "i", "n", "s" },
			},
		},
	},
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader>d", group = "diff", icon = { icon = " ", color = "red" } },
					{ "<leader>r", group = "replace", icon = { icon = "󰛔 ", color = "red" } },
					{ "<leader>rb", group = "replace multi-buffer", icon = { icon = "󰛔 ", color = "red" } },
					{ "<leader>rv", group = "replace selection", icon = { icon = "󰛔 ", color = "red" } },
					{ "<leader>t", group = "terminal", icon = { icon = " ", color = "green" } },
					-- { "ys", group = "surround" },
				},
			},
		},
	},
}
