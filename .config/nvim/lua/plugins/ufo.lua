local Fold = require("core.fold")

local ftMap = {
	vim = "indent",
	python = { "treesitter", "indent" },
	lua = { "treesitter", "indent" },
	javascript = { "treesitter", "indent" },
	typescript = { "treesitter", "indent" },
	javascriptreact = { "treesitter", "indent" },
	typescriptreact = { "treesitter", "indent" },
	vue = { "indent", "treesitter" },
	json = { "treesitter", "indent" },
	jsonc = { "treesitter", "indent" },
	yaml = { "treesitter", "indent" },
	toml = { "treesitter", "indent" },
	rust = { "lsp", "treesitter" },
	go = { "lsp", "treesitter" },
	php = { "lsp", "treesitter" },
	ruby = { "treesitter", "indent" },
	c = { "lsp", "treesitter" },
	cpp = { "lsp", "treesitter" },
	java = { "lsp", "treesitter" },
	css = { "treesitter", "indent" },
	scss = { "treesitter", "indent" },
	html = { "treesitter", "indent" },
	xml = { "treesitter", "indent" },
	markdown = { "treesitter", "indent" },
	sh = { "treesitter", "indent" },
	zsh = { "treesitter", "indent" },
	fish = { "treesitter", "indent" },
	git = "",
	gitcommit = "",
	fff_list = "",
	fff_preview = "",
	fff_input = "",
	help = "indent",
	text = "indent",
}

return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
		"nvim-treesitter/nvim-treesitter",
	},
	init = function()
		vim.opt.foldcolumn = "1"
		vim.opt.foldlevelstart = 99
		vim.opt.foldnestmax = 6
		vim.opt.foldenable = true
		vim.opt.foldopen = "block,insert,jump,mark,percent,quickfix,search,tag,undo"
	end,
	keys = {
		{
			"zR",
			function()
				require("ufo").openAllFolds()
			end,
			mode = { "n", "v" },
			desc = "Open All Folds",
		},
		{
			"zM",
			function()
				require("ufo").closeAllFolds()
			end,
			mode = { "n", "v" },
			desc = "Close All Folds",
		},
		{
			"zp",
			function()
				local winid = require("ufo").peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end,
			desc = "Peek folded lines",
			mode = { "n", "v" },
		},
	},
	opts = {
		open_fold_hl_timeout = 150,
		enable_get_fold_virt_text = true,
		fold_virt_text_handler = Fold.ufo_virt_text_handler_enhanced,
		close_fold_kinds_for_ft = {
			default = { "imports", "comment" },
			json = { "array" },
			jsonc = { "array" },
			c = { "comment", "region" },
			cpp = { "comment", "region" },
			java = { "comment", "imports" },
			javascript = { "comment", "imports" },
			typescript = { "comment", "imports" },
			vue = { "imports" },
			python = { "comment", "imports" },
			go = { "comment", "imports" },
			rust = { "comment", "imports" },
			php = { "imports" },
		},
		provider_selector = function(bufnr, filetype, buftype)
			if buftype ~= "" then
				return nil
			end
			return ftMap[filetype] or Fold.ufo_provider_selector
		end,
	},
}
