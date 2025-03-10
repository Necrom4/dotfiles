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

THEME.git = THEME.git or {}
THEME.git.modified_sign = "󰏬"
THEME.git.modified = ui.Style():fg("#FFFF00")
THEME.git.added_sign = ""
THEME.git.added = ui.Style():fg("#00FF00")
THEME.git.untracked_sign = "?"
THEME.git.untracked = ui.Style():fg("#7F0000")
THEME.git.ignored_sign = ""
THEME.git.ignored = ui.Style():fg("#7F0000")
THEME.git.deleted_sign = ""
THEME.git.deleted = ui.Style():fg("#CC0000")
THEME.git.updated_sign = "󰇚"
THEME.git.updated = ui.Style():fg("#00FF00")
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
  staged_color = "#FF0000",
  staged_symbol = "",

  show_unstaged = true,
  unstaged_color = "#A50000",
  unstaged_symbol = "",

  show_untracked = true,
  untracked_color = "#7F0000",
  untracked_symbol = "?",
})

require("relative-motions"):setup({ show_numbers="relative", show_motion = true, enter_mode ="first" })
