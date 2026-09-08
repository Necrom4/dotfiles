local function searchcount()
	if vim.v.hlsearch == 0 then
		return ""
	end
	local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 500 })
	if not ok or not result.total or result.total == 0 then
		return ""
	end
	if result.incomplete == 1 then
		return "?/?"
	elseif result.incomplete == 2 then
		return ("%d/>%d"):format(result.current, result.total)
	end
	return ("%d/%d"):format(result.current, result.total)
end

local function scrollbar()
	local sbar = { "▔", "🭶", "🭷", "🭸", "🭹", "🭺", "🭻", "▁" }
	local curr_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_line_count(0)
	local i = math.floor((curr_line - 1) / lines * #sbar) + 1
	return string.rep(sbar[i], 2)
end

-- Shorten long branch names so the statusline does not get pushed around.
local function short_branch(str)
	local max_len = 23

	str = str:gsub("^feature/", "feat/")
	str = str:gsub("^bugfix/", "fix/")
	str = str:gsub("^hotfix/", "hfx/")
	str = str:gsub("^release/", "rls/")
	str = str:gsub("^refactor/", "rfct/")

	if #str > max_len then
		str = str:gsub("^feat/", "ft/")
		str = str:gsub("^fix/", "fx/")
		str = str:gsub("^rls/", "rl/")
		str = str:gsub("^rfct/", "rf/")

		-- Strip a leading ticket ID (ABC-123- or 123-)
		if #str > max_len then
			str = str:gsub("^(.-/)[A-Za-z]+-[0-9]+[-_]", "%1")
			str = str:gsub("^(.-/)[0-9]+[-_]", "%1")
		end

		if #str > max_len then
			str = ("%s"):format(str:sub(1, max_len - 1))
		end
	end

	return str
end

-- Several components are only worth the horizontal space on a wide window.
local function wide()
	return vim.o.columns > 80
end

return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		-- Mode: single letter when narrow.
		opts.sections.lualine_a = {
			{
				"mode",
				fmt = function(str)
					return vim.o.columns < 100 and str:sub(1, 1) or str
				end,
			},
		}

		-- Branch: shortened.
		opts.sections.lualine_b = {
			{ "branch", fmt = short_branch, icon = LazyVim.config.icons.git.branch or "" },
		}

		-- Only the root dir and the diagnostics counts are gated on width; the
		-- filename and filetype icon must always be visible.
		local function gate_on_width(section, matches)
			for _, component in ipairs(section) do
				if type(component) == "table" and matches(component) then
					local orig = component.cond
					component.cond = function()
						return wide() and (not orig or orig())
					end
				end
			end
		end

		-- root_dir is the first entry upstream, and is the one component here
		-- without a string name to match on.
		gate_on_width(opts.sections.lualine_c, function(component)
			return component == opts.sections.lualine_c[1] or component[1] == "diagnostics"
		end)

		-- navic breadcrumbs after the path.
		table.insert(opts.sections.lualine_c, { "navic", cond = wide })

		gate_on_width(opts.sections.lualine_x, function(component)
			return component[1] == "diff"
		end)
		vim.list_extend(opts.sections.lualine_x, {
			{ "overseer" },
			{ "encoding", cond = wide },
		})

		-- Search count + a two-cell scroll indicator; drop upstream's clock.
		opts.sections.lualine_y = {
			{
				searchcount,
				color = function()
					return { fg = Snacks.util.color("Number") }
				end,
			},
			{ "location" },
			{ "progress", separator = "", padding = { left = 1, right = 1 } },
			{ scrollbar, padding = { left = 0, right = 0 }, cond = wide },
		}
		opts.sections.lualine_z = {}

		-- Per-window filename list in the winbar.
		local windows = {
			lualine_b = {
				{ "windows", show_filename_only = true, show_modified_status = true, mode = 0 },
			},
		}
		opts.winbar = windows
		opts.inactive_winbar = vim.deepcopy(windows)

		opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
		opts.options.disabled_filetypes.winbar = {
			"aerial",
			"dashboard",
			"help",
			"neogitstatus",
			"Outline",
			"snacks_dashboard",
			"toggleterm",
			"Trouble",
			"undotree",
		}

		opts.extensions = { "lazy", "aerial", "overseer", "quickfix", "man", "trouble" }

		return opts
	end,
}
