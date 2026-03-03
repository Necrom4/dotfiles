return {
	"TheNoeTrevino/haunt.nvim",
	opts = {
		sign = "󰆉",
		sign_hl = "MiniIconsPurple",
		annotation_prefix = "󰆉 ",
	},
	keys = {
		{
			"<leader>aa",
			function()
				require("haunt.api").annotate()
			end,
			desc = "Annotate",
		},
		{
			"<leader>uN",
			function()
				require("haunt.api").toggle_all_lines()
			end,
			desc = "Toggle Annotations",
		},
		{
			"<leader>ad",
			function()
				require("haunt.api").delete()
			end,
			desc = "Delete",
		},
		{
			"<leader>aD",
			function()
				require("haunt.api").clear_all()
			end,
			desc = "Delete all",
		},
		{
			"]n",
			function()
				require("haunt.api").next()
			end,
			desc = "Next Annotation",
		},
		{
			"[n",
			function()
				require("haunt.api").prev()
			end,
			desc = "Previous Annotation",
		},
		{
			"<leader>sA",
			function()
				require("haunt.picker").show()
			end,
			desc = "Annotations",
		},
		{
			"<leader>Qa",
			function()
				require("haunt.api").to_quickfix()
			end,
			desc = "Annotations",
		},
		{
			"<leader>QA",
			function()
				require("haunt.api").to_quickfix({ current_buffer = true })
			end,
			desc = "Buffer Annotations",
		},
		{
			"<leader>ay",
			function()
				require("haunt.api").yank_locations({ current_buffer = true })
			end,
			desc = "Yank",
		},
		{
			"<leader>aY",
			function()
				require("haunt.api").yank_locations()
			end,
			desc = "Yank all",
		},
	},
}
