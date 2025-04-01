return {
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
				{ "gs", group = "surround", icon = { icon = "󰅲 ", color = "yellow" } },
			},
		},
		plugins = {
			registers = false,
		},
	},
}
