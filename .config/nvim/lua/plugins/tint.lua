-- tint keeps its state in a private upvalue (`__`) and exposes no getter
local function is_enabled()
	local enable = require("tint").enable
	local i = 1
	while true do
		local name, value = debug.getupvalue(enable, i)
		if not name then
			return false
		elseif name == "__" then
			return value.enabled == true
		end
		i = i + 1
	end
end

return {
	"levouh/tint.nvim",
	event = "LazyFile",
	opts = {
		tint = -75,
	},
	config = function(_, opts)
		local tint = require("tint")

		tint.setup(opts)
		-- setup() defers its initialization until VimEnter when loaded early.
		-- Disable only after that callback, so it cannot recreate tint autocmds.
		if vim.v.vim_did_enter == 1 then
			tint.disable()
		else
			vim.api.nvim_create_autocmd("VimEnter", {
				once = true,
				callback = function()
					tint.disable()
				end,
			})
		end

		Snacks.toggle
			.new({
				id = "tint",
				name = "Tint",
				get = is_enabled,
				set = function(state)
					if state then
						tint.enable()
					else
						tint.disable()
					end
				end,
				icon = {
					enabled = " ",
					disabled = " ",
				},
				color = {
					enabled = "green",
					disabled = "yellow",
				},
				wk_desc = {
					enabled = "Disable ",
					disabled = "Enable ",
				},
			})
			:map("<leader>uDw")
	end,
}
