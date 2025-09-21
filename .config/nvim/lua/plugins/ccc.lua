local ccc_highlighter_enabled = true

return {
	"uga-rosa/ccc.nvim",
	event = { "VeryLazy" },
	opts = {
		highlighter = {
			auto_enable = true,
			lsp = true,
		},
	},
	cmd = {
		"CccConvert",
		"CccHighlighterToggle",
		"CccPick",
	},
	keys = {
		{ "<leader>cC", "<cmd>CccPick<cr>", desc = "Color Picker", silent = true },
	},
	config = function(_, opts)
		local ccc = require("ccc")
		ccc.setup(opts)

		Snacks.toggle
			.new({
				id = "ccc_highlighter",
				name = "Color Highlighter",
				get = function()
					return ccc_highlighter_enabled
				end,
				set = function()
					ccc_highlighter_enabled = not ccc_highlighter_enabled
					vim.cmd("CccHighlighterToggle")
				end,
				icon = {
					enabled = " ",
					disabled = " ",
				},
				color = {
					enabled = "green",
					disabled = "yellow",
				},
				wk_desc = {
					enabled = "Disable ",
					disabled = "Enable ",
				},
			})
			:map("<leader>uC")
	end,
}
