-- AUTOCMDS --

local opt = vim.opt

-- PERSISTENT UNDO

opt.undofile = true
local vimrc_undofile_augroup = vim.api.nvim_create_augroup('vimrc_undofile', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '/tmp/*',
  group = vimrc_undofile_augroup,
  command = 'setlocal noundofile',
})

-- YANK TO NUMBER REGISTERS

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" then
      -- Shift registers "9" to "2" down
      for i = 9, 2, -1 do
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
      end
      -- Store the new yank in register "1" (but don't touch "0")
      vim.fn.setreg("1", vim.fn.getreg('"'))
    end
  end
})

-- TOGGLE COLUMN NUMBER DISPLAY ON MODE SWITCH

vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  callback = function() vim.opt_local.relativenumber = false end
})

vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  callback = function() vim.opt_local.relativenumber = true end
})

-- Set embedded templating languages
vim.cmd [[
  autocmd BufRead,BufNewFile *.tpl.yaml set filetype=helm
]]

