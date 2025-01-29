-- KEYMAPS --

-- Source vim configs

vim.keymap.set("n", "<leader>v", function()
  vim.cmd("luafile ~/.config/nvim/lua/core/settings.lua")
  vim.cmd("luafile ~/.config/nvim/lua/core/appearence.lua")
  vim.cmd("luafile ~/.config/nvim/lua/core/autocmds.lua")
  vim.cmd("luafile ~/.config/nvim/lua/core/keymaps.lua")
  vim.cmd("noh")
  print("[VIM Reloaded]")
end, { silent = true })
