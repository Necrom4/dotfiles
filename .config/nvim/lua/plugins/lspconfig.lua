return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		local keys = require("lazyvim.plugins.lsp.keymaps").get()
		-- disable a keymap
		keys[#keys + 1] = { "K", false }
		keys[#keys + 1] = {
			"gK",
			function()
				return vim.lsp.buf.hover()
			end,
			desc = "Hover",
		}
		keys[#keys + 1] = { "<leader>cC", false }
		keys[#keys + 1] = { "<leader>ss", false }
		keys[#keys + 1] = { "<c-k>", mode = "i", false }

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
