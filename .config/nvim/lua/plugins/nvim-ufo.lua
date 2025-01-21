return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  opts = function()

    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep:│,foldclose:]]
    vim.o.foldcolumn = 'auto:2' -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    require('ufo').setup({
      open_fold_hl_timeout = 200,
      -- provider_selector = function(bufnr, filetype, buftype)
      --   return {'treesitter', 'indent'}
      -- end
    })
  end,
}
