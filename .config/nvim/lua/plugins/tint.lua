local tint_enabled = true

return {
	"levouh/tint.nvim",
	event = "LazyFile",
	opts = function()
		Snacks.toggle
			.new({
				id = "tint",
				name = "Tint",
				get = function()
					return tint_enabled
				end,
				set = function()
					tint_enabled = not tint_enabled
					require("tint").toggle()
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
		return { tint = -75 }
	end,
}
