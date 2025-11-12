return {
	"okuuva/auto-save.nvim",
	version = "*",
	cmd = "ASToggle",
	event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
	opts = {
		debounce_delay = 500, -- delay after which a pending save is executed
		trigger_events = {
			immediate_save = { { "BufLeave", "FocusLost", pattern = { "*.norg" } } }, -- vim events that trigger an immediate save
			defer_save = {
				{ "InsertLeave", "TextChanged", pattern = { "*.erb", "*.css", "*.scss" } },
			},
			cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
		},
	},
}
