--------------------
--------GIT---------
--------------------

-- TOGGLE BETWEEN CURRENT & YADM REPO
local original_git_dir = nil

local function switchRepo()
	local yadm_git_dir = vim.fn.expand("~/.local/share/yadm/repo.git")

	if vim.env.GIT_DIR == yadm_git_dir then
		vim.env.GIT_DIR = original_git_dir
		original_git_dir = nil
		print("Switched to Git repository")
	else
		original_git_dir = vim.env.GIT_DIR or nil
		vim.env.GIT_DIR = yadm_git_dir
		print("Switched to Yadm repository")
	end
end

-- SWITCH TO YADM REPO
local function cmdInDotfiles(cmd)
	local original_git_dir = vim.env.GIT_DIR
	local home_dir = vim.fn.expand("~")
	local git_dir = vim.fn.expand("~/.local/share/yadm/repo.git")

	vim.env.GIT_DIR = git_dir
	cmd(home_dir)
	vim.schedule(function()
		vim.env.GIT_DIR = original_git_dir
	end)
end

--------------------
-----DASHBOARD------
--------------------

-- SYSTEM UTILS
local function term_cmd(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+$", "")
end

local function make_graph(percent, width)
	percent = tonumber(percent) or 0
	if percent ~= percent then
		percent = 0
	end
	width = width or 20
	if percent > 100 then
		return string.rep("󰨔", width)
	end
	local filled = math.floor((percent / 100) * width)
	return string.rep("■", filled) .. string.rep("□", width - filled)
end

-- GET OS
local function get_os()
	local uname = term_cmd("uname")
	local is_wsl = uname
		and (term_cmd("cat /proc/version"):match("Microsoft") or term_cmd("cat /proc/version"):match("WSL"))
	if is_wsl then
		uname = "WSL"
	end
	return uname
end

-- OS VERSION
local function os_version()
	local uname = get_os()
	if uname == "Linux" or "WSL" then
		local linux_name = term_cmd("lsb_release -is"):lower()
		if linux_name == "" then
			linux_name = term_cmd("cat /etc/os-release | grep '^ID=' | cut -d '=' -f2"):lower()
		end

		local os_pretty_name = term_cmd("lsb_release -ds")
		if os_pretty_name == "" then
			os_pretty_name = term_cmd("cat /etc/os-release | grep '^PRETTY_NAME=' | cut -d '\"' -f2")
		end

		local icon = "" -- default Linux icon
		if linux_name:find("ubuntu") then
			icon = ""
		elseif linux_name:find("debian") then
			icon = ""
		elseif linux_name:find("arch") then
			icon = "󰣇"
		end

		return icon .. " " .. (os_pretty_name ~= "" and os_pretty_name or "Linux")
	elseif uname == "Darwin" then
		local name = term_cmd("sw_vers -productName")
		local version = term_cmd("sw_vers -productVersion")
		return " " .. name .. " " .. version
	end
	return " Unknown OS"
end

-- NEOVIM VERSION
local function vim_version()
	return " " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
end

-- NEOVIDE VERSION
local function neovide_version()
	if vim.g.neovide then
		return " | 󰏌 " .. vim.g.neovide_version
	end
	return ""
end

-- CPU
local cpu_load = tonumber(term_cmd("uptime"):match("load averages?:%s*([%d%.]+)")) or 0

-- RAM
local function ram()
	if get_os() == "Linux" or "WSL" then
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

-- SWAP
local function swap()
	if get_os() == "Linux" or "WSL" then
		local memory_output = term_cmd("free -m | awk '/Swap:/ {print $3, $2}'")
		local used_mb, total_mb = memory_output:match("(%d+)%s+(%d+)")
		return tonumber(used_mb), tonumber(total_mb)
	end
	local swap_output = term_cmd("sysctl vm.swapusage")
	local total = tonumber(swap_output:match("total = ([%d%.]+)M"))
	local used = tonumber(swap_output:match("used = ([%d%.]+)M"))
	return math.floor(used), math.floor(total)
end

-- DISK
local function disk()
	local uname = get_os()
	local flag = "-H"
	if uname == "Linux" or "WSL" then
		flag = "-h"
	end
	local mount_path = "/"
	if uname == "WSL" then
		mount_path = "/mnt/c"
	elseif uname == "Darwin" then
		mount_path = "/System/Volumes/Data"
	end
	local used, total = term_cmd("df " .. flag .. " " .. mount_path .. " | awk 'NR==2 {print $3, $2}'"):match(
		"([%d%.]+)[GMKTB]?%s+([%d%.]+)[GMKTB]?"
	)
	return math.floor(tonumber(used or 0) + 0.5), math.floor(tonumber(total or 1) + 0.5)
end

-- UPTIME
local function uptime()
	local boot_time, boot_date

	if get_os() == "Linux" or "WSL" then
		boot_date = term_cmd("uptime -s")
		local y, m, d = boot_date:match("(%d+)-(%d+)-(%d+)")
		boot_time = os.time({ year = y, month = m, day = d })
	else
		local boot_sec = term_cmd("sysctl -n kern.boottime"):match("sec%s*=%s*(%d+)")
		boot_time = tonumber(boot_sec)
		boot_date = os.date("%Y-%m-%d %H:%M:%S", boot_time)
	end

	local current_time = os.time(os.date("*t"))
	local days_since_boot = math.floor(os.difftime(current_time, boot_time) / 86400)
	local uptime_percentage = math.min(days_since_boot / 14, 1) * 100

	return boot_date, uptime_percentage
end

-- BATTERY
local function battery_percentage()
	local output = term_cmd([[
		for d in /sys/class/power_supply/*; do
			case "$d" in */BAT*|*/CMD*|*/battery*)
				[ -f "$d/capacity" ] && cat "$d/capacity" && exit
			esac
		done
		pmset -g batt | grep -Eo '\d+%' | head -1 | tr -d '%'
	]])
	return tonumber(output and output:match("%d+")) or 0
