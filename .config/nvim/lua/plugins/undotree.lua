return {
	"mbbill/undotree",
	event = "VeryLazy",
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
					-- Check if an UndoTree buffer exists and is visible
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].filetype == "undotree" and vim.api.nvim_win_is_valid(win) then
							return true
						end
					end
					return false
				end,
				set = function(state)
					vim.cmd("UndotreeToggle")
				end,
				icon = {
					enabled = "󰈆 ",
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
	end,
}
