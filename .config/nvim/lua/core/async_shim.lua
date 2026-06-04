-- =============================================================================
-- async module disambiguation shim
-- =============================================================================
-- WHY THIS EXISTS:
--   Two plugins ship a top-level `lua/async.lua`:
--     * kevinhwang91/promise-async  (dependency of nvim-ufo / fundo)
--     * lewis6991/async.nvim        (dependency of refactoring.nvim)
--   Neovim's module path is flat, so `require("async")` resolves to whichever
--   appears first on runtimepath -- the other plugin then gets the wrong impl
--   and breaks. There is no namespacing in Lua module resolution to fix this
--   cleanly, so we intercept `require("async")` and dispatch on the CALLER.
--
--   This is a workaround. The correct fix is upstream: one of the two plugins
--   renaming its bare `async` module to a namespaced one. Track:
--     https://github.com/LazyVim/LazyVim/issues/7130
--   Remove this file once that lands.
--
-- HOW IT WORKS:
--   We wrap the global `require`. For every module name OTHER than "async" we
--   delegate untouched. For "async" we walk the call stack to find which plugin
--   is asking, then load that plugin's async.lua directly by file path (via
--   loadfile), bypassing name-based resolution entirely. Each impl is loaded
--   from disk at most once and memoized.
-- =============================================================================

-- Idempotency guard: re-sourcing config must not wrap an already-wrapped
-- require (that would stack wrappers and slow every require call).
if _G.__async_shim_installed then
	return
end
_G.__async_shim_installed = true

local data = vim.fn.stdpath("data")

-- Resolve each plugin's async.lua path. If you use a plugin manager other than
-- lazy.nvim, or custom install dirs, adjust the "/lazy/<name>/..." segments.
local paths = {
	async_nvim = data .. "/lazy/async.nvim/lua/async.lua",
	promise = data .. "/lazy/promise-async/lua/async.lua",
}

-- Cache of loaded implementations (keyed by the `paths` key above).
local loaded = {}

local function load(kind)
	if loaded[kind] == nil then
		local path = paths[kind]
		-- Verify the file exists before trying to load it; gives a clear error
		-- instead of a cryptic one if a plugin dir was renamed/removed.
		if vim.fn.filereadable(path) ~= 1 then
			error(
				("async_shim: expected file not readable: %s\n"):format(path)
					.. "Check the plugin install path in lua/config/async_shim.lua."
			)
		end
		local chunk, err = loadfile(path)
		if not chunk then
			error(("async_shim: failed to load %s: %s"):format(path, err))
		end
		loaded[kind] = chunk()
	end
	return loaded[kind]
end

-- Map a caller's source path (substring match) to which impl it needs.
-- Order matters only in that the FIRST match on the stack wins. Add a line
-- here for any new plugin that requires a bare "async". `plain = true` on
-- string.find means the needle is literal -- no Lua-pattern escaping needed,
-- so "-" and "." are safe as-is.
local dispatch = {
	-- consumers of lewis6991/async.nvim:
	{ needle = "refactoring.nvim", kind = "async_nvim" },
	-- consumers of kevinhwang91/promise-async:
	{ needle = "promise-async", kind = "promise" },
	{ needle = "nvim-ufo", kind = "promise" },
	{ needle = "fundo", kind = "promise" },
}

-- Fallback when no caller on the stack matched. Pick the impl most of your
-- UNattributed `require("async")` calls expect. Most direct calls come from
-- the plugins above (which DO match), so this rarely triggers.
local DEFAULT_KIND = "async_nvim"

local orig_require = _G.require

_G.require = function(modname, ...)
	if modname ~= "async" then
		return orig_require(modname, ...)
	end

	-- Walk up the stack looking for a frame whose source identifies the caller.
	-- Start at level 2 (skip this wrapper itself). Cap the walk to keep it cheap
	-- and bounded; the contested require almost always happens at plugin
	-- load/setup time with a shallow, clean stack.
	for lvl = 2, 24 do
		local info = debug.getinfo(lvl, "S")
		if not info then
			break
		end
		local src = info.source or ""
		for _, rule in ipairs(dispatch) do
			if src:find(rule.needle, 1, true) then
				return load(rule.kind)
			end
		end
	end

	return load(DEFAULT_KIND)
end
