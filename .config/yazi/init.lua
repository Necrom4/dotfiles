require("bookmarks"):setup({
	last_directory = { enable = true, persist = false, mode = "dir" },
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

require("full-border"):setup()

th.git = th.git or {}
th.git.modified_sign = "󰏬"
th.git.modified = ui.Style():fg("#82AAFF")
th.git.added_sign = ""
th.git.added = ui.Style():fg("#C3E88D")
th.git.untracked_sign = ""
th.git.untracked = ui.Style():fg("#FFC777")
th.git.ignored_sign = ""
th.git.ignored = ui.Style():fg("#636DA6")
th.git.deleted_sign = ""
th.git.deleted = ui.Style():fg("#C53B53")
th.git.updated_sign = "󰚰"
th.git.updated = ui.Style():fg("#4FD6BE")
require("git"):setup()

require("relative-motions"):setup({ show_numbers = "relative", show_motion = true, enter_mode = "first" })

-- local tokyo_night_theme = require("yatline-tokyo-night"):setup("moon") -- or moon/storm/day
--
-- require("yatline"):setup({
-- 	theme = tokyo_night_theme,
--
-- 	section_separator = { open = "", close = "" },
-- 	part_separator = { open = "", close = "" },
-- 	inverse_separator = { open = "", close = "" },
--
-- 	tab_width = 20,
-- 	tab_use_inverse = false,
--
-- 	selected = { icon = "󰒉", fg = "#FFC777" },
-- 	copied = { icon = "", fg = "#9ECE6A" },
-- 	cut = { icon = "", fg = "#C53B53" },
--
-- 	total = { icon = "󰮍", fg = "#CC0000" },
-- 	succ = { icon = "", fg = "#0FF000" },
-- 	fail = { icon = "", fg = "#0000FF" },
-- 	found = { icon = "󰮕", fg = "#FFFF00" },
-- 	processed = { icon = "󰐍", fg = "#00F0F0" },
--
-- 	show_background = false,
--
-- 	display_header_line = true,
-- 	display_status_line = true,
--
-- 	component_positions = { "header", "tab", "status" },
--
-- 	header_line = {
-- 		left = {
-- 			section_a = {
-- 				{ type = "line", custom = false, name = "tabs", params = { "left" } },
-- 			},
-- 			section_b = {
-- 				{ type = "coloreds", custom = false, name = "githead" },
-- 			},
-- 			section_c = {},
-- 		},
-- 		right = {
-- 			section_a = {},
-- 			section_b = {},
-- 			section_c = {},
-- 		},
-- 	},
--
-- 	status_line = {
-- 		left = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "tab_mode" },
-- 			},
-- 			section_b = {
-- 				{ type = "string", custom = false, name = "hovered_size" },
-- 			},
-- 			section_c = {
-- 				{ type = "string", custom = false, name = "hovered_path" },
-- 				{ type = "coloreds", custom = false, name = "count" },
-- 			},
-- 		},
-- 		right = {
-- 			section_a = {
-- 				{ type = "string", custom = false, name = "cursor_position" },
-- 			},
-- 			section_b = {
-- 				{ type = "string", custom = false, name = "cursor_percentage" },
-- 			},
-- 			section_c = {
-- 				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
-- 				{ type = "coloreds", custom = false, name = "permissions" },
-- 				{ type = "coloreds", custom = false, name = "created_time" },
-- 			},
-- 		},
-- 	},
-- })
--
-- require("yatline-created-time"):setup()
--
-- require("yatline-githead"):setup({
-- 	show_branch = true,
-- 	branch_prefix = "",
-- 	branch_color = "#C8D3F5",
-- 	branch_symbol = "",
-- 	branch_borders = "",
--
-- 	commit_symbol = "@",
--
-- 	show_behind_ahead = true,
-- 	behind_symbol = "",
-- 	ahead_symbol = "",
--
-- 	show_stashes = true,
-- 	stashes_symbol = "",
--
-- 	show_state = true,
-- 	show_state_prefix = true,
-- 	state_symbol = "~",
--
-- 	show_staged = true,
-- 	staged_symbol = "",
--
-- 	show_unstaged = true,
-- 	unstaged_symbol = "",
--
-- 	show_untracked = true,
-- 	untracked_symbol = "?",
-- })
