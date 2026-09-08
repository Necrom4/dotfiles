return {
	"dhruvasagar/vim-table-mode",
	ft = { "markdown" },
	config = function()
		vim.g.table_mode_corner = "|"

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				vim.cmd("silent! TableModeEnable")
			end,
		})
	end,
}
