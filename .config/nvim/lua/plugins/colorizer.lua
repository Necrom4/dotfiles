local colored = true

return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufNewFile", "BufReadPost" },
	opts = function()
		Snacks.toggle({
			id = "colorizer",
			name = "Colorizer",
			get = function()
				return colored
			end,
			set = function()
				colored = not colored
				vim.cmd("ColorizerToggle")
			end,
		}):map("<leader>uC")

		return {
			user_default_options = {
				RGB = true,
				RRGGBB = true,
				names = true,
				RRGGBBAA = true,
				rgb_fn = true,
				hsl_fn = false,
				css = true,
				css_fn = true,
				always_update = true,
			},
		}
	end,
}
