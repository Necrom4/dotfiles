local M = {}

-- EXECUTE TERM CMD
function M.term_cmd(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result:gsub("%s+$", "")
end

-- GET OS
function M.system_type()
	local uname = vim.loop.os_uname()

	if uname.sysname == "Darwin" then
		return "darwin"
	elseif uname.sysname == "Linux" then
		local is_wsl = vim.fn.has("wsl") == 1
			or uname.release:lower():match("microsoft")
			or uname.version:lower():match("microsoft")
		if is_wsl then
			return "wsl"
		else
			return "linux"
		end
	else
		return "unknown"
	end
end

return M
