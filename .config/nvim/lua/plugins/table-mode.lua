return {
	"dhruvasagar/vim-table-mode",
	ft = { "markdown" },
	init = function()
		vim.g.table_mode_corner = "|"
		vim.g.table_mode_map_prefix = "<localleader>t"
		vim.g.table_mode_tableize_d_map = "<localleader>T"

		-- lazy re-fires FileType after loading the plugin, so the first markdown buffer is caught on that pass
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("table_mode_markdown", { clear = true }),
			pattern = "markdown",
			callback = function(ev)
				if vim.fn.exists(":TableModeEnable") == 2 and vim.b[ev.buf].table_mode_active ~= 1 then
					vim.api.nvim_buf_call(ev.buf, function()
						vim.cmd("TableModeEnable")
					end)
				end
			end,
		})
	end,
}
