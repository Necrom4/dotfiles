local utils = require("core.utils")
local system_type = utils.system_type()

local function gen_graph(percent, width)
	percent = tonumber(percent) or 0
	width = width or 20

	local start_empty, start_filled = "", ""
	local mid_empty, mid_filled = "", ""
	local end_empty, end_filled = "", ""

	if percent <= 0 then
		return start_empty .. string.rep(mid_empty, width - 2) .. end_empty
	end
	if percent >= 100 then
		return start_filled .. string.rep(mid_filled, width - 2) .. end_filled
	end

	local filled = math.floor((percent / 100) * width)
	filled = math.max(1, math.min(filled, width - 1))

	return start_filled .. string.rep(mid_filled, filled - 1) .. string.rep(mid_empty, width - filled - 1) .. end_empty
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
	local mount_path = utils.in_yadm_env(function()
		return utils.term_cmd("git config local.class")
	end) == "42" and "~" or "/"
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

-- IP ADDRESSES
local function local_ip_address()
	if system_type ~= "darwin" then
		return utils.term_cmd("hostname -I | awk '{print $1}'")
	end
	local ip = utils.term_cmd("ipconfig getifaddr en0")
	if ip == "" then
		ip = utils.term_cmd("ipconfig getifaddr en1")
	end
	return ip ~= "" and ip or "N/A"
end

local function public_ip_address()
	return utils.term_cmd("curl -s4 ifconfig.me")
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
	string.format("│ CPU    │ %-16s %s │", cpu_load .. "%", " " .. gen_graph(cpu_load)),
	string.format(
		"│ RAM    │ %-16s %s │",
		ram_used .. "/" .. ram_total .. "MB",
		" " .. gen_graph(ram_percent)
	),
	string.format(
		"│ SWAP   │ %-16s %s │",
		swap_used .. "/" .. swap_total .. "MB",
		"󰯍 " .. gen_graph(swap_percent)
	),
	string.format(
		"│ DISK   │ %-16s %s │",
		disk_used .. "/" .. disk_total .. "GB",
		" " .. gen_graph(disk_percent)
	),
	string.format("│ UPTIME │ %-20s  %-20s │", uptime_date, "󰩠 " .. local_ip_address()),
	string.format(
		"│  │ %-27s  %-19s │",
		battery_icon(battery_percentage(), battery_status())
			.. " "
			.. battery_percentage()
			.. "%"
			.. "  "
			.. " "
			.. utils.term_cmd("who | awk '{print $1}' | sort -u | wc -l | awk '{print $1}'")
			.. "  "
			.. " "
			.. processes(),
		" " .. public_ip_address()
	),
	"╰────────┴─────────────────────────────────────────╯",
}

local header = vim.g.neovide
		and [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗██████╗ ███████╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║██╔══██╗██╔════╝
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██║  ██║█████╗
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║  ██║██╔══╝
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██████╔╝███████╗
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═════╝ ╚══════╝]]
	or [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

return {
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

	system_info = system_info,
}
