return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		local keys = require("lazyvim.plugins.lsp.keymaps").get()
		-- disable a keymap
		keys[#keys + 1] = { "K", false }
		keys[#keys + 1] = { "<leader>ss", false }

		opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics, {
			virtual_text = {
				prefix = "",
			},
			signs = false,
		})
		-- opts.inlay_hints = vim.tbl_deep_extend("force", opts.inlay_hints, {
		-- 	enabled = false,
		-- })
		-- opts.codelens = vim.tbl_deep_extend("force", opts.codelens, {
		-- 	enabled = false,
		-- })
	end,
}
