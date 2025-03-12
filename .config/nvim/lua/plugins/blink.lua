return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    {
      'saghen/blink.compat',
      lazy = true,
    },
    'mikavilpas/blink-ripgrep.nvim',
    'hrsh7th/cmp-calc',
    'folke/lazydev.nvim',
    'moyiz/blink-emoji.nvim',
    'MahanRahmati/blink-nerdfont.nvim',
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
      ['<C-L>'] = { 'select_and_accept', 'fallback' },
      ['<C-U>'] = { 'cancel' },
      ['<C-E>'] = { 'hide' },
      ['<C-D>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-S>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
    },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },
    cmdline = {
      completion = {
        list = { selection = { preselect = false } },
        menu = { auto_show = true },
      }
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
      default = { 'lsp', 'path', 'snippets', 'buffer', 'ripgrep', 'calc', 'lazydev', 'emoji', 'nerdfont' },
      providers = {
        ripgrep = {
          name = "Ripgrep",
          module = "blink-ripgrep",
        },
        calc = {
          name = 'calc',
          module = 'blink.compat.source',
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100, -- show at a higher priority than lsp
        },
        emoji = {
          name = "Emoji",
          module = "blink-emoji",
          score_offset = 15, -- Tune by preference
          opts = { insert = true }, -- Insert emoji (default) or complete its name
        },
        nerdfont = {
          name = "Nerd Fonts",
          module = "blink-nerdfont",
          score_offset = 10, -- Tune by preference
          opts = { insert = true }, -- Insert emoji (default) or complete its name
        },
      }
    },
  },
  opts_extend = {
    "sources.default",
  },
}
