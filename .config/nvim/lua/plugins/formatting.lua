return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			sql = { "pg_format", "sqruff", stop_after_first = true },
		},
	},
}
