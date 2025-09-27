return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			ruby = { "standardrb", "rubocop", stop_after_first = true },
			sql = { "pg_format", "sqruff", stop_after_first = true },
		},
	},
}
