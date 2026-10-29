local layout = "compact"

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
				base_url = "https://" .. vim.env.GITLAB_URL,
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
			github = {
				views = {
					{ name = "Me", key = "1", layout = layout, search = "involves:@me" },
				},
			},
			gitlab = {
				views = {
					{
						name = "Waiting for review",
						key = "1",
						layout = layout,
						scope = "reviews_for_me",
						state = "opened",
						review_states = { "UNREVIEWED", "REVIEW_STARTED" },
					},
					{
						name = "Reviewing",
						key = "2",
						layout = layout,
						scope = "reviews_for_me",
					},
					{
						name = "Assigned",
						key = "3",
						layout = layout,
						scope = "assigned_to_me",
					},
					{
						name = "Created",
						key = "4",
						layout = layout,
						scope = "created_by_me",
					},
				},
			},
		},
		issues = {
			github = {
				views = {
					{ name = "Assigned", key = "1", layout = layout, search = "assignee:@me is:open" },
				},
			},
			gitlab = {
				views = {
					{ name = "Assigned", key = "1", layout = layout, scope = "assigned_to_me", state = "opened" },
					{ name = "Created", key = "2", layout = layout, scope = "created_by_me", state = "opened" },
				},
			},
		},
	},
	keys = {
		{ "<leader>fa", "<cmd>Atlas<cr>", desc = "Atlas" },
	},
}
