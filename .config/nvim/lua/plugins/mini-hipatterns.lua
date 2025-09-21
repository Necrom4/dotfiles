return {
	"nvim-mini/mini.hipatterns",
	opts = function(_, opts)
		local hipatterns = require("mini.hipatterns")

		local function buf_enabled(bufnr)
			bufnr = bufnr or vim.api.nvim_get_current_buf()
			for _, b in ipairs(hipatterns.get_enabled_buffers()) do
				if b == bufnr then
					return true
				end
			end
			return false
		end

		Snacks.toggle({
			id = "mini-hipatterns",
			name = "Color",
			get = function()
				return buf_enabled()
			end,
			set = function(state)
				if buf_enabled() ~= state then
					hipatterns.toggle(0)
					if state then
						pcall(hipatterns.update, 0)
					end
				end
			end,
		}):map("<leader>uC")
		return opts
	end,
}
