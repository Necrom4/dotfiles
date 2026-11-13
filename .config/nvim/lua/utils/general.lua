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
