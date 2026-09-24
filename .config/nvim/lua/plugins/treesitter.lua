local languages = {
	"css",
	"csv",
	"embedded_template",
	"lua_patterns",
	"make",
	"passwd",
	"pkl",
	"scss",
	"sql",
	"ssh_config",
	"styled",
	"superhtml",
	"tmux",
	"tsv",
	"vhs",
	"xml",
	"zsh",
}

local status, class_extras = pcall(require, "manifests.languages")
if status and type(class_extras) == "table" then
	for _, extra_path in ipairs(class_extras) do
		table.insert(languages, extra_path)
	end
end

return {
	"nvim-treesitter/nvim-treesitter",
	opts = {
		ensure_installed = languages,
	},
}
