return {
  "goolord/alpha-nvim",
  event = "VimEnter",  -- Lazy load on startup
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    -- Header Art
    dashboard.section.header.val = {
      [[╭────────────────────────────────────────────────────────╮]],
      [[│ ███╗   ██╗███████╗ ██████╗██████╗  ██████╗ ███╗   ███╗ │]],
      [[│ ████╗  ██║██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗ ████║ │]],
      [[│ ██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██╔████╔██║ │]],
      [[│ ██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║╚██╔╝██║ │]],
      [[│ ██║ ╚████║███████╗╚██████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║ │]],
      [[│ ╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ │]],
      [[╰────────────────────────────────────────────────────────╯]],
    }

    -- Dashboard Buttons
    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("f", "󰮗  Find file", ":Telescope find_files <CR>"),
      dashboard.button("w", "󱎸  Find word", ":Telescope live_grep <CR>"),
      dashboard.button("r", "  Recently opened files (cwd)", ":Telescope oldfiles cwd_only=true<CR>"),
      dashboard.button("R", "  Recently opened files (all)", ":Telescope oldfiles <CR>"),
      dashboard.button(".", "  CWD", ":execute 'cd ' . g:cwd<CR>"),
      dashboard.button("t", "  Trash", ":Vifm ~/../.vifm-Trash-0/ <CR>"),
      dashboard.button("q", "󰈆  Exit", ":qa<CR>"),
    }

    -- Highlights
    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true

    return dashboard.opts
  end,

  keys = {
    { "<leader>e", "<cmd>Alpha<CR>", desc = "Open Alpha Dashboard" },
  },
}
