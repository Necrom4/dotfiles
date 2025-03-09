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

require("eza-preview"):setup({
  level = 3,
  follow_symlinks = true,
  dereference = true,
})

require("git"):setup()

require("githead"):setup({
  show_branch = true,
  branch_prefix = "on",
  branch_color = "#FF0000",
  branch_symbol = "",
  branch_borders = "()",

  commit_color = "#CC0000",
  commit_symbol = "@",

  show_behind_ahead = true,
  behind_color = "#CC0000",
  behind_symbol = "",
  ahead_color = "#CC0000",
  ahead_symbol = "",

  show_stashes = true,
  stashes_color = "#CC0000",
  stashes_symbol = "",

  show_state = true,
  show_state_prefix = true,
  state_color = "red",
  state_symbol = "~",

  show_staged = true,
  staged_color = "bright yellow",
  staged_symbol = "",

  show_unstaged = true,
  unstaged_color = "bright yellow",
  unstaged_symbol = "",

  show_untracked = true,
  untracked_color = "blue",
  untracked_symbol = "?",
})

require("relative-motions"):setup({ show_numbers="relative", show_motion = true, enter_mode ="first" })
