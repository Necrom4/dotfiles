return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		opts.servers = vim.tbl_deep_extend("force", opts.servers, {
			["*"] = {
				keys = {
					{ "K", false },
					{
						"gk",
						function()
							return vim.lsp.buf.hover()
						end,
						desc = "Hover",
					},
					{ "<leader>cC", false },
					{ "<leader>ss", false },
					{ "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", has = "definition" },
					{ "<c-k>", mode = "i", false },
				},
			},
		})

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
