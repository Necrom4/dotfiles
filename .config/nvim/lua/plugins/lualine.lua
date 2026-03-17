local function scrollbar()
	local sbar = { "▔", "🭶", "🭷", "🭸", "🭹", "🭺", "🭻", "▁" }
	local curr_line = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_line_count(0)
	local i = math.floor((curr_line - 1) / lines * #sbar) + 1
	return string.rep(sbar[i], 2)
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	init = function()
		vim.g.lualine_laststatus = vim.o.laststatus
		if vim.fn.argc(-1) > 0 then
			-- set an empty statusline till lualine loads
			vim.o.statusline = " "
		else
			-- hide the statusline on the starter page
			vim.o.laststatus = 0
		end
	end,
	opts = function()
		-- PERF: we don't need this lualine require madness 🤷
		local lualine_require = require("lualine_require")
		lualine_require.require = require

		local icons = LazyVim.config.icons

		vim.o.laststatus = vim.g.lualine_laststatus

		local opts = {
			options = {
				theme = "auto",
				globalstatus = vim.o.laststatus == 3,
				disabled_filetypes = {
					statusline = { "alpha", "dashboard", "ministarter", "snacks_dashboard" },
					winbar = {
						"aerial",
						"alpha",
						"dashboard",
						"help",
						"lir",
						"neogitstatus",
						"NvimTree",
						"Outline",
						"packer",
						"snacks_dashboard",
						"spectre_panel",
						"startify",
						"toggleterm",
						"Trouble",
						"undotree",
					},
				},
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							if vim.o.columns < 100 then
								return str:sub(1, 1)
							end
							return str
						end,
					},
				},
				lualine_b = {
					{
						"branch",
						fmt = function(str)
							local max_len = 23

							-- 1. Standard prefix shortening
							str = str:gsub("^feature/", "feat/")
							str = str:gsub("^bugfix/", "fix/")
							str = str:gsub("^hotfix/", "hfx/")
							str = str:gsub("^release/", "rls/")
							str = str:gsub("^refactor/", "rfct/")

							if #str > max_len then
								-- 2. Shortest prefixes
								str = str:gsub("^feat/", "ft/")
								str = str:gsub("^fix/", "fx/")
								str = str:gsub("^rls/", "rl/")
								str = str:gsub("^rfct/", "rf/")

								-- 3. Strip ticket ID
								if #str > max_len then
									str = str:gsub("^(.-/)[A-Za-z]+-[0-9]+[-_]", "%1")
									str = str:gsub("^(.-/)[0-9]+[-_]", "%1")
								end

								-- 4. Hard truncate & add icon
								if #str > max_len then
									str = ("%s"):format(str:sub(1, max_len - 1))
								end
							end

							return str
						end,
						icon = icons.git.branch or "", -- Use a custom icon if LazyVim.config.icons.git.branch is not set
					},
				},

				lualine_c = {
					(function()
						local c = LazyVim.lualine.root_dir()
						local orig = c.cond
						c.cond = function()
							return vim.o.columns > 80 and (not orig or orig())
						end
						return c
					end)(),
					{
						LazyVim.lualine.pretty_path(),
						separator = "",
						padding = { left = 1, right = 0 },
					},
					{
						"filetype",
						icon_only = true,
						padding = { left = 1, right = 0 },
					},
					{
						"navic",
						cond = function()
							return vim.o.columns > 80
						end,
					},
				},
				lualine_x = {
					Snacks.profiler.status(),
          -- stylua: ignore
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = function() return { fg = Snacks.util.color("Statement") } end,
          },
          -- stylua: ignore
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color("Constant") } end,
          },
          -- stylua: ignore
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = function() return { fg = Snacks.util.color("Debug") } end,
          },
          -- stylua: ignore
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = function() return { fg = Snacks.util.color("Special") } end,
          },
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
						source = function()
							local gitsigns = vim.b.gitsigns_status_dict
							if gitsigns then
								return {
									added = gitsigns.added,
									modified = gitsigns.changed,
									removed = gitsigns.removed,
								}
							end
						end,
						cond = function()
							return vim.o.columns > 80
						end,
					},
					{
						"diagnostics",
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
						cond = function()
							return vim.o.columns > 80
						end,
					},
					{ "overseer" },
					{
						"encoding",
						cond = function()
							return vim.o.columns > 80
						end,
					},
				},
				lualine_y = {
					{ "location" },
					{ "progress", separator = "", padding = { left = 1, right = 1 } },
					{
						scrollbar,
						padding = { left = 0, right = 0 },
						cond = function()
							return vim.o.columns > 80
						end,
					},
				},
				lualine_z = {},
			},
			winbar = {
				lualine_b = {
					{
						"windows",
						show_filename_only = true,
						show_modified_status = true,
						mode = 0,
					},
				},
			},
			inactive_winbar = {
				lualine_b = {
					{
						"windows",
						show_filename_only = true,
						show_modified_status = true,
						mode = 0,
					},
				},
			},
			extensions = { "neo-tree", "lazy", "fzf" },
		}

		return opts
	end,
}
