return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,  -- Enable Treesitter-based syntax highlighting
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = 'vs',
        scope_incremental = '<CR>',
        node_incremental = '<TAB>',
        node_decremental = '<S-TAB>',
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
  end,
}
