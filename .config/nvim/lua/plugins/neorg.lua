return {
	"nvim-neorg/neorg",
	version = "*",
	event = { "LazyFile" },
	opts = {
		load = {
			["core.defaults"] = {},
			["core.concealer"] = {}, -- We added this line!
			["core.dirman"] = {
				config = {
					workspaces = {
						notes = "~/notes",
					},
					default_workspace = "notes",
				},
			},
		},
	},
	cmd = "Neorg",
	keys = {
		{
			"<leader>N",
			':lua Snacks.win({ width = 0.4, height = 0.8, position = "float", border = "rounded", wo = { wrap = true, spell = false, number = true, relativenumber = true, foldenable = false, foldcolumn = "0" }, on_win = function(win) vim.cmd("Neorg workspace notes") end, })<CR>',
			desc = "Open Notes",
			silent = true,
		},
	},
}
