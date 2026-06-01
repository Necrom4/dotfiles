return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			pkl = { "pkl" },
			ruby = { "standardrb", "rubocop", stop_after_first = false },
			sql = { "pg_format", "sqruff", stop_after_first = true },
		},
	},
}
