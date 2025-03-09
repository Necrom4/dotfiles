require("bookmarks"):setup({
	last_directory = { enable = true, persist = false, mode="dir" },
	persist = "all",
	desc_format = "full",
	file_pick_mode = "parent",
	custom_desc_input = false,
	notify = {
		enable = false,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})

require("relative-motions"):setup({ show_numbers="relative", show_motion = true, enter_mode ="first" })
