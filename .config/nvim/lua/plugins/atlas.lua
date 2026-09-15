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
		pulls = {
			gitlab = {
				views = {
					{
						name = "Reviewing",
						key = "1",
						scope = "reviews_for_me",
					},
					{
						name = "Assigned",
						key = "2",
						scope = "assigned_to_me",
					},
					{
						name = "Created",
						key = "3",
						scope = "created_by_me",
					},
				},
			},
		},
	},
}
