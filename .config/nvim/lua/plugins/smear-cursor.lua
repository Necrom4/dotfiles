local smear_enabled = true

return {
	"sphamba/smear-cursor.nvim",
	event = "VeryLazy",
	opts = {
		cursor_color = "none",
		legacy_computing_symbols_support = true,
	},
	keys = {
		{
			"<leader>uC",
			function()
				-- Toggle SmearCursor
				vim.cmd("SmearCursorToggle")

				-- Update the state based on the current status
				smear_enabled = not smear_enabled
				-- Send the appropriate notification based on the state
				local status = smear_enabled and "Enabled" or "Disabled"
				local log_level = smear_enabled and vim.log.levels.INFO or vim.log.levels.WARN

				-- Notify the user about the state change
				vim.notify(status .. " **SmearCursor**", log_level, { title = "Cursor Animation" })
			end,
			desc = "Toggle Cursor Animation",
			silent = true,
		},
	},
}
