local gitlab = {
	base_url = vim.env.GITLAB_URL,
	token = vim.env.GITLAB_TOKEN,
}

return {
	"emrearmagan/atlas.nvim",
	dependencies = {
		"MeanderingProgrammer/render-markdown.nvim",
		"esmuellert/codediff.nvim",
	},
	opts = {
		pulls = {
			providers = {
				gitlab = gitlab,
			},
		},
		issues = {
			providers = {
				gitlab = gitlab,
			},
		},
	},
}
