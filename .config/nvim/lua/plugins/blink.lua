return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    {
      'saghen/blink.compat',
      lazy = true,
    },
    'hrsh7th/cmp-calc',
    'folke/lazydev.nvim',
  },
  version = '*',
  event = { 'InsertEnter', 'CmdlineEnter' },
  opts = {
    keymap = {
      preset = 'none',
      ['<C-K>'] = { 'select_prev', 'fallback' },
      ['<C-J>'] = { 'select_next', 'fallback' },
      ['<S-TAB>'] = { 'select_prev', 'fallback' },
      ['<TAB>'] = { 'select_next', 'fallback' },
      ['<CR>'] = { 'select_and_accept', 'fallback' },
      ['<C-U>'] = { 'cancel' },
      ['<C-E>'] = { 'hide' },
      ['<C-D>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-S>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
        window = {
          border = 'rounded'
        }
      },
      list = { selection = { preselect = false } },
      ghost_text = { enabled = true, show_without_selection = true },
      menu = {
        draw = {
          treesitter = { 'lsp' },
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon" }
          },
        },
        border = 'rounded'
      },
    },
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'calc', 'lazydev' },
      providers = {
        calc = {
          name = 'calc',
          module = 'blink.compat.source',
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100, -- show at a higher priority than lsp
        },
      }
    },
  },
  opts_extend = {
    "sources.default",
  },
}
