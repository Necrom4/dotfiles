return {
	"okuuva/auto-save.nvim",
	version = "*",
	cmd = "ASToggle",
	ft = { "norg", "eruby", "css", "scss" },
	opts = {
		debounce_delay = 500, -- delay after which a pending save is executed
		trigger_events = {
			immediate_save = { -- vim events that trigger an immediate save
				{ "BufLeave", pattern = { "*.norg" } },
				{ "FocusLost", pattern = { "*.norg" } },
			},
			defer_save = {
				{ "InsertLeave", pattern = { "*.erb", "*.rhtml", "*.css", "*.scss" } },
				{ "TextChanged", pattern = { "*.erb", "*.rhtml", "*.css", "*.scss" } },
			},
			cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
		},
	},
}
