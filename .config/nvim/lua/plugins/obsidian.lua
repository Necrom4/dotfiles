local utils = require("utils.general")

local class = utils.in_yadm_env(function()
	return utils.term_cmd("git config local.class")
end)

class = vim.trim(string.lower(class))
assert(class ~= "", "yadm config local.class is not set")

local vault_path = vim.fn.expand("~/vaults/" .. class)

if vim.fn.isdirectory(vault_path) == 0 then
	vim.fn.mkdir(vault_path, "p")
end

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	opts = {
		legacy_commands = false, -- this will be removed in 4.0.0
		workspaces = {
			{
				name = class,
				path = vault_path,
			},
		},
	},
}
