local packages = {
	"ast-grep",
	"bash-language-server",
	"checkmake",
	"clang-format",
	"debugpy",
	"html-lsp",
	"kube-linter",
	"pgformatter",
	"pkl-lsp",
	"postgres-language-server",
	"stylelint-language-server",
	"superhtml",
	"vim-language-server",
	"vint",
	"yamlfmt",
	"yamllint",
}

vim.list_extend(packages, require("utils.general").manifest("packages"))

return {
	"mason-org/mason.nvim",
	opts = {
		ensure_installed = packages,
		ui = {
			border = "rounded",
			height = 0.8,
		},
	},
}
