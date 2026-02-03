require("duckdb"):setup()

require("eza-preview"):setup({
	level = 3,
	follow_symlinks = true,
	dereference = true,
	all = false,
})

require("full-border"):setup()

th.git = th.git or {}
th.git.modified_sign = "󰏬"
th.git.modified = ui.Style():fg("#82AAFF")
th.git.added_sign = ""
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

require("whoosh"):setup {
  -- Configuration bookmarks (cannot be deleted through plugin)
  bookmarks = {
    { tag = "Home", path = "~", key = "~" },
    { tag = "Documents", path = "~/Documents", key = "d" },
    { tag = "Downloads", path = "~/Downloads", key = "D" },
    { tag = "/tmp", path = "/tmp", key = "t" },
    { tag = "~/.config/nvim", path = "~/.config/nvim", key = { "c", "n" } },
    { tag = "~/.config/yadm", path = "~/.config/yadm", key = { "c", "y" } },
    { tag = "~/.config/zsh", path = "~/.config/zsh", key = { "c", "z" } },
    { tag = "~/.local/share/nvim", path = "~/.local/share/nvim", key = { "l", "s", "n" } },
  },

  -- Notification settings
  jump_notify = false,

  -- Key generation for auto-assigning bookmark keys
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",

  special_keys = {
    previous_dir = "'",
  },

  -- File path for storing user bookmarks
  path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
         (os.getenv("HOME") .. "/.config/yazi/bookmark"),

  -- Path truncation in navigation menu
  path_truncate_enabled = false,                        -- Enable/disable path truncation
  path_max_depth = 3,                                   -- Maximum path depth before truncation

  -- Path truncation in fuzzy search (fzf)
  fzf_path_truncate_enabled = false,                    -- Enable/disable path truncation in fzf
  fzf_path_max_depth = 5,                               -- Maximum path depth before truncation in fzf

  -- Long folder name truncation
  path_truncate_long_names_enabled = false,             -- Enable in navigation menu
  fzf_path_truncate_long_names_enabled = false,         -- Enable in fzf
  path_max_folder_name_length = 20,                     -- Max length in navigation menu
  fzf_path_max_folder_name_length = 20,                 -- Max length in fzf

  -- History directory settings
  history_size = 10,                                    -- Number of directories in history (default 10)
  history_fzf_path_truncate_enabled = false,            -- Enable/disable path truncation by depth for history
  history_fzf_path_max_depth = 5,                       -- Maximum path depth before truncation for history (default 5)
  history_fzf_path_truncate_long_names_enabled = false, -- Enable/disable long folder name truncation for history
  history_fzf_path_max_folder_name_length = 30,         -- Maximum length for folder names in history (default 30)
}

local tokyo_night_theme = require("yatline-tokyo-night"):setup("moon") -- or moon/storm/day

require("yatline"):setup({
	theme = tokyo_night_theme,

	section_separator = { open = "", close = "" },
	part_separator = { open = "", close = " " },
	inverse_separator = { open = "", close = "" },

	tab_width = 20,
	tab_use_inverse = false,

	selected = { icon = "󰒉", fg = "#FFC777" },
	copied = { icon = "", fg = "#9ECE6A" },
	cut = { icon = "", fg = "#C53B53" },

	total = { icon = "󰮍", fg = "#CC0000" },
	succ = { icon = "", fg = "#0FF000" },
	fail = { icon = "", fg = "#0000FF" },
	found = { icon = "󰮕", fg = "#FFFF00" },
	processed = { icon = "󰐍", fg = "#00F0F0" },

	show_background = false,

	display_header_line = true,
	display_status_line = true,

	component_positions = { "header", "tab", "status" },

	header_line = {
		left = {
			section_a = {
				{ type = "line", custom = false, name = "tabs", params = { "left" } },
			},
			section_b = {
				{ type = "coloreds", custom = false, name = "githead" },
			},
			section_c = {},
		},
		right = {
			section_a = {},
			section_b = {},
			section_c = {},
		},
	},

	status_line = {
		left = {
			section_a = {
				{ type = "string", custom = false, name = "tab_mode" },
			},
			section_b = {
				{ type = "string", custom = false, name = "hovered_size" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_path" },
				{ type = "coloreds", custom = false, name = "count" },
			},
		},
		right = {
			section_a = {
				{ type = "string", custom = false, name = "cursor_position" },
			},
			section_b = {
				{ type = "string", custom = false, name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", custom = false, name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", custom = false, name = "permissions" },
				{ type = "coloreds", custom = false, name = "modified_time" },
			},
		},
	},
})

require("yatline-modified-time"):setup()

require("yatline-githead"):setup({
	show_branch = true,
	branch_prefix = "",
	branch_color = "#C8D3F5",
	branch_symbol = "",
	branch_borders = "",

	commit_symbol = "@",

	show_behind_ahead = true,
	behind_symbol = "",
	ahead_symbol = "",

	show_stashes = true,
	stashes_symbol = "",

	show_state = true,
	show_state_prefix = true,
	state_symbol = "~",

	show_staged = true,
	staged_symbol = "",

	show_unstaged = true,
	unstaged_symbol = "",

	show_untracked = true,
	untracked_symbol = "?",
})

function Entity:padding() return " " end
function Linemode:padding() return " " end

-- TEMPORARY FIX: Override yatline-modified-time to handle empty directories
-- Remove this once https://github.com/wekauwau/yatline-modified-time.yazi/pull/4 is merged
if Yatline then
	function Yatline.coloreds.get:modified_time()
		local h = cx.active.current.hovered
		local modified_time = {}
		local time = ""

		if h and h.cha and h.cha.mtime then
			time = " M: " .. os.date("%Y-%m-%d %H:%M", h.cha.mtime // 1) .. " "
		end

		table.insert(modified_time, { time, "silver" })
		return modified_time
	end
end
