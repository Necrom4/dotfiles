return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = true,
    styles = {
      floats = "transparent",
    },
    on_highlights = function(hl, c)
      hl.WinSeparator = {
        fg = "#C0CAF5",
      }
    end,
  },
}
