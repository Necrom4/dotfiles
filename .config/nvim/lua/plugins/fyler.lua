return {
	"A7Lavinraj/fyler.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	opts = {
		git_status = {
			symbols = {
				Untracked = "",
				Added = "",
				Modified = "󰏬",
				Deleted = "",
				Renamed = "󰑕",
				Copied = "",
				Conflict = "",
				Ignored = "",
			},
		},
		icon = {
			directory_empty = "",
			directory_expanded = "",
		},
		mappings = {
			["H"] = "GotoParent",
			["~"] = "GotoCwd",
			["."] = "GotoNode",
			["Z"] = "CollapseAll",
			["z"] = "CollapseNode",
		},
		win = {
			kind_presets = {
				split_left_most = {
					width = "0.25rel",
				},
			},
		},
	},
	keys = {
		{
			"<leader>xb",
			function()
				require("fyler").toggle({
					dir = LazyVim.root(),
					kind = "split_left_most",
				})
			end,
			desc = "Root Dir (bulk)",
			silent = true,
		},
		{
			"<leader>xB",
			function()
				require("fyler").toggle({
					kind = "split_left_most",
				})
			end,
			desc = "CWD (bulk)",
			silent = true,
		},
	},
}
