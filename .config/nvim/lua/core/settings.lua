-- GENERAL CONFIG --

local opt = vim.opt

vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.filetype = "on"
vim.opt.wildmenu = true
vim.opt.showmatch = true
vim.opt.ruler = true
vim.opt.swapfile = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.formatoptions:remove("cro")
vim.opt.splitbelow = true
vim.opt.timeoutlen = 250
vim.opt.linebreak = true
vim.opt.cursorline = false
vim.opt.cursorcolumn = false
vim.opt.wrap = true
vim.opt.termguicolors = true

-- This makes vim act like all other editors, buffers can exist in the background without being in a window.
opt.hidden = true
-- Make macros render faster (lazy draw)
opt.lazyredraw = true
