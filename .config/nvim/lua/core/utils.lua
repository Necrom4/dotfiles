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

-- CHECK YADM
function M.is_yadm_cwd(path)
	local home = vim.fn.expand("~")
	local config = home .. "/.config"

	path = path or vim.fn.getcwd()

	if path == home or path:sub(1, #config) == config then
		return true
	end

	return false
end

function M.is_yadm_file(path)
	local home = vim.fn.expand("~")
	local repo = home .. "/.local/share/yadm/repo.git"

	path = path or vim.fn.getcwd()

	if vim.fn.filereadable(path) == 1 then
		vim.fn.systemlist({
			"yadm",
			"--yadm-repo",
			repo,
			"ls-files",
			"--error-unmatch",
			path,
		})
		return vim.v.shell_error == 0
	end

	return false
end

function M.is_yadm(path)
	if M.is_yadm_cwd(path) or M.is_yadm_file(path) then
		return true
	end

	return false
end

return M
