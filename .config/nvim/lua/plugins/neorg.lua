return {
	"nvim-neorg/neorg",
	version = "*",
	event = { "LazyFile" },
	ft = { "norg" },
	opts = {
		load = {
			-- Basics
			["core.defaults"] = {}, -- Loads default modules
			["core.concealer"] = {}, -- Handles visual rendering of markup
			["core.dirman"] = { -- Manages workspaces
				config = {
					workspaces = {
						notes = "~/notes",
					},
					default_workspace = "notes",
				},
			},
			["core.autocommands"] = {},
			["core.integrations.treesitter"] = {},
			["core.itero"] = {},
			["core.highlights"] = {},
			["core.keybinds"] = {},
			["core.promo"] = {},
			["core.qol.todo_items"] = {},
			["core.syntax"] = {},
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
			"<tab>",
			"<Plug>(neorg.itero.next-iteration)",
			mode = "i",
			ft = "norg",
			silent = true,
		},
		{
			"<a-x>",
			"<Plug>(neorg.qol.todo-items.todo.task-cycle)",
			ft = "norg",
			silent = true,
		},
		{
			"<leader>ct",
			"<cmd>Neorg toc<cr>",
			ft = "norg",
			desc = "Create a Table of Contents",
			silent = true,
		},
		{
			"<leader>cc",
			"<Plug>(neorg.looking-glass.magnify-code-block)",
			ft = "norg",
			desc = "Magnify code block to separate buffer",
			silent = true,
		},
		{
			"gi",
			"<Plug>(neorg.pivot.list.toggle)",
			ft = "norg",
			desc = "Invert list items",
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
			">>",
			"<Plug>(neorg.promo.promote)",
			ft = "norg",
			desc = "[neorg] Promote object (Non-Recursively)",
			silent = true,
		},
		{
			"<<",
			"<Plug>(neorg.promo.demote)",
			ft = "norg",
			desc = "[neorg] Demote object (Non-Recursively)",
			silent = true,
		},
		{
			">",
			"<Plug>(neorg.promo.promote.range)",
			ft = "norg",
			mode = "v",
			desc = "[neorg] Promote object in range",
			silent = true,
		},
		{
			"<",
			"<Plug>(neorg.promo.demote.range)",
			ft = "norg",
			mode = "v",
			desc = "[neorg] Demote object in range",
			silent = true,
		},
	},
}
