-- SYSYTEM_INFO
local function term_cmd(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+$", "")
end

local function make_graph(percentage, width)
	percentage = tonumber(percentage) or 0
	width = width or 20
	local filled = math.floor((percentage / 100) * width)
	return string.rep("■", filled) .. string.rep("□", width - filled)
end

-- CPU
local cpu = tonumber(term_cmd("uptime"):match("load average:%s*([%d%.]+)")) or 0

-- RAM
local ram_output = term_cmd("free -m | awk '/Mem:/ {print $3, $2}'")
local ram_used, ram_total = ram_output:match("(%d+)%s+(%d+)")
ram_used = tonumber(ram_used or "0")
ram_total = tonumber(ram_total or "1") -- avoid division by zero

-- DISK
local disk_output = term_cmd("df -h / | awk 'NR==2 {print $3, $2}'")
local disk_used, disk_total = disk_output:match("(%d+)%a?%s+(%d+)%a?")
disk_used = tonumber(disk_used or "0")
disk_total = tonumber(disk_total or "1")

-- UPTIME
local function days_since_uptime(uptime_date_str)
	local year, month, day = uptime_date_str:match("(%d+)-(%d+)-(%d+)")
	year, month, day = tonumber(year), tonumber(month), tonumber(day)
	local uptime_time = os.time({ year = year, month = month, day = day, hour = 0, min = 0, sec = 0 })
	local now = os.date("*t")
	local current_time = os.time({ year = now.year, month = now.month, day = now.day, hour = 0, min = 0, sec = 0 })
	local diff_in_seconds = os.difftime(current_time, uptime_time)
	local days = math.floor(diff_in_seconds / (60 * 60 * 24))

	return days
end

-- BATTERY
local function get_battery_percentage()
	local handle
	local result

	-- Try Linux first
	handle = io.popen("cat /sys/class/power_supply/BAT*/capacity 2>/dev/null")
	if handle then
		result = handle:read("*a")
		handle:close()
		if result and result:match("%d+") then
			return tonumber(result:match("%d+"))
		end
	end

	-- Try macOS if Linux check failed
	handle = io.popen("pmset -g batt | grep -Eo '\\d+%' | head -1")
	if handle then
		result = handle:read("*a")
		handle:close()
		if result and result:match("%d+") then
			return tonumber(result:match("%d+"))
		end
	end

	return nil -- Battery info not found
end

-- Calculations
local ram_percent = (tonumber(ram_used) or 0) / (tonumber(ram_total) or 1) * 100
local disk_percent = (tonumber(disk_used) or 0) / (tonumber(disk_total) or 1) * 100
local uptime_percent = math.min((days_since_uptime(term_cmd("uptime -s")) / 7) * 100, 100)

-- Neovim Version
local function vim_version()
	return vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
end

-- Table system_info
local system_info = {
	"╭────────┬─────────────────────────────────────────╮",
	string.format("│ CPU    │ %-16s %2s %s │", cpu .. "%", "", make_graph(cpu)),
	string.format(
		"│ RAM    │ %-16s %2s %s │",
		ram_used .. "/" .. ram_total .. "MB",
		"",
		make_graph(ram_percent)
	),
	string.format(
		"│ DISK   │ %-16s %2s %s │",
		disk_used .. "/" .. disk_total .. "GB",
		"󰨆",
		make_graph(disk_percent)
	),
	string.format("│ UPTIME │ %-29s %2s %s │", term_cmd("uptime -s"), "󰃭", make_graph(uptime_percent, 7)),
	string.format(
		"│ MORE   │ %-10s %33s │",
		" " .. get_battery_percentage() .. "%",
		"󰍸 " .. term_cmd("hostname -I | awk '{print $1}'")
	),
	"╰────────┴─────────────────────────────────────────╯",
}

--YADM
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
		{ "<leader>e", false },
		{ "<leader>E", false },
		{ "<leader>n", false },
		{ "<leader>sr", mode = { "n", "x" }, false },
		{ "<leader>sw", mode = { "n", "x" }, false },
		{ "<leader>sW", mode = { "n", "x" }, false },
		{
			"<leader><leader>",
			function()
				Snacks.picker()
			end,
			desc = "Snacks Picker",
			silent = true,
		},
		{
			"<leader>.",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume Picker",
			silent = true,
		},
		{
			"<leader><cr>",
			function()
				Snacks.dashboard.open()
			end,
			desc = "Dashboard",
			silent = true,
		},
		{
			"<leader>bn",
			function()
				vim.cmd("enew")
			end,
			desc = "New Buffer",
			silent = true,
		},
		{
			"<leader>D",
			function()
				Snacks.terminal("lazydocker")
			end,
			desc = "Lazydocker",
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
				switchToDotfiles(function(home_dir)
					Snacks.dashboard.pick("git_files", { cwd = home_dir })
				end)
			end,
			desc = "Find Config File",
			silent = true,
		},
		{
			"<leader>fl",
			function()
				Snacks.picker.lazy()
			end,
			desc = "Find Lazy Config Files",
			silent = true,
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Picker",
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
			"<leader>gy",
			function()
				switchToDotfiles(Snacks.lazygit)
			end,
			desc = "Lazygit (Yadm)",
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
			"<leader>sr",
			function()
				Snacks.picker.registers()
			end,
			desc = "Registers",
			mode = { "n", "x" },
			silent = true,
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
			desc = "cwd",
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
			desc = "cwd",
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
	},
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]
					.. "\n"
					.. term_cmd("lsb_release -ds")
					.. "  "
					.. vim_version()
					.. "\n"
					.. table.concat(system_info, "\n")
					.. "\n"
					.. os.date(),
				keys = {
					{ icon = " ", key = "n", desc = "New File", action = ":ene" },
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = " ", key = "q", desc = "Quit", action = ":quit" },
				},
			},
			sections = {
				{ pane = 1, section = "header" },
				{
					pane = 1,
					section = "terminal",
					cmd = "curl -s 'https://wttr.in/?0FQ' || echo",
					height = 6,
				},
				{ pane = 1, section = "startup" },
				{ pane = 2, section = "keys", padding = 1 },
				{ pane = 2, icon = " ", title = "RECENT FILES", section = "recent_files", indent = 2, padding = 1 },
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
			sources = {
				buffers = {
					hidden = true,
				},
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
							},
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
		words = { enabled = true },
	},
}
