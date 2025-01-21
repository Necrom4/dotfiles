return {
  {
    "williamboman/mason.nvim",
    cmd = { 'Mason', 'MasonLog', 'MasonUpdate', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll' },
    build = ':MasonUpdate', -- :MasonUpdate updates registry contents
    opts = {
      ensure_installed = {
        "ast_grep",
        "harper_ls",
        "pyright",
        "clangd",
        "lua_ls",
        "yamlls",
      },
      automatic_installation = true,
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      handlers = {
        function(server_name)
          require("lspconfig")[server_name].setup {}
        end,
      },
    }
  },
  "neovim/nvim-lspconfig",
  event = { 'BufReadPre', 'BufNewFile' },
  vim.diagnostic.config({
    signs = false,
  })
}
