return {
	{
		"neovim/nvim-lspconfig",
		opts = function()
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			-- disable a keymap
			keys[#keys + 1] = { "K", false }
			keys[#keys + 1] = { "<leader>ss", false }

			local ret = {
				diagnostics = {
					virtual_text = {
						prefix = "",
					},
				},
				inlay_hints = {},
				codelens = {
					enabled = false,
				},
				servers = {},
				setup = {},
			}
			return ret
		end,
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"ast-grep",
				"bash-language-server",
				"checkmake",
				"clang-format",
				"clangd",
				"debugpy",
				"delve",
				"docker-compose-language-service",
				"dockerfile-language-server",
				"eslint-lsp",
				"gofumpt",
				"golangci-lint",
				"gopls",
				"helm-ls",
				"html-lsp",
				"json-lsp",
				"just-lsp",
				"kube-linter",
				"lua-language-server",
				"luacheck",
				"marksman",
				"phpactor",
				"prettierd",
				"pyright",
				"rubocop",
				"ruby-lsp",
				"rubyfmt",
				"ruff",
				"sqls",
				"stylelint",
				"stylelint-lsp",
				"superhtml",
				"taplo",
				"typescript-language-server",
				"vim-language-server",
				"vint",
				"yaml-language-server",
				"yamlfmt",
				"yamllint",
			},
			ui = {
				border = "rounded",
				height = 0.8,
			},
		},
	},
}
