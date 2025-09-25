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

function M.is_yadm_file(file)
	local home = vim.fn.expand("~")
	local config = home .. "/.config"
	local repo = home .. "/.local/share/yadm/repo.git"

	file = file or vim.fn.getcwd()

	if file == home or file:sub(1, #config) == config then
		return true
	end

	if vim.fn.filereadable(file) == 1 then
		vim.fn.systemlist({
			"yadm",
			"--yadm-repo",
			repo,
			"ls-files",
			"--error-unmatch",
			file,
		})
		return vim.v.shell_error == 0
	end

	return false
end

return M
