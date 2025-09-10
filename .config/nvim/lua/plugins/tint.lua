local tinted = false

return {
	"levouh/tint.nvim",
	event = "LazyFile",
	opts = function()
		local tint = require("tint")

		tint.setup({
			tint = -75,
		})

		tint.disable()

		Snacks.toggle
			.new({
				id = "tint",
				name = "Tint",
				get = function()
					return tinted
				end,
				set = function()
					tinted = not tinted
					tint.toggle()
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
			:map("<c-w>d")
		return {}
	end,
}
