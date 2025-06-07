local M = {}

-- EXECUTE TERM CMD
function M.term_cmd(cmd)
	local wrapped_cmd = { "sh", "-c", cmd }
	return vim.fn.system(wrapped_cmd):gsub("%s+$", "")
end

-- GET OS
function M.system_type()
	if vim.fn.has("wsl") == 1 then
		return "wsl"
	end

	local sysname = vim.loop.os_uname().sysname:lower()

	if sysname:find("darwin") then
		return "darwin"
	elseif sysname:find("windows") then
		return "windows"
	elseif sysname:find("linux") then
		return "linux"
	else
		return "unknown"
	end
end

return M
