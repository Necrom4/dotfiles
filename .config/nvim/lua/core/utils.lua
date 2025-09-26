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

-- YADM
function M.is_yadm_repo(path)
	local home = vim.fn.expand("~")
	local config = home .. "/.config"

	path = path or vim.fn.getcwd()

	if path == home or path:sub(1, #config) == config then
		return true
	end

	return false
end

function M.is_yadm(path)
	if M.is_yadm_repo(path) or vim.b.yadm_tracked then
		return true
	end

	return false
end

M.original_git_dir = nil

function M.switch_git_dir()
	local yadm_repo = vim.fn.expand("~/.local/share/yadm/repo.git")

	if vim.env.GIT_DIR == yadm_repo then
		vim.env.GIT_DIR = M.original_git_dir
		M.original_git_dir = nil
		print("In Project Repo")
	else
		M.original_git_dir = vim.env.GIT_DIR or nil
		vim.env.GIT_DIR = yadm_repo
		print("In Yadm Repo")
	end
end

function M.cmd_in_yadm(cmd)
	local original_git_dir = vim.env.GIT_DIR
	local home = vim.fn.expand("~")
	local git_dir = vim.fn.expand("~/.local/share/yadm/repo.git")

	vim.env.GIT_DIR = git_dir
	cmd(home)
	vim.schedule(function()
		vim.env.GIT_DIR = original_git_dir
	end)
end

return M
