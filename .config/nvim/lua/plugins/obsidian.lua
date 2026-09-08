return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	-- Everything below is deferred into `opts`. Previously the yadm `git config`
	-- lookup and the mkdir ran at spec-parse time, i.e. a blocking subprocess on
	-- every single startup, and the `assert` meant an unset `local.class` took
	-- down the whole `{ import = "plugins" }` module rather than just this plugin.
	opts = function()
		local utils = require("utils.general")

		local class = vim.trim(string.lower(utils.yadm_config("local.class")))
		if class == "" then
			vim.notify(
				"obsidian.nvim: yadm config `local.class` is not set; falling back to 'default'",
				vim.log.levels.WARN
			)
			class = "default"
		end

		local vault_path = vim.fn.expand("~/vaults/" .. class)
		if vim.fn.isdirectory(vault_path) == 0 then
			vim.fn.mkdir(vault_path, "p")
		end

		return {
			legacy_commands = false, -- this will be removed in 4.0.0
			ui = {
				enable = false,
			},
			workspaces = {
				{
					name = class,
					path = vault_path,
				},
			},
		}
	end,
	cmd = { "Obsidian" },
	keys = {
		{ "<leader>fo", "<cmd>Obsidian<cr>", desc = "Obsidian" },
	},
}
