return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    'nvim-treesitter/nvim-treesitter',
  },
  init = function()
    vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldclose:'
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  keys = {
    { 'zR', function() require('ufo').openAllFolds() end,  mode = { 'n', 'v' }, desc = 'Open All Folds', },
    { 'zM', function() require('ufo').closeAllFolds() end, mode = { 'n', 'v' }, desc = 'Close All Folds', },
    {
      'zp',
      function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      desc = 'Peek folded lines',
      mode = { 'n', 'v' },
    },
  },
  opts = {
    open_fold_hl_timeout = 200,
    provider_selector = function(bufnr, filetype, buftype)
      return { 'treesitter', 'indent' }
    end,
  },
}

