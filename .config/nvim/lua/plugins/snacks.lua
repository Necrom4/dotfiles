return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>e", ":lua Snacks.dashboard.open()<CR>", desc = "Open Snacks Dashboard", silent = true },
    { "<leader>g", ":lua Snacks.lazygit.open()<CR>", desc = "Open LazyGit", silent = true },
    { "<leader>t", ":lua Snacks.terminal()<CR>", desc = "Open Terminal", silent = true },
  },
  opts = {
    bigfile = { enabled = true },
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
          { icon = " ", key = ".", desc = "Switch to CWD", action = ":execute 'cd ' . g:cwd" },
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
            return Snacks.git.get_root() == nil
          end,
          cmd = "cmatrix",
          height = 5,
          padding = 2,
          ttl = 5 * 60,
          indent = 2,
        },
        {
          icon = " ",
          title = "GIT STATUS [" .. vim.fn.trim(vim.fn.system("git branch --show-current")) .. "]",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git --no-pager diff --stat -B -M -C && git status --short --renames",
          height = 5,
          padding = 2,
          ttl = 5 * 60,
          indent = 2,
        },
        { section = "startup" },
      },
    },
    indent = {
      indent = {
        enabled = false,
      },
      scope = {
        enabled = true,
        only_current = true,
        hl = "Operator",
      },
    },
    input = { enabled = false },
    lazygit = {
      enabled = true,
      theme = {
        [241]                      = { fg = "Special" },
        activeBorderColor          = { fg = "MatchParen", bold = true },
        cherryPickedCommitBgColor  = { fg = "Identifier" },
        cherryPickedCommitFgColor  = { fg = "Function" },
        defaultFgColor             = { fg = "Normal" },
        inactiveBorderColor        = { fg = "FloatBorder" },
        optionsTextColor           = { fg = "Function" },
        searchingActiveBorderColor = { fg = "MatchParen", bold = true },
        selectedLineBgColor        = { bg = "Visual" }, -- set to `default` to have no background colour
        unstagedChangesColor       = { fg = "Operator" },
      },
    },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    terminal = {
      enabled = true,
      win = "float",
    },
    words = { enabled = false },
    win = {
      border = "rounded",
    },
  },
}
