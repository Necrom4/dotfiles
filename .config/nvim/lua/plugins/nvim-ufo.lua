return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    'nvim-treesitter/nvim-treesitter',
  },
  init = function()
    vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep:│,foldclose:'
    vim.o.foldcolumn = 'auto:9'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,

  opts = {
    open_fold_hl_timeout = 200,
    provider_selector = function(bufnr, filetype, buftype)
      return { 'treesitter', 'indent' }
    end,
  },
}

