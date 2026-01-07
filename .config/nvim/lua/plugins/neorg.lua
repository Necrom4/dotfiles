return {
	"nvim-neorg/neorg",
	version = false,
	dependencies = {
		{
			-- TODO: remove whenever norg is integrate into nvim-treesitter's main branch
			"nvim-neorg/tree-sitter-norg",
			build = {
				"rockspec",
				function()
					local from = vim.fn.stdpath("data") .. "/lazy-rocks/tree-sitter-norg/lib/lua/5.1/parser/norg.so"
					local to = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/norg.so"
					vim.fn.mkdir(vim.fn.fnamemodify(to, ":p:h"), "p")

					pcall(vim.uv.fs_unlink, to)
					local ok, err, err_name = vim.uv.fs_symlink(from, to, { dir = false, junction = false })
					if not ok then
						vim.notify(
							("symlink %s → %s failed: %s %s"):format(from, to, err, err_name),
							vim.log.levels.ERROR,
							{ title = "tree-sitter-norg" }
						)
					else
						vim.notify(
							("symlink %s → %s created"):format(from, to),
							vim.log.levels.INFO,
							{ title = "tree-sitter-norg" }
						)
					end
				end,
			},
		},
		"benlubas/neorg-conceal-wrap",
		"benlubas/neorg-interim-ls",
	},
	event = { "LazyFile" },
	ft = { "norg" },
	opts = {
		load = {
			["core.autocommands"] = {},
			["core.completion"] = {
				config = { engine = { module_name = "external.lsp-completion" } },
			},
			["core.concealer"] = {},
			["core.defaults"] = {},
			["core.dirman"] = {
				config = {
					workspaces = { notes = "~/.notes" },
					default_workspace = "notes",
				},
			},
			["core.esupports.indent"] = {},
			["core.export"] = {},
			["core.export.html"] = {},
			["core.export.markdown"] = {},
			["core.highlights"] = {},
			["core.integrations.treesitter"] = {},
			["core.itero"] = {},
			["core.keybinds"] = {},
			["core.promo"] = {},
			["core.qol.todo_items"] = {},
			["core.syntax"] = {},
			["external.conceal-wrap"] = {},
			["external.interim-ls"] = {},
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
						vim.cmd("Neorg index")
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
			"<c-x>",
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
