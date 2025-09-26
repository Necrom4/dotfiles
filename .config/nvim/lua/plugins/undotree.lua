local undotree_enabled = false

return {
	"mbbill/undotree",
	config = function()
		vim.g.undotree_WindowLayout = 2
		vim.g.undotree_ShortIndicators = 1
		vim.g.undotree_TreeNodeShape = ""
		vim.g.undotree_TreeVertShape = "│"
	end,
	opts = function()
		Snacks.toggle
			.new({
				id = "undotree",
				name = "Undotree",
				get = function()
					return undotree_enabled
				end,
				set = function()
					undotree_enabled = not undotree_enabled
					vim.cmd("UndotreeToggle")
				end,
				icon = {
					enabled = "󰕌 ",
					disabled = "󰕌 ",
				},
				color = {
					enabled = "red",
					disabled = "purple",
				},
				wk_desc = {
					enabled = "Close ",
					disabled = "Open ",
				},
			})
			:map("<leader>du")
		return {}
	end,
}
