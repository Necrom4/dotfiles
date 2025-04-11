return {
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
}
