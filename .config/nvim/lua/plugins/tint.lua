return {
  "levouh/tint.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "<leader>dt", ":lua require('tint').toggle()<CR>", desc = "Toggle Tint", silent = true },
  },
}
