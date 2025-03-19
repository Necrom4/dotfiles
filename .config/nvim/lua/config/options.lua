local opt = vim.opt

opt.autowrite = false -- Enable auto write
opt.cursorline = false -- Enable highlighting of the current line
opt.list = false
opt.scrolloff = 0
opt.wrap = false -- Disable line wrap

-- This makes vim act like all other editors, buffers can exist in the background without being in a window.
opt.hidden = true
