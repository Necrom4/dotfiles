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

		-- Load in-project .overseer.lua files and register their templates scoped to their directories
		local function load_file(filepath)
			local ok, tpl = pcall(dofile, filepath)
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

		-- Find .overseer.lua files from cwd upward, load new ones
		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			callback = function()
				for _, file in
					ipairs(vim.fs.find(".overseer.lua", {
						upward = true,
						type = "file",
						path = vim.fn.getcwd(),
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
