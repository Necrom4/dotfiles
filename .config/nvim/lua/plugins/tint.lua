return {
  "levouh/tint.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "<leader>D", ":lua require('tint').toggle()<CR>", desc = "Toggle Tint", silent = true },
  },
}
