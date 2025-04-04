return {
	"folke/which-key.nvim",
	opts = {
		spec = {
			{
				mode = { "n", "v" },
				{ "<leader>d", group = "diff", icon = { icon = " ", color = "red" } },
				{ "<leader>e", group = "explorer", icon = { icon = " ", color = "yellow" } },
				{ "<leader>ee", name = "Root Dir", icon = { icon = " ", color = "yellow" } },
				{ "<leader>eE", name = "cwd", icon = { icon = " ", color = "yellow" } },
				{ "<leader>ef", name = "Buffer Dir (floating)", icon = { icon = " ", color = "yellow" } },
				{ "<leader>h", group = "history", icon = { icon = " ", color = "green" } },
				{ "<leader>n", group = "notes", icon = { icon = "󰠮 ", color = "blue" } },
				{ "<leader>r", group = "replace", icon = { icon = "󰛔 ", color = "red" } },
				{ "<leader>rb", group = "replace multi-buffer", icon = { icon = "󰛔 ", color = "red" } },
				{ "<leader>rv", group = "replace selection", icon = { icon = "󰛔 ", color = "red" } },
				{ "<leader>t", group = "terminal", icon = { icon = " ", color = "green" } },
				{ "<leader>tf", name = "Buffer Dir (floating)", icon = { icon = " ", color = "green" } },
				{ "<leader>tt", name = "Root Dir", icon = { icon = " ", color = "green" } },
				{ "<leader>tT", name = "cwd", icon = { icon = " ", color = "green" } },
				{ "gs", group = "surround", icon = { icon = "󰅲 ", color = "yellow" } },
			},
		},
		plugins = {
			registers = false,
		},
	},
}
