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

		local loaded = {}

		-- Load in-project .overseer.lua files and register their templates scoped
		-- to their directories.
		--
		-- SECURITY: this executes Lua that ships inside whatever repository you
		-- happen to have opened. It must go through vim.secure.read(), which
		-- prompts once per file and records the decision in the trust database
		-- (see :help vim.secure.read and :trust). A bare dofile() here meant
		-- cloning a hostile repo and opening it was enough to run arbitrary code.
		local function load_file(filepath)
			local contents = vim.secure.read(filepath)
			if type(contents) ~= "string" then
				return -- denied by the user, or not readable
			end

			local chunk, load_err = loadstring(contents, "@" .. filepath)
			if not chunk then
				vim.notify(("overseer: %s: %s"):format(filepath, load_err), vim.log.levels.WARN)
				return
			end

			local ok, tpl = pcall(chunk)
			if not ok or type(tpl) ~= "table" then
				return
			end

			local root = vim.fn.fnamemodify(filepath, ":h")
			for _, t in ipairs(tpl.builder and { tpl } or tpl) do
				t.condition = vim.tbl_extend("keep", t.condition or {}, { dir = root })
				local orig = t.builder
				t.builder = function(p)
					return vim.tbl_extend("keep", orig(p), { cwd = root })
				end
				overseer.register_template(t)
			end
		end

		-- Find .overseer.lua files from cwd upward, load new ones.
		-- The upward walk stops at the project root instead of running all the way
		-- to `/`, so a stray file in a parent directory (or in $HOME) is not picked
		-- up for every unrelated project.
		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			callback = function()
				local cwd = vim.fn.getcwd()
				local stop = LazyVim.root.git() or vim.uv.os_homedir()

				for _, file in
					ipairs(vim.fs.find(".overseer.lua", {
						upward = true,
						type = "file",
						path = cwd,
						stop = vim.fs.dirname(stop),
						limit = math.huge,
					}))
				do
					if not loaded[file] then
						loaded[file] = true
						load_file(file)
					end
				end
			end,
		})
	end,
}