end

local function battery_status()
	local status = term_cmd([[
		(for d in /sys/class/power_supply/*; do
			case "$d" in */BAT*|*/CMD*|*/battery*)
				[ -f "$d/status" ] && cat "$d/status" && break
			esac
		done) || pmset -g batt | grep 'AC Power'
	]])

	return status and status:match("Charging") or status:match("AC Power") or false
end

local function battery_icon(capacity, battery_status)
	if battery_status then
		return "󰂄"
	end

	local index = math.floor(capacity / 10) + 1
	local capacity_icons = {
		"󰂎",
		"󰁺",
		"󰁻",
		"󰁼",
		"󰁽",
		"󰁾",
		"󰁿",
		"󰂀",
		"󰂁",
		"󰂂",
		"󰁹",
	}
	if index > #capacity_icons then
		index = #capacity_icons
	end
	return capacity_icons[index]
end

-- PROCESSES
local function processes()
	if get_os() == "Linux" or "WSL" then
		return term_cmd("ps -e --no-headers | wc -l")
	end
	return term_cmd("ps ax | wc -l | awk '{print $1}'")
end

-- IP ADDRESS
local function ip_address()
	if get_os() == "Linux" or "WSL" then
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
local ram_percent = ram_used / ram_total * 100
local swap_used, swap_total = swap()
local swap_percent = swap_used / swap_total * 100
local disk_used, disk_total = disk()
local disk_percent = disk_used / disk_total * 100
local uptime_date, uptime_percent = uptime()

-- SYSTEM INFO BOX
local system_info = {
	"╭────────┬─────────────────────────────────────────╮",
	string.format("│ CPU    │ %-16s %s │", cpu_load .. "%", " " .. make_graph(cpu_load)),
	string.format(
		"│ RAM    │ %-16s %s │",
		ram_used .. "/" .. ram_total .. "MB",
		" " .. make_graph(ram_percent)
	),
	string.format(
		"│ SWAP   │ %-16s %s │",
		swap_used .. "/" .. swap_total .. "MB",
		"󰯍 " .. make_graph(swap_percent)
	),
	string.format(
		"│ DISK   │ %-16s %s │",
		disk_used .. "/" .. disk_total .. "GB",
		"󰨆 " .. make_graph(disk_percent)
	),
	string.format("│ UPTIME │ %-22s %s │", uptime_date, "󰃭 " .. make_graph(uptime_percent, 14)),
	string.format(
		"│ MORE   │ %-12s %3s %-7s %22s │",
		battery_icon(battery_percentage(), battery_status()) .. " " .. battery_percentage() .. "%",
		" " .. term_cmd("who | awk '{print $1}' | sort -u | wc -l | awk '{print $1}'"),
		" " .. processes(),
		"󰍸 " .. ip_address()
	),
	"╰────────┴─────────────────────────────────────────╯",
}

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
				if not vim.g.neovide then
					vim.b.minianimate_disable = not vim.b.minianimate_disable
					require("smear_cursor").toggle()
				end
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
				cmdInDotfiles(function(home_dir)
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
			"<leader>ga",
			function()
				vim.cmd({
					cmd = "!",
					args = { "git", "add", vim.fn.expand("%:p") },
				})
			end,
			desc = "Add file",
			silent = true,
		},
		{
			"<leader>gD",
			function()
				vim.cmd({
					cmd = "!",
					args = { "git", "rm", "--cached", vim.fn.expand("%:p") },
				})
			end,
			desc = "Remove file",
			silent = true,
		},
		{
			"<leader>gy",
			function()
				switchRepo()
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
	opts = function()
		local header
		if vim.g.neovide then
			header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗██████╗ ███████╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║██╔══██╗██╔════╝
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██║  ██║█████╗
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║  ██║██╔══╝
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██████╔╝███████╗
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═════╝ ╚══════╝]]
		else
			header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]
		end
		return {
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				preset = {
					header = header
						.. "\n\n"
						.. os_version()
						.. " | "
						.. vim_version()
						.. neovide_version()
						.. "\n"
						.. table.concat(system_info, "\n")
						.. "\n"
						.. os.date(),
					keys = {
						{ icon = " ", key = "n", desc = "New File", action = ":ene" },
						{
							icon = "󰥨 ",
							key = "f",
							desc = "Find File",
							action = function()
								Snacks.dashboard.pick("files")
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
								cmdInDotfiles(function(home_dir)
									Snacks.dashboard.pick("git_files", { cwd = home_dir })
								end)
							end,
						},
						{
							icon = " ",
							key = "l",
							desc = "Lazy Config",
							action = function()
								Snacks.picker.lazy()
							end,
						},
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
		}
	end,
}
