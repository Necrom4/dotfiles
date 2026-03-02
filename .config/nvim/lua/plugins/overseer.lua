return {
	"stevearc/overseer.nvim",
	opts = {
		form = {
			border = "rounded",
			win_opts = { winblend = 0 },
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		-- Load all tasks from .overseer.nvim/<task>.lua at the git root
		local function load_project_tasks()
			local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
			if not git_root or git_root == "" or vim.v.shell_error ~= 0 then
				return
			end

			local cwd = vim.fn.getcwd()
			if not vim.startswith(cwd, git_root) then
				return
			end

			local dirs_to_scan = { git_root }
			if cwd ~= git_root then
				table.insert(dirs_to_scan, cwd)
			end

			local function load_from_dir(dir)
				local task_dir = dir .. "/.overseer.nvim"
				local stat = vim.loop.fs_stat(task_dir)
				if not stat or stat.type ~= "directory" then
					return
				end

				local handle = vim.loop.fs_opendir(task_dir, nil, 32)
				if not handle then
					return
				end

				while true do
					local entries = vim.loop.fs_readdir(handle)
					if not entries then
						break
					end
					for _, entry in ipairs(entries) do
						if entry.type == "file" and entry.name:match("%.lua$") then
							local filepath = task_dir .. "/" .. entry.name
							local ok, tpl = pcall(dofile, filepath)
							if ok and type(tpl) == "table" then
								require("overseer").register_template(tpl)
							else
								vim.notify("[overseer] Failed to load: " .. filepath, vim.log.levels.WARN)
							end
						end
					end
				end
				vim.loop.fs_closedir(handle)
			end

			for _, dir in ipairs(dirs_to_scan) do
				load_from_dir(dir)
			end
		end

		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			callback = load_project_tasks,
		})
	end,
}
