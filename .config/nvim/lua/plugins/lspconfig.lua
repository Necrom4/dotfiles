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
				"docker-compose-language-service",
				"dockerfile-language-server",
				"html-lsp",
				"json-lsp",
				"just-lsp",
				"phpactor",
				"rubocop",
				"ruby-lsp",
				"rubyfmt",
				"superhtml",
				"taplo",
				"yaml-language-server",
			},
			ui = {
				border = "rounded",
				height = 0.8,
			},
		},
	},
}
