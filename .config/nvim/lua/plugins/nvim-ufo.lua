return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    'nvim-treesitter/nvim-treesitter',
    {
      "luukvbaal/statuscol.nvim",
      config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
            relculright = true,
            segments = {
              {text = {"%s"}, click = "v:lua.ScSa"},
              {text = {builtin.foldfunc}, click = "v:lua.ScFa"},
              {text = {builtin.lnumfunc, " "}, click = "v:lua.ScLa"}
            }
          })
      end,
    },
  },
  init = function()
    vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldclose:'
    vim.o.foldcolumn = '1'
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

