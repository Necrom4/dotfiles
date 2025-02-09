return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    {
      'saghen/blink.compat',
      lazy = true,
    },
    'hrsh7th/cmp-calc',
  },
  version = '*',
  event = 'InsertEnter',
  opts = {
    keymap = {
      preset = 'default',
      ['<C-K>'] = { 'select_prev', 'fallback' },
      ['<C-J>'] = { 'select_next', 'fallback' },
      ['<TAB>'] = { 'select_next', 'fallback' },
      ['<C-L>'] = { 'select_and_accept', 'fallback' },
      ['<C-E>'] = { 'cancel' },
      ['<C-D>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
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
      ghost_text = { enabled = true },
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
        border = 'rounded'
      },
    },
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'calc' },
      providers = {
        calc = {
          name = 'calc',
          module = 'blink.compat.source',
        }
      }
    },
  },
  opts_extend = {
    "sources.default",
  },
}
