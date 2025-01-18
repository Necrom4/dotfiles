return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-calc",
  },
  config = function()
    local cmp = require'cmp'

    cmp.setup({
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = {
        ["<C-K>"] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
        ["<C-J>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
        ["<TAB>"] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
        ["<C-S-K>"] = cmp.mapping(cmp.mapping.select_prev_item({count = 5}), {'i', 'c'}),
        ["<C-S-J>"] = cmp.mapping(cmp.mapping.select_next_item({count = 5}), {'i', 'c'}),
        ["<C-P>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), {'i', 'c'}),
        ["<C-N>"] = cmp.mapping(cmp.mapping.scroll_docs(5), {'i', 'c'}),
        ["<C-d>"] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ["<C-e>"] = cmp.mapping {
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        },
        -- ["<CR>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { 'i', 'c' }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      },
      sources = cmp.config.sources({
        { name = 'buffer',
        option = {
          get_bufnrs = function()
            return vim.api.nvim_list_bufs()
          end
        }
      },
      { name = 'calc' },
      { name = 'path' },
      { name = "nvim_lsp" },
    }),
    experimental = {
      ghost_text = true,
    },
    formatting = {
      fields = {"abbr"},
    }
  })

  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
end
}
