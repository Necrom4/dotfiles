return {
  'sindrets/diffview.nvim',
  opts = {},
  keys = {
    { "<leader>di", ":DiffviewOpen<CR>", mode = 'n', desc = "Open Current Index Diffview", silent = true },
    { "<leader>dh", ":DiffviewFileHistory %<CR>", mode = 'n', desc = "Open File History Diffview", silent = true },
    { "<leader>dh", ":'<,'>DiffviewFileHistory<CR>", mode = 'x', desc = "Open File History Diffview", silent = true },
    { "<leader>dq", ":DiffviewClose<CR>", desc = "Close Diffview", silent = true },
  }
}
