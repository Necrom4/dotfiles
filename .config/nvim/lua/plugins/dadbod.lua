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

return {}
