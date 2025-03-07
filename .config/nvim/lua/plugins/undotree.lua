return {
  'mbbill/undotree',
  config = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_TreeNodeShape = ''
    vim.g.undotree_TreeVertShape = '│'
  end,
  keys = {
    { "<leader>u", ":UndotreeToggle<CR>", desc = "Open UndoTree", silent = true },
  }
}
