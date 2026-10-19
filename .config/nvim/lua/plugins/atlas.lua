return {
	"emrearmagan/atlas.nvim",
	dependencies = {
		"MeanderingProgrammer/render-markdown.nvim",
		"esmuellert/codediff.nvim",
	},
	cmd = { "Atlas", "AtlasDiff" },
	opts = {
		keymaps = {
			ui = {
				show_details = "gK",
			},
			pulls = {
				review = {
					show_details = "gK",
				},
			},
		},
		providers = {
			github = {},
			gitlab = {
				base_url = vim.env.GITLAB_URL,
				token = vim.env.GITLAB_TOKEN,
			},
		},
		pulls = {
			diff = {
				open_cmd = "CodeDiff",
				review_panel = {
					hidden = false,
				},
			},
			gitlab = {
				views = {
					{
						name = "Waiting for review",
						key = "1",
						scope = "reviews_for_me",
						state = "opened",
						review_states = { "UNREVIEWED", "REVIEW_STARTED" },
					},
					{
						name = "Reviewing",
						key = "2",
						scope = "reviews_for_me",
					},
					{
						name = "Assigned",
						key = "3",
						scope = "assigned_to_me",
					},
					{
						name = "Created",
						key = "4",
						scope = "created_by_me",
					},
				},
			},
		},
	},
	keys = {
		{ "<leader>fa", "<cmd>Atlas<cr>", desc = "Atlas" },
	},
}
