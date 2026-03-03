local M = {}

-- EXECUTE TERM CMD
function M.term_cmd(cmd)
	local wrapped_cmd = { "sh", "-c", cmd }
	return vim.fn.system(wrapped_cmd):gsub("%s+$", "")
end

-- GET OS (memoized -- OS does not change during a session)
local _system_type_cache = nil

function M.system_type()
	if _system_type_cache then
		return _system_type_cache
	end

	if vim.fn.has("wsl") == 1 then
		_system_type_cache = "wsl"
	else
		local sysname = (vim.uv or vim.loop).os_uname().sysname:lower()

		if sysname:find("darwin") then
			_system_type_cache = "darwin"
		elseif sysname:find("windows") then
			_system_type_cache = "windows"
		elseif sysname:find("linux") then
			_system_type_cache = "linux"
		else
			_system_type_cache = "unknown"
		end
	end

	return _system_type_cache
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
	local yadm_repo = vim.fn.expand("$HOME/.local/share/yadm/repo.git")

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

function M.in_yadm_env(fn)
	local original_git_dir = vim.env.GIT_DIR
	local original_git_work_tree = vim.env.GIT_WORK_TREE
	local home = vim.fn.expand("$HOME")

	vim.env.GIT_DIR = home .. "/.local/share/yadm/repo.git"
	vim.env.GIT_WORK_TREE = home

	local result = fn(home)

	vim.schedule(function()
		vim.env.GIT_DIR = original_git_dir
		vim.env.GIT_WORK_TREE = original_git_work_tree
	end)

	return result
end

return M
