return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = function()
      local tsc = require("treesitter-context")
      Snacks.toggle({
        name = "Treesitter Context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map("<leader>c")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    opts = {
      ensure_installed = {
        'c',
        'cpp',
        'bash',
        'diff',
        'dockerfile',
        'git_config',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'html',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'python',
        'php',
        'ruby',
        'sql',
        'ssh_config',
        'vim',
        'vimdoc',
        'yaml',
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_decremental = 'v',
          node_incremental = 'V',
        },
      },
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  }
}
