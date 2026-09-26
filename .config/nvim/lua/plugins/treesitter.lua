local languages = {
	"css",
	"csv",
	"embedded_template",
	"lua_patterns",
	"make",
	"passwd",
	"pkl",
	"scss",
	"sql",
	"ssh_config",
	"styled",
	"superhtml",
	"tsv",
	"vhs",
	"xml",
	"zsh",
}

vim.list_extend(languages, require("utils.general").manifest("languages"))

return {
	"nvim-treesitter/nvim-treesitter",
	-- Custom parsers must be registered before LazyVim's config installs ensure_installed,
	-- which can run before config/autocmds.lua is loaded on VeryLazy.
	init = function()
		-- Queries cannot see the filetype; used by after/queries/jinja/injections.scm.
		vim.treesitter.query.add_predicate("buf-filetype?", function(_, _, source, predicate)
			return type(source) == "number" and vim.bo[source].filetype == predicate[2]
		end, { force = true })

		vim.api.nvim_create_autocmd("User", {
			pattern = "TSUpdate",
			callback = function()
				require("nvim-treesitter.parsers").lua_patterns = {
					install_info = {
						url = "https://github.com/OXY2DEV/tree-sitter-lua_patterns",
					},
				}
			end,
		})
	end,
	opts = {
		ensure_installed = languages,
	},
}
