return {
  "nvim-treesitter/nvim-treesitter",
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
      enable = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        node_decremental = 'v',
        node_incremental = 'V',
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
  end,
}
