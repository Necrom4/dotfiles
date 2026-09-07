return {
	"emrearmagan/atlas.nvim",
	dependencies = {
		"MeanderingProgrammer/render-markdown.nvim",
		"esmuellert/codediff.nvim",
	},
	cmd = { "Atlas", "AtlasDiff" },
	opts = {
		providers = {
			gitlab = {
				base_url = vim.env.GITLAB_URL,
				token = vim.env.GITLAB_TOKEN,
			},
		},
	},
}
