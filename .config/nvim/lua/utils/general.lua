local M = {}

function M.on_very_lazy(fn)
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = fn,
	})
end

-- EXECUTE TERM CMD
function M.term_cmd(cmd)
	local wrapped_cmd = { "sh", "-c", cmd }
	return vim.fn.system(wrapped_cmd):gsub("%s+$", "")
end

function M.yadm_config(key)
	local home = vim.fn.expand("$HOME")
	local git_dir = home .. "/.local/share/yadm/repo.git"

	return M.term_cmd(
		string.format(
			"GIT_DIR=%s GIT_WORK_TREE=%s git config %s",
			vim.fn.shellescape(git_dir),
			vim.fn.shellescape(home),
			vim.fn.shellescape(key)
		)
	)
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
		local sysname = vim.uv.os_uname().sysname:lower()

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

	if path == home or path == config or vim.startswith(path, config .. "/") then
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

function M.pick_yadm_files()
	local home = vim.fn.expand("$HOME")

	Snacks.dashboard.pick("git_files", {
		cwd = home,
		args = { "--git-dir=" .. home .. "/.local/share/yadm/repo.git", "--work-tree=" .. home },
	})
end

-- MANIFESTS
-- A missing manifest is fine (not every class has one), but errors inside one must surface.
function M.manifest(name)
	local module = "manifests." .. name
	local ok, result = pcall(require, module)

	if ok then
		assert(type(result) == "table", module .. " must return a table")
		return result
	end

	if type(result) == "string" and vim.startswith(result, "module '" .. module .. "' not found:") then
		return {}
	end

	error(result, 0)
end

return M
