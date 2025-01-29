-- GENERAL CONFIG --

local opt = vim.opt

-- This makes vim act like all other editors, buffers can exist in the background without being in a window.

opt.hidden = true

-- Make macros render faster (lazy draw)

opt.lazyredraw = true
