local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local vimsettings = "~/.config/nvim/lua/core"
local settingsfiles = vim.fn.split(vim.fn.globpath(vimsettings, "*.lua"), "\n")

for _, fpath in ipairs(settingsfiles) do
  dofile(fpath)
end

require("lazy").setup({
  spec = {
    { import = "plugins" }
  },
  ui = {
    border = "rounded",
  },
})
