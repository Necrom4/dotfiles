local utils = require("utils.general")

return {
	"folke/snacks.nvim",
	keys = {
		-- Disable keymaps
		{ "<leader>e", false },
		{ "<leader>E", false },
		{ "<leader>fT", false },
		{ "<leader>ft", false },
		{ "<leader>gB", false },
		{ "<leader>gD", false },
		{ "<leader>gI", false },
		{ "<leader>gL", false },
		{ "<leader>gP", false },
		{ "<leader>gS", false },
		{ "<leader>gY", false },
		{ "<leader>gb", false },
		{ "<leader>gd", false },
		{ "<leader>gf", false },
		{ "<leader>gi", false },
		{ "<leader>gl", false },
		{ "<leader>gp", false },
		{ "<leader>gs", false },
		{ "<leader>n", false },
		{ "<leader>sC", false },
		{ "<leader>sc", false },
		{ "<leader>sR", false },
		{ "<leader>sw", mode = { "n", "x" }, false },
		{ "<leader>sW", mode = { "n", "x" }, false },
		{ "<leader>uc", false },
		{ "<leader>uC", false },
		{ "<leader>uD", false },
		{ "<leader>.", false },
		{
			"<leader><leader>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Picker",
			silent = true,
		},
		{
			"<leader>=",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume Picker",
			silent = true,
		},
		{
			"<leader><cr>",
			function()
				Snacks.picker()
			end,
			desc = "Snacks Picker",
			silent = true,
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers({ current = false })
			end,
			desc = "Buffers",
			silent = true,
		},
		{
			"<leader>fc",
			function()
				utils.in_yadm_env(function(yadm_repo)
					Snacks.dashboard.pick("git_files", { cwd = yadm_repo })
				end)
			end,
			desc = "Find Config File",
			silent = true,
		},
		{
			"<leader>fy",
			function()
				Snacks.picker.yanky()
			end,
			desc = "Yanky Picker",
			silent = true,
		},
		{
			"<leader>ga",
			function()
				vim.cmd("!git add " .. vim.fn.fnameescape(vim.fn.expand("%:p")))
			end,
			desc = "Add file",
			silent = true,
		},
		{
			"<leader>gy",
			function()
				utils.switch_git_dir()
			end,
			desc = "Toggle Repo",
			silent = true,
		},
		{
			"<leader>hc",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command",
		},
		{
			"<leader>hs",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search",
		},
		{
			"<leader>ns",
			function()
				Snacks.scratch()
			end,
			desc = "Scratch",
			silent = true,
		},
		{
			"<leader>sc",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep_word({ cwd = LazyVim.root() })
			end,
			desc = "Grep Selection (Root Dir)",
			mode = "x",
		},
		{
			"<leader>sG",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Grep Selection (cwd)",
			mode = "x",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.lines()
			end,
			desc = "Lines",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.spelling()
			end,
			desc = "Spelling",
		},
		{
			"<leader>tf",
			function()
				Snacks.terminal("zsh", { cwd = vim.fn.expand("%:p:h") })
			end,
			desc = "Buffer Dir (floating)",
			silent = true,
		},
		{
			"<leader>tt",
			function()
				Snacks.terminal(nil, { cwd = LazyVim.root() })
			end,
			desc = "Root Dir",
			silent = true,
		},
		{
			"<leader>tT",
			function()
				Snacks.terminal()
			end,
			desc = "CWD",
			silent = true,
		},
		{
			"<leader>ua",
			function()
				Snacks.toggle.animate():toggle()
				if not vim.g.neovide then
					vim.b.minianimate_disable = not vim.b.minianimate_disable
					require("smear_cursor").toggle()
				end
			end,
			silent = true,
		},
		{
			"<leader>xx",
			function()
				Snacks.picker.explorer({ cwd = LazyVim.root() })
			end,
			desc = "Root Dir",
			silent = true,
		},
		{
			"<leader>xX",
			function()
				Snacks.picker.explorer()
			end,
			desc = "CWD",
			silent = true,
		},
		{
			"<c-w>m",
			function()
				Snacks.toggle.zoom():toggle()
			end,
			desc = "Toggle maximize",
			silent = true,
		},
		-- OTHER
		{
			"<leader>.d",
			function()
				Snacks.dashboard.open()
			end,
			desc = "Dashboard",
			silent = true,
		},
		-- use Snacks for default LazyVim LSP function keymaps
		{
			"grd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "vim.lsp.buf.lsp_definitions()",
		},
		{
			"grD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "vim.lsp.buf.lsp_declarations()",
		},
		{
			"gri",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "vim.lsp.buf.lsp_implementations()",
		},
		{
			"grr",
			function()
				Snacks.picker.lsp_references()
			end,
			desc = "vim.lsp.buf.references()",
		},
		{
			"grt",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "vim.lsp.buf.lsp_type_definitions()",
		},
	},
	opts = {
		bigfile = {
			enabled = true,
			setup = function(ctx)
				-- defaults
				if vim.fn.exists(":NoMatchParen") ~= 0 then
					vim.cmd([[NoMatchParen]])
				end
				Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
				vim.b.minianimate_disable = true
				vim.b.minihipatterns_disable = true
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(ctx.buf) then
						vim.bo[ctx.buf].syntax = ctx.ft
					end
				end)

				-- mine
				vim.b.completion = false
				vim.b.minidiff_disable = true
				if vim.fn.exists(":UfoDetach") ~= 0 then
					vim.cmd("UfoDetach")
				end
			end,
		},
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = " ", key = "n", desc = "New File", action = ":ene" },
					{
						icon = "󰥨 ",
						key = "f",
						desc = "Find File",
						action = function()
							Snacks.dashboard.pick("files", { cwd = "." })
						end,
					},
					{
						icon = "󰈞 ",
						key = "g",
						desc = "Find Text",
						action = function()
							Snacks.dashboard.pick("live_grep")
						end,
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = function()
							Snacks.dashboard.pick("oldfiles")
						end,
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							utils.in_yadm_env(function(yadm_repo)
								Snacks.dashboard.pick("git_files", { cwd = yadm_repo })
							end)
						end,
					},
					{
						icon = " ",
						key = "p",
						desc = "Plugins",
						action = function()
							Snacks.picker.lazy()
						end,
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = " ", key = "q", desc = "Quit", action = ":quit" },
				},
			},
			sections = {
				function()
					return {
						header = require("utils.dashboard").header,
						padding = 1,
						pane = 1,
					}
				end,
				{
					pane = 1,
					section = "terminal",
					cmd = "curl -s 'https://wttr.in/?0FQ' | sed 's/^/               /' || echo -n",
					height = 6,
				},
				{ pane = 1, section = "startup" },
				{ pane = 2, section = "keys", padding = 1 },
				{
					pane = 2,
					icon = " ",
					title = "RECENT FILES",
					section = "recent_files",
					indent = 2,
					padding = 1,
				},
				{ pane = 2, icon = "󰙅 ", title = "PROJECTS", section = "projects", indent = 2, padding = 1 },
				{
					pane = 2,
					icon = " ",
					title = "GIT STATUS [" .. vim.fn.trim(vim.fn.system("git branch --show-current")) .. "]",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git --no-pager diff --stat -B -M -C && git status --short --renames",
					height = 5,
					padding = 1,
					ttl = 5 * 60,
					indent = 2,
				},
				{
					pane = 2,
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() == nil
					end,
					cmd = "cmatrix -br",
					height = 6,
					indent = 2,
					padding = 1,
				},
			},
		},
		dim = {
			enabled = true,
		},
		indent = { enabled = true },
		input = { enabled = true },
		lazygit = {
			enabled = true,
		},
		notifier = { enabled = false, style = "fancy" },
		picker = {
			enabled = true,
			sources = {
				explorer = {
					auto_close = true,
					hidden = true,
					win = {
						list = {
							keys = {
								["L"] = "explorer_focus",
								["H"] = "explorer_up",
								["K"] = "preview_scroll_up",
								["J"] = "preview_scroll_down",
								["<Tab>"] = { { "select_and_next", "list_up" } },
								["<S-Tab>"] = "select_and_next",
								["<c-w>m"] = "toggle_maximize",
								["<leader>ga"] = "git_add",
								["<leader>gD"] = "git_rm",
								["<leader>xf"] = "yazi_open",
							},
						},
					},
					actions = {
						git_add = {
							action = function(picker)
								vim.cmd({
									cmd = "!",
									args = { "git", "add", vim.fn.escape(picker:current().file, "#") },
								})
							end,
						},
						git_rm = {
							action = function(picker)
								vim.cmd({
									cmd = "!",
									args = { "git", "rm", "--cached", vim.fn.escape(picker:current().file, "#") },
								})
							end,
						},
						yazi_open = {
							action = function(picker)
								require("yazi").yazi({}, vim.fn.escape(picker:current().file, "#"))
							end,
						},
					},
				},
				files = {
					hidden = true,
				},
			},
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					keys = {
						["<c-q>"] = { "close", mode = { "n", "i" } },
						["<F1>"] = { "toggle_help", mode = { "n", "i" } },
						["<c-/>"] = { "toggle_help", mode = { "i" } },
						["<a-r>"] = { "toggle_regex", mode = { "i", "n" } },
						["<a-q>"] = { "qflist", mode = { "i", "n" } },
						["<s-k>"] = { "preview_scroll_up", mode = { "n" } },
						["<s-j>"] = { "preview_scroll_down", mode = { "n" } },
						["<a-k>"] = { "history_back", mode = { "i" } },
						["<a-j>"] = { "history_forward", mode = { "i" } },
						["<tab>"] = { { "select_and_next", "list_up" }, mode = { "i", "n" } },
						["<s-tab>"] = { "select_and_next", mode = { "i", "n" } },
					},
				},
			},
			on_show = function()
				require("nvim-treesitter")
			end,
		},
		quickfile = { enabled = true },
		scroll = { enabled = not vim.g.neovide },
		statuscolumn = {
			left = { "git" }, -- priority of signs on the left (high to low)
			right = { "sign", "mark", "fold" }, -- priority of signs on the right (high to low)
			folds = {
				open = true, -- show open fold icons
				git_hl = false, -- use Git Signs hl for fold icons
			},
			git = {
				-- patterns to match Git signs
				patterns = { "GitSign", "MiniDiffSign" },
			},
			refresh = 50, -- refresh at most every 50ms
		},
		styles = {
			dashboard = {
				height = 0.8,
				width = 0.8,
				border = "rounded",
			},
			lazygit = {
				border = "rounded",
			},
			terminal = {
				border = "rounded",
			},
		},
		terminal = {
			enabled = true,
			win = {
				keys = {
					nav_h = false,
					nav_j = false,
					nav_k = false,
					nav_l = false,
				},
			},
		},
		words = { enabled = false },
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				Snacks.toggle.dim():map("<leader>uDt")
			end,
		})
	end,
}
