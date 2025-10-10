return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufNewFile", "BufReadPost" },
	opts = {
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
	},
}
