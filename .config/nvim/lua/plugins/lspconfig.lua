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
							-- uri_to_bufnr() creates a buffer for unknown URIs, so only resolve names that already exist
							local bufnr = vim.fn.bufexists(vim.uri_to_fname(result.uri)) == 1 and vim.uri_to_bufnr(result.uri)
							if bufnr and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "yamljinja" then
								result.diagnostics = {}
							end
						end
						return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
					end,
				},
			},
		})

		-- Extend (never replace) LazyVim's LSP keys: on Neovim 0.12 tbl_deep_extend
		-- replaces lists wholesale, which would drop every LazyVim/extra LSP keymap.
		opts.servers["*"] = opts.servers["*"] or {}
		opts.servers["*"].keys = vim.list_extend(opts.servers["*"].keys or {}, {
			{ "K", false },
			{
				"gK",
				function()
					return vim.lsp.buf.hover()
				end,
				desc = "Hover",
			},
			{ "<c-k>", mode = "i", false },
			{ "<leader>ss", false },
			-- LazyVim's `gr` is nowait and would swallow Neovim's gr* family.
			-- References live on grr (see plugins/snacks.lua).
			{ "gr", false },
			-- `ga` is text-case's prefix; call hierarchy moves under gr*.
			{ "gai", false },
			{ "gao", false },
			{
				"grI",
				function()
					Snacks.picker.lsp_incoming_calls()
				end,
				desc = "Calls Incoming",
				has = "callHierarchy/incomingCalls",
			},
			{
				"grO",
				function()
					Snacks.picker.lsp_outgoing_calls()
				end,
				desc = "Calls Outgoing",
				has = "callHierarchy/outgoingCalls",
			},
			-- <leader>cc is the calc group and <leader>cC the color picker.
			{ "<leader>cc", mode = { "n", "x" }, false },
			{ "<leader>cC", false },
			{ "grc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
			{ "grC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", has = "codeLens" },
			{ "grA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
			{
				"grR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
				has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
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
