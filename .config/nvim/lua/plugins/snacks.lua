-- SYSTEM UTILS
local function term_cmd(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+$", "")
end

local function make_graph(percent, width)
	percent = tonumber(percent) or 0
	width = width or 20
	if percent > 100 then
		return string.rep("󰨔", width)
	end
	local filled = math.floor((percent / 100) * width)
	return string.rep("■", filled) .. string.rep("□", width - filled)
end

-- OS NAME
local function os_name()
	local uname = term_cmd("uname")
	if uname == "Linux" then
		local linux_name = term_cmd("lsb_release -ds")
		if linux_name == "" then
			linux_name = term_cmd("cat /etc/os-release | grep '^PRETTY_NAME=' | cut -d '\"' -f2")
		end
		return linux_name ~= "" and linux_name or "Linux"
	elseif uname == "Darwin" then
		return term_cmd("sw_vers -productName") .. " " .. term_cmd("sw_vers -productVersion")
	end
	return "Unknown OS"
end

-- NEOVIM VERSION
local function vim_version()
	return vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
end

-- CPU
local cpu_load = tonumber(term_cmd("uptime"):match("load averages?:%s*([%d%.]+)")) or 0

-- RAM
local function ram()
	if term_cmd("uname") == "Linux" then
		local memory_output = term_cmd("free -m | awk '/Mem:/ {print $3, $2}'")
		local used_mb, total_mb = memory_output:match("(%d+)%s+(%d+)")
		return tonumber(used_mb), tonumber(total_mb)
	end
	local page_size = 4096
	local active_pages = tonumber(term_cmd("vm_stat | grep 'Pages active'"):match("(%d+)")) or 0
	local inactive_pages = tonumber(term_cmd("vm_stat | grep 'Pages inactive'"):match("(%d+)")) or 0
	local wired_pages = tonumber(term_cmd("vm_stat | grep 'Pages wired down'"):match("(%d+)")) or 0
	local memsize_str = term_cmd("sysctl -n hw.memsize"):gsub("[^%d]", "")
	local total_bytes = tonumber(memsize_str) or (8 * 1024 ^ 3)
	local used_bytes = (active_pages + inactive_pages + wired_pages) * page_size
	local used_mb = used_bytes / 1024 ^ 2
	local total_mb = total_bytes / 1024 ^ 2
	return math.floor(used_mb), math.floor(total_mb)
end

-- DISK
local function disk()
	local uname = term_cmd("uname")
	local disk_output
	local is_wsl = false

	if uname == "Linux" then
		local kernel_version = term_cmd("cat /proc/version")
		if kernel_version:match("Microsoft") or kernel_version:match("WSL") then
			is_wsl = true
		end
	end

	if uname == "Linux" or uname == "Darwin" then
		local mount_path = is_wsl and "/mnt/c" or "/"
		disk_output = term_cmd("df -k " .. mount_path .. " | awk 'NR==2 {print $3, $2}'")
		local used_kb, total_kb = disk_output:match("(%d+)%s+(%d+)")
		local used_gb = tonumber(used_kb or "0") / (1024 * 1024)
		local total_gb = tonumber(total_kb or "1") / (1024 * 1024)
		return math.floor(used_gb + 0.5), math.floor(total_gb + 0.5)
	end

	return 0, 1
end

-- UPTIME
local function uptime()
	if term_cmd("uname") == "Linux" then
		local year, month, day = term_cmd("uptime -s"):match("(%d+)-(%d+)-(%d+)")
		local boot_time = os.time({ year = year, month = month, day = day })
		local current_time = os.time(os.date("*t"))
		return term_cmd("uptime -s"), math.min(math.floor(os.difftime(current_time, boot_time) / 86400) / 14) * 100, 100
	end
	local boot_sec = term_cmd("sysctl -n kern.boottime"):match("sec%s*=%s*(%d+)")
	local boot_date = tonumber(boot_sec) and os.date("*t", tonumber(boot_sec))
	local current_date = os.date("*t")
	local boot_day = os.time({ year = boot_date.year, month = boot_date.month, day = boot_date.day })
	local current_day = os.time({ year = current_date.year, month = current_date.month, day = current_date.day })
	return boot_date, math.min(math.floor(os.difftime(current_day, boot_day) / 86400) / 14) * 100, 100
end

-- BATTERY
local function battery_percentage()
	local battery_output = term_cmd(
		'for d in /sys/class/power_supply/*; do case "$d" in */BAT*|*/CMD*|*/battery*) cat "$d/capacity" 2>/dev/null; break; esac; done'
	)
	if battery_output:match("%d+") then
		return tonumber(battery_output:match("%d+"))
	end
	local battery_mac = term_cmd("pmset -g batt | grep -Eo '\\d+%' | head -1")
	return tonumber(battery_mac and battery_mac:match("%d+")) or 0
end

-- IP ADDRESS
local function ip_address()
	if term_cmd("uname") == "Linux" then
		return term_cmd("hostname -I | awk '{print $1}'")
	end
	local ip = term_cmd("ipconfig getifaddr en0")
	if ip == "" then
		ip = term_cmd("ipconfig getifaddr en1")
	end
	return ip ~= "" and ip or "N/A"
end

-- RAM/DISK/UPTIME
local ram_used, ram_total = ram()
local disk_used, disk_total = disk()
local disk_percent = disk_used / disk_total * 100
local ram_percent = ram_used / ram_total * 100
local uptime_date, uptime_percent = uptime()

-- SYSTEM INFO BOX
local system_info = {
	"╭────────┬─────────────────────────────────────────╮",
	string.format("│ CPU    │ %-16s %2s %s │", cpu_load .. "%", "", make_graph(cpu_load)),
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
	string.format("│ UPTIME │ %-22s %2s %s │", uptime_date, "󰃭", make_graph(uptime_percent, 14)),
	string.format("│ MORE   │ %-10s %33s │", " " .. battery_percentage() .. "%", "󰍸 " .. ip_address()),
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
		{ "<leader>ua", false },
		{
			"<leader>ua",
			function()
				Snacks.toggle.animate():toggle()
				Snacks.toggle.scroll():toggle()
				require("smear_cursor").toggle()
			end,
			desc = "Toggle Animations",
			silent = true,
		},
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
					.. os_name()
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
