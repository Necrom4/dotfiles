return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			ruby = { "rubocop", stop_after_first = true },
			sql = { "pg_format", "sqruff", stop_after_first = true },
		},
	},
}
