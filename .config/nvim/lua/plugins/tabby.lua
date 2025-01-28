return {
  "nanozuki/tabby.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "TabNew", -- Load the plugin only when a new tab is opened
  opts = {
    line = function(line)
      local theme = {
        fill = 'TabLineFill',
        head = 'TabLine',
        current_tab = 'TabLineSel',
        tab = 'TabLine',
        win = 'TabLine',
        tail = 'TabLine',
      }
      return {
        line.tabs().foreach(function(tab)
          local hl = tab.is_current() and theme.current_tab or theme.tab
          return {
            line.sep('', hl, theme.fill),
            tab.is_current() and '' or '󰆣',
            tab.number(),
            tab.name(),
            tab.close_btn(''),
            line.sep('', hl, theme.fill),
            hl = hl,
            margin = ' ',
          }
        end),
      }
    end,
  },
  config = true, -- Automatically apply the `opts` when loading the plugin
}
