return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		opts = function()
			local tsc = require("treesitter-context")
			Snacks.toggle({
				name = "Treesitter Context",
				get = tsc.enabled,
				set = function(state)
					if state then
						tsc.enable()
					else
						tsc.disable()
					end
				end,
			}):map("<leader>uc")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			incremental_selection = {
				enable = true,
				keymaps = {
					node_decremental = "v",
					node_incremental = "V",
				},
			},
		},
	},
}
