local utils = require("core.utils")
local system_type = utils.system_type()

--------------------
-----DASHBOARD------
--------------------

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

-- WSL VERSION
local function wsl_version()
	if system_type == "wsl" then
		return "󰖳 WSL "
			.. utils.term_cmd(
				"wsl.exe -v 2>&1 | iconv -f UTF-16LE -t UTF-8 | grep 'WSL version' | cut -d ':' -f2 | xargs"
			)
			.. " | "
	end
	return ""
end

-- OS VERSION
local function os_version()
	local uname = system_type
	if uname ~= "darwin" then
		local linux_name = utils.term_cmd("lsb_release -is"):lower()
		if linux_name == "" then
			linux_name = utils.term_cmd("cat /etc/os-release | grep '^ID=' | cut -d '=' -f2"):lower()
		end

		local os_pretty_name = utils.term_cmd("lsb_release -ds")
		if os_pretty_name == "" then
			os_pretty_name = utils.term_cmd("cat /etc/os-release | grep '^PRETTY_NAME=' | cut -d '\"' -f2")
		end

		local icon = "" -- default Linux icon
		if linux_name:find("ubuntu") then
			icon = ""
		elseif linux_name:find("debian") then
			icon = ""
		elseif linux_name:find("arch") then
			icon = "󰣇"
		end

		return icon .. " " .. (os_pretty_name ~= "" and os_pretty_name or "linux")
	else
		local name = utils.term_cmd("sw_vers -productName")
		local version = utils.term_cmd("sw_vers -productVersion")
		return " " .. name .. " " .. version
	end
end

-- NEOVIM VERSION
local function vim_version()
	return " " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
end

-- NEOVIDE VERSION
local function neovide_version()
	if vim.g.neovide then
		return " |  " .. vim.g.neovide_version
	end
	return ""
end

-- CPU
local cpu_load = tonumber(utils.term_cmd("uptime"):match("load averages?:%s*([%d%.]+)")) or 0

-- RAM
local function ram()
	if system_type ~= "darwin" then
		local memory_output = utils.term_cmd("free -m | awk '/Mem:/ {print $3, $2}'")
		local used_mb, total_mb = memory_output:match("(%d+)%s+(%d+)")
		return tonumber(used_mb), tonumber(total_mb)
	end
	local page_size = 4096
	local active_pages = tonumber(utils.term_cmd("vm_stat | grep 'Pages active'"):match("(%d+)")) or 0
	local inactive_pages = tonumber(utils.term_cmd("vm_stat | grep 'Pages inactive'"):match("(%d+)")) or 0
	local wired_pages = tonumber(utils.term_cmd("vm_stat | grep 'Pages wired down'"):match("(%d+)")) or 0
	local memsize_str = utils.term_cmd("sysctl -n hw.memsize"):gsub("[^%d]", "")
	local total_bytes = tonumber(memsize_str) or (8 * 1024 ^ 3)
	local used_bytes = (active_pages + inactive_pages + wired_pages) * page_size
	local used_mb = used_bytes / 1024 ^ 2
	local total_mb = total_bytes / 1024 ^ 2
	return math.floor(used_mb), math.floor(total_mb)
end

-- SWAP
local function swap()
	if system_type ~= "darwin" then
		local memory_output = utils.term_cmd("free -m | awk '/Swap:/ {print $3, $2}'")
		local used_mb, total_mb = memory_output:match("(%d+)%s+(%d+)")
		return tonumber(used_mb), tonumber(total_mb)
	end
	local swap_output = utils.term_cmd("sysctl vm.swapusage")
	local total = tonumber(swap_output:match("total = ([%d%.]+)M"))
	local used = tonumber(swap_output:match("used = ([%d%.]+)M"))
	return math.floor(used), math.floor(total)
end

-- DISK
local function disk()
	local uname = system_type
	local flag = "-H"
	if uname ~= "darwin" then
		flag = "-h"
	end
	local mount_path = "/"
	if uname == "wsl" then
		mount_path = "/mnt/c"
	elseif uname == "darwin" then
		mount_path = "/System/Volumes/Data"
	end
	local used, total = utils
		.term_cmd("df " .. flag .. " " .. mount_path .. " | awk 'NR==2 {print $3, $2}'")
		:match("([%d%.]+)[GMKTB]?%s+([%d%.]+)[GMKTB]?")
	return math.floor(tonumber(used or 0) + 0.5), math.floor(tonumber(total or 1) + 0.5)
end

-- UPTIME
local function uptime()
	local boot_time, boot_date

	if system_type ~= "darwin" then
		boot_date = utils.term_cmd("uptime -s")
		local y, m, d = boot_date:match("(%d+)-(%d+)-(%d+)")
		boot_time = os.time({ year = y, month = m, day = d })
	else
		local boot_sec = utils.term_cmd("sysctl -n kern.boottime"):match("sec%s*=%s*(%d+)")
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
	local output = utils.term_cmd([[
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
	if system_type ~= "darwin" then
		local status = utils.term_cmd([[
      (for d in /sys/class/power_supply/*; do
        case "$d" in */BAT*|*/CMD*|*/battery*)
          [ -f "$d/status" ] && cat "$d/status" && break
        esac
      done) || pmset -g batt | grep 'AC Power'
    ]])

		if not status then
			return false
		end
		return status and status:match("Charging") or status:match("AC Power") or false
	else
		local status = utils.term_cmd("pmset -g batt")
		if not status then
			return false
		end

		return status and status:match(" charging") or status:match("AC Power") or false
	end
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
	if system_type ~= "darwin" then
		return utils.term_cmd("ps -e --no-headers | wc -l")
	end
	return utils.term_cmd("ps ax | wc -l | awk '{print $1}'")
end

-- IP ADDRESS
local function ip_address()
	if system_type ~= "darwin" then
		return utils.term_cmd("hostname -I | awk '{print $1}'")
	end
	local ip = utils.term_cmd("ipconfig getifaddr en0")
	if ip == "" then
		ip = utils.term_cmd("ipconfig getifaddr en1")
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
		"│  │ %-12s %3s %-7s %22s │",
		battery_icon(battery_percentage(), battery_status()) .. " " .. battery_percentage() .. "%",
		" " .. utils.term_cmd("who | awk '{print $1}' | sort -u | wc -l | awk '{print $1}'"),
		" " .. processes(),
		"󰍸 " .. ip_address()
	),
	"╰────────┴─────────────────────────────────────────╯",
}

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
		{ "<leader>uC", false },
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
				utils.cmd_in_yadm(function(yadm_repo)
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
	},
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			enabled = true,
			preset = {
				header = header
					.. "\n\n"
					.. wsl_version()
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
							utils.cmd_in_yadm(function(yadm_repo)
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
}
