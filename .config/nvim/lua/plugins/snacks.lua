return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  keys = {
    { "<leader>e", ":lua Snacks.dashboard.open()<CR>", desc = "Open Snacks Dashboard" },
  },
  opts = {
    bigfile = { enabled = false },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
╭────────────────────────────────────────────────────────╮
│ ███╗   ██╗███████╗ ██████╗██████╗  ██████╗ ███╗   ███╗ │
│ ████╗  ██║██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗ ████║ │
│ ██╔██╗ ██║█████╗  ██║     ██████╔╝██║   ██║██╔████╔██║ │
│ ██║╚██╗██║██╔══╝  ██║     ██╔══██╗██║   ██║██║╚██╔╝██║ │
│ ██║ ╚████║███████╗╚██████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║ │
│ ╚═╝  ╚═══╝╚══════╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝ │
╰────────────────────────────────────────────────────────╯]],
        keys = {
          { icon = " ", key = "e", desc = "New File", action = ":ene | startinsert" },
          { icon = "󰥨 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "󰈞 ", key = "t", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent CWD Files", action = ":Telescope oldfiles cwd_only=true" },
          { icon = " ", key = "R", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", padding = 2 },
        { icon = "󰙅 ", title = "PROJECTS", section = "projects", indent = 2, padding = 2 },
        {
          icon = " ",
          title = "GIT STATUS",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git --no-pager diff --stat -B -M -C",
          height = 5,
          padding = 2,
          ttl = 5 * 60,
          indent = 2,
        },
        { section = "startup" },
      },
    },
    indent = { enabled = false },
    input = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
}
