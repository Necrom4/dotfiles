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

require("full-border"):setup()

THEME.git = THEME.git or {}
THEME.git.modified_sign = "󰏬"
THEME.git.modified = ui.Style():fg("#FFFF00")
THEME.git.added_sign = ""
THEME.git.added = ui.Style():fg("#00BF00")
THEME.git.untracked_sign = ""
THEME.git.untracked = ui.Style():fg("#FFAA00")
THEME.git.ignored_sign = ""
THEME.git.ignored = ui.Style():fg("#7F7F7F")
THEME.git.deleted_sign = ""
THEME.git.deleted = ui.Style():fg("#FF0000")
THEME.git.updated_sign = "󰚰"
THEME.git.updated = ui.Style():fg("#FF7F7F")
require("git"):setup()

require("relative-motions"):setup({ show_numbers="relative", show_motion = true, enter_mode ="first" })

require("yatline"):setup({
  section_separator = { open = "", close = "" },
  part_separator = { open = "", close = "" },
  inverse_separator = { open = "", close = "" },

  style_a = {
    fg = "#000000",
    bg_mode = {
      normal = "#CC0000",
      select = "#CC0000",
      un_set = "#CC0000"
    }
  },
  style_b = { bg = "#590000", fg = "#CC0000" },
  style_c = { bg = "#000000", fg = "#CC0000" },

  permissions_t_fg = "green",
  permissions_r_fg = "yellow",
  permissions_w_fg = "red",
  permissions_x_fg = "cyan",
  permissions_s_fg = "white",

  tab_width = 20,
  tab_use_inverse = false,

  selected = { icon = "󰒉", fg = "#CC0000" },
  copied = { icon = "", fg = "#CC0000" },
  cut = { icon = "", fg = "#CC0000" },

  total = { icon = "󰮍", fg = "#CC0000" },
  succ = { icon = "", fg = "#0FF000" },
  fail = { icon = "", fg = "#0000FF" },
  found = { icon = "󰮕", fg = "#FFFF00" },
  processed = { icon = "󰐍", fg = "#00F0F0" },

  show_background = true,

  display_header_line = true,
  display_status_line = true,

  component_positions = { "header", "tab", "status" },

  header_line = {
    left = {
      section_a = {
        {type = "line", custom = false, name = "tabs", params = {"left"}},
      },
      section_b = {
      },
      section_c = {
        {type = "coloreds", custom = false, name = "githead"},
      }
    },
    right = {
      section_a = {
      },
      section_b = {
      },
      section_c = {
      }
    }
  },

  status_line = {
    left = {
      section_a = {
        {type = "string", custom = false, name = "tab_mode"},
      },
      section_b = {
        {type = "string", custom = false, name = "hovered_size"},
      },
      section_c = {
        {type = "string", custom = false, name = "hovered_path"},
        {type = "coloreds", custom = false, name = "count"},
      }
    },
    right = {
      section_a = {
        {type = "string", custom = false, name = "cursor_position"},
      },
      section_b = {
        {type = "string", custom = false, name = "cursor_percentage"},
      },
      section_c = {
        {type = "string", custom = false, name = "hovered_file_extension", params = {true}},
        {type = "coloreds", custom = false, name = "permissions"},
        {type = "coloreds", custom = false, name = "created_time"},
      }
    }
  },
})

require("yatline-created-time"):setup()

require("yatline-githead"):setup({
  show_branch = true,
  branch_prefix = "",
  branch_color = "#FF0000",
  branch_symbol = "",
  branch_borders = "",

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
