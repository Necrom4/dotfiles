local function switchToDotfiles(cmd)
	local original_git_dir = vim.env.GIT_DIR
	local home_dir = vim.fn.expand("~")
	local git_dir = vim.fn.expand("~/.local/share/yadm/repo.git") -- Hardcoded for speed

	vim.env.GIT_DIR = git_dir
	cmd(home_dir)
	vim.schedule(function()
		vim.env.GIT_DIR = original_git_dir
	end)
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{ "<leader><leader>", ":lua Snacks.picker()<CR>", desc = "Open Picker", silent = true },
		{ "<leader>.", ":lua Snacks.picker.resume()<CR>", desc = "Resume Picker", silent = true },
		{ "<leader>e", ":lua Snacks.dashboard.open()<CR>", desc = "Open Dashboard", silent = true },
		{
			"<leader>fc",
			function()
				switchToDotfiles(function(home_dir)
					Snacks.dashboard.pick("git_files", { cwd = home_dir })
				end)
			end,
			desc = "Find Config Files",
			silent = true,
		},
		{ "<leader>fs", ":lua Snacks.picker.smart()<CR>", desc = "Open Smart Picker", silent = true },
		{
			"<leader>gy",
			function()
				switchToDotfiles(Snacks.lazygit)
			end,
			desc = "Open Lazygit (Yadm)",
			silent = true,
		},
		{ "<leader>tf", ":lua Snacks.terminal('zsh')<CR>", desc = "Open Floating Terminal", silent = true },
		{ "<leader>tt", ":lua Snacks.terminal()<CR>", desc = "Open Terminal", silent = true },
		{
			"<leader>tc",
			":lua Snacks.terminal(nil, { cwd = vim.fn.expand('%:p:h') })<CR>",
			desc = "Open Terminal (Current Dir)",
			silent = true,
		},
		{
			"<leader>tr",
			":lua Snacks.terminal(nil, { cwd = LazyVim.root() })<CR>",
			desc = "Open Terminal (Root Dir)",
			silent = true,
		},
		{
			"<leader>fn",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{ "<leader>S", ":lua Snacks.scratch()<CR>", desc = "Open Scratch", silent = true },
	},
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = [[
╭────────────────────────────────────────────────────────╮
│ ███╗   ██╗███████╗ ██████╗██████╗  ██████╗ ███╗   ███╗ │
│ ████╗  ██║██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗ ████║ │
│ ██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██╔████╔██║ │
│ ██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║╚██╔╝██║ │
│ ██║ ╚████║███████╗╚██████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║ │
│ ╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ │
╰────────────────────────────────────────────────────────╯]],
				keys = {
					{ icon = " ", key = "e", desc = "New File", action = ":ene | startinsert" },
					{ icon = "󰥨 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{
						icon = "󰈞 ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							switchToDotfiles(function(home_dir)
								Snacks.dashboard.pick("git_files", { cwd = home_dir })
							end)
						end,
					},
					{ icon = " ", key = "l", desc = "Lazy Config", action = ":lua Snacks.picker.lazy()" },
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = " ", key = "q", desc = "Quit", action = ":quit" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", padding = 2 },
				{ icon = "󰙅 ", title = "PROJECTS", section = "projects", indent = 2, padding = 2 },
				{
					icon = " ",
					title = "GIT STATUS",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() == nil
					end,
					cmd = "cmatrix",
					height = 5,
					padding = 2,
					ttl = 5 * 60,
					indent = 2,
				},
				{
					icon = " ",
					title = "GIT STATUS [" .. vim.fn.trim(vim.fn.system("git branch --show-current")) .. "]",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git --no-pager diff --stat -B -M -C && git status --short --renames",
					height = 5,
					padding = 2,
					ttl = 5 * 60,
					indent = 2,
				},
				{ section = "startup" },
			},
		},
		dim = {
			enabled = true,
		},
		indent = {
			-- indent = {
			-- 	enabled = false,
			-- },
		},
		input = { enabled = true },
		lazygit = {
			enabled = true,
			theme = {
				[241] = { fg = "Special" },
				activeBorderColor = { fg = "MatchParen", bold = true },
				cherryPickedCommitBgColor = { fg = "Identifier" },
				cherryPickedCommitFgColor = { fg = "Function" },
				defaultFgColor = { fg = "Normal" },
				inactiveBorderColor = { fg = "FloatBorder" },
				optionsTextColor = { fg = "Function" },
				searchingActiveBorderColor = { fg = "MatchParen", bold = true },
				selectedLineBgColor = { bg = "Visual" },
				unstagedChangesColor = { fg = "Operator" },
			},
		},
		notifier = { enabled = false, style = "fancy" },
		picker = {
			enabled = true,
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<c-q>"] = { "close", mode = { "n", "i" } },
						["<F1>"] = { "toggle_help", mode = { "n", "i" } },
						["<c-p>"] = { "preview_scroll_up", mode = { "i", "n" } },
						["<c-n>"] = { "preview_scroll_down", mode = { "i", "n" } },
						["<a-q>"] = { "qflist", mode = { "i", "n" } },
						["<Tab>"] = { { "select_and_next", "list_up" }, mode = { "i", "n" } },
						["<S-Tab>"] = { "select_and_next", mode = { "i", "n" } },
					},
				},
			},
			on_show = function()
				require("nvim-treesitter")
			end,
		},
		quickfile = { enabled = true },
		scroll = { enabled = true },
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
				height = 0.7,
				width = 0.7,
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
}
