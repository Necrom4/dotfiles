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
			{ "<leader>N", "", desc = "+noice" },
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>Nl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>Nh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>Na",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>Nd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			{
				"<leader>Nt",
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
					-- { "<leader>c", group = "code" },
					{ "<leader>d", group = "diff", icon = { icon = " ", color = "red" } },
					{ "<leader>q", group = "quit/session" },
					-- { "<leader>/", group = "search" },
					{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
					-- { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
					-- { "ys", group = "surround" },
				},
			},
		},
	},
}
