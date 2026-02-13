local languages = {
	"css",
	"csv",
	"embedded_template",
	"lua_patterns",
	"make",
	"passwd",
	"scss",
	"sql",
	"ssh_config",
	"styled",
	"superhtml",
	"tmux",
	"tsv",
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
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "LazyFile",
		opts = function()
			local tsc = require("treesitter-context")
			Snacks.toggle({
				name = "Treesitter Context",
				get = tsc.enabled,
				set = function(state)
					if state then
						tsc.enable()
					else
						tsc.disable()
					end
				end,
			}):map("<leader>ut")
			return { mode = "cursor", max_lines = 3 }
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = languages,
		},
	},
}
