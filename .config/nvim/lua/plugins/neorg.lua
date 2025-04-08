return {
	"nvim-neorg/neorg",
	version = "*",
	event = { "LazyFile" },
	ft = { "norg" },
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
			"<leader>nf",
			function()
				Snacks.win({
					width = 0.4,
					height = 0.8,
					position = "float",
					border = "rounded",
					wo = {
						wrap = true,
						spell = false,
						number = false,
						relativenumber = false,
						foldenable = false,
						foldcolumn = "0",
					},
					on_win = function(win)
						vim.cmd("Neorg workspace notes")
					end,
				})
			end,
			desc = "Floating Note",
			silent = true,
		},
		{
			"<leader>nn",
			function()
				Snacks.win({
					width = 0.2,
					position = "right",
					wo = {
						wrap = true,
						spell = false,
						number = true,
						relativenumber = true,
						foldenable = false,
						foldcolumn = "0",
					},
					on_win = function(win)
						vim.cmd("Neorg workspace notes")
					end,
				})
			end,
			desc = "Note",
			silent = true,
		},
		{
			"<leader>nN",
			"<Plug>(neorg.dirman.new-note)",
			desc = "New Note",
			silent = true,
		},
		{
			"<tab>",
			"<Plug>(neorg.itero.next-iteration)",
			mode = "i",
			ft = "norg",
			silent = true,
		},
		{
			"gO",
			"<cmd>Neorg toc<cr>",
			ft = "norg",
			desc = "Create a Table of Contents",
			silent = true,
		},
	},
}
