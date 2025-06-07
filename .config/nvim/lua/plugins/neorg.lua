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
			["core.keybinds"] = {},
			["core.promo"] = {},
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
			"<a-x>",
			"<Plug>(neorg.qol.todo-items.todo.task-cycle)",
			ft = "norg",
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
		{
			"g>>",
			"<Plug>(neorg.promo.promote.nested)",
			ft = "norg",
			desc = "[neorg] Promote object (Recursively)",
			silent = true,
		},
		{
			"g<<",
			"<Plug>(neorg.promo.demote.nested)",
			ft = "norg",
			desc = "[neorg] Demote object (Recursively)",
			silent = true,
		},
		{
			"g>.",
			"<Plug>(neorg.promo.promote)",
			ft = "norg",
			desc = "[neorg] Promote object (Non-Recursively)",
			silent = true,
		},
		{
			"g<.",
			"<Plug>(neorg.promo.demote)",
			ft = "norg",
			desc = "[neorg] Demote object (Non-Recursively)",
			silent = true,
		},
	},
}
