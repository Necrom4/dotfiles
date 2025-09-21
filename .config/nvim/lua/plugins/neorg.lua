return {
	"nvim-neorg/neorg",
	-- version = "*",
	commit = "a0858f0f83dd45e26671b9153babf974bb52e205",
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
			"<leader>nn",
			function()
				Snacks.win({
					width = 0.3,
					height = 0.6,
					row = -1,
					col = -1,
					position = "float",
					border = "rounded",
					wo = {
						wrap = true,
						spell = true,
						number = false,
						relativenumber = false,
						foldenable = false,
						foldcolumn = "0",
					},
					on_win = function()
						vim.cmd("Neorg workspace notes")
					end,
				})
			end,
			desc = "Open Note",
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
