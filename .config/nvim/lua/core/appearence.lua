-- STATUSLINE CONFIG

-- Disable showmode and enable global statusline
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.o.showtabline = 1

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌶", texthl = "DiagnosticHint" })
