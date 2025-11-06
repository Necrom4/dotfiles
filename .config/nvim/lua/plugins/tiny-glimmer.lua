return {
	"rachartier/tiny-glimmer.nvim",
	event = "VeryLazy",
	priority = 10,
	opts = {
		overwrite = {
			paste = {
				enabled = true,
				default_animation = "left_to_right",
			},
			undo = {
				enabled = true,
				default_animation = "fade",
			},
			redo = {
				enabled = true,
				default_animation = "fade",
			},
		},
		animations = {
			fade = {
				max_duration = 1000,
			},
			left_to_right = {
				max_duration = 1000,
				min_duration = 800,
				min_progress = 0.25,
				chars_for_max_duration = 10,
			},
		},
	},
}
