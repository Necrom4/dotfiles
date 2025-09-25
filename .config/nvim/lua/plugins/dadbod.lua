vim.g.db_ui_drawer_sections = { "schemas", "saved_queries", "new_query", "buffers" }

vim.g.db_ui_icons = {
	expanded = {
		buffers = "▾ ﬘",
		saved_queries = "▾ 󱔗",
	},
	collapsed = {
		buffers = "▸ ﬘",
		saved_queries = "▸ 󱔗",
	},
	saved_query = "",
	new_query = "󱇧",
	connection_ok = "",
	connection_error = "",
}

return {
	"kndndrj/nvim-dbee",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	build = function()
		-- Install tries to automatically detect the install method.
		-- if it fails, try calling it with one of these parameters:
		--    "curl", "wget", "bitsadmin", "go"
		require("dbee").install()
	end,
	config = function()
		require("dbee").setup(--[[optional config]])
	end,
}
