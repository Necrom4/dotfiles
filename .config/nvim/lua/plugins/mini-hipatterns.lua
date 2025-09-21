return {
	"nvim-mini/mini.hipatterns",
	opts = function(_, opts)
		local hipatterns = require("mini.hipatterns")
		local api = vim.api

		Snacks.toggle({
			id = "mini-hipatterns",
			name = "Colorizer",
			get = function()
				return not vim.g.minihipatterns_disable
			end,
			set = function(state)
				vim.g.minihipatterns_disable = not state
				for _, buf in ipairs(api.nvim_list_bufs()) do
					if api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
						if state then
							hipatterns.enable(buf)
							pcall(hipatterns.update, buf)
						else
							hipatterns.disable(buf)
						end
					end
				end
			end,
		}):map("<leader>uC")

		return opts
	end,
}
