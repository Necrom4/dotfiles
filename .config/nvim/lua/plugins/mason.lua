local packages = {
	"ast-grep",
	"bash-language-server",
	"checkmake",
	"clang-format",
	"clangd",
	"debugpy",
	"delve",
	"gofumpt",
	"golangci-lint",
	"gopls",
	"helm-ls",
	"html-lsp",
	"kube-linter",
	"lua-language-server",
	"marksman",
	"pgformatter",
	"php-debug-adapter",
	"phpactor",
	"postgres-language-server",
	"pyright",
	"rubocop",
	"ruff",
	"sqruff",
	"standardrb",
	"stylelint",
	"stylelint-lsp",
	"superhtml",
	"taplo",
	"tree-sitter-cli",
	"typescript-language-server",
	"vim-language-server",
	"vint",
	"yaml-language-server",
	"yamlfmt",
	"yamllint",
}

local status, class_extras = pcall(require, "manifests.packages")
if status and type(class_extras) == "table" then
	for _, extra_path in ipairs(class_extras) do
		table.insert(packages, extra_path)
	end
end

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
