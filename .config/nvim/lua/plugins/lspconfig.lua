return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		opts.servers = vim.tbl_deep_extend("force", opts.servers, {
			jinja_lsp = {
				filetypes = { "jinja", "yamljinja" },
			},
			yamlls = {
				filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values", "yamljinja" },
				-- Drop yamlls diagnostics on yamljinja buffers (it doesn't understand jinja).
				handlers = {
					["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
						if result and result.uri then
							local bufnr = vim.uri_to_bufnr(result.uri)
							if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "yamljinja" then
								result.diagnostics = {}
							end
						end
						return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
					end,
				},
			},
			["*"] = {
				keys = {
					{ "K", false },
					{
						"gK",
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
		opts.inlay_hints = vim.tbl_deep_extend("force", opts.inlay_hints, {
			enabled = false,
		})
		-- opts.codelens = vim.tbl_deep_extend("force", opts.codelens, {
		-- 	enabled = false,
		-- })
	end,
}
