local tint_enabled = true

return {
	"levouh/tint.nvim",
	event = "VeryLazy",
	opts = {
		tint = -75,
	},
	keys = {
		{
			"<leader>ut",
			function()
				-- Toggle Tint
				require("tint").toggle()

				-- Update the state based on the current status
				tint_enabled = not tint_enabled

				-- Send the appropriate notification based on the state
				local status = tint_enabled and "Enabled" or "Disabled"
				local log_level = tint_enabled and vim.log.levels.INFO or vim.log.levels.WARN

				-- Notify the user about the state change
				vim.notify(status .. " **Tint**", log_level, { title = "Tint" })
			end,
			desc = "Toggle Window Tint",
			silent = true,
		},
	},
}
