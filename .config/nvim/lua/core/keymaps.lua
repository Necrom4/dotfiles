-- KEYMAPS --

-- SOURCE VIM CONFIGS

vim.keymap.set("n", "<leader>v", function()
  vim.cmd("luafile ~/.config/nvim/lua/core/settings.lua")
  vim.cmd("luafile ~/.config/nvim/lua/core/appearence.lua")
  vim.cmd("luafile ~/.config/nvim/lua/core/autocmds.lua")
  vim.cmd("luafile ~/.config/nvim/lua/core/keymaps.lua")
  vim.cmd("noh")
  print("[VIM Reloaded]")
end, { silent = true })

-- SAVE/QUIT

-- Save the current file
vim.api.nvim_set_keymap('n', '<c-s>', ':w<cr>', { noremap = true, silent = true })
-- Force save the current file with force
vim.api.nvim_set_keymap('n', '<c-s><c-s>', ':w!<cr>', { noremap = true, silent = true })
-- Save all files
vim.api.nvim_set_keymap('n', '<c-s><c-a>', ':wa<cr>', { noremap = true, silent = true })
-- Save and quit
vim.api.nvim_set_keymap('n', '<c-s><c-q>', ':wq<cr>', { noremap = true, silent = true })
-- Save all files and quit
vim.api.nvim_set_keymap('n', '<c-s><c-q>', ':waq<cr>', { noremap = true, silent = true })
-- Quit the current file
vim.api.nvim_set_keymap('n', '<c-q>', ':q<cr>', { noremap = true, silent = true })
-- Force quit the current file
vim.api.nvim_set_keymap('n', '<c-q><c-q>', ':q!<cr>', { noremap = true, silent = true })
-- Quit all files
vim.api.nvim_set_keymap('n', '<c-q><c-a>', ':qa<cr>', { noremap = true, silent = true })
-- Force quit all files
vim.api.nvim_set_keymap('n', '<c-q><c-a><c-q>', ':qa!<cr>', { noremap = true, silent = true })

-- CLEAR SELECTION

vim.keymap.set('n', '<leader>h', function()
  vim.cmd('noh')
  local search_pattern = vim.fn.getreg('/')
  vim.api.nvim_out_write('["' .. search_pattern .. '" cleared]\n')
end, { noremap = true, silent = true })

-- NAVIGATION
vim.keymap.set({ 'n', 'v' }, '<c-j>', '<c-f>', { noremap = true, silent = true })
vim.keymap.set({ 'n', 'v' }, '<c-k>', '<c-b>', { noremap = true, silent = true })
vim.keymap.set('n', 'MM', 'zz', { noremap = true, silent = true })
vim.keymap.set('n', 'J', 'L', { noremap = true, silent = true })
vim.keymap.set('n', 'K', 'H', { noremap = true, silent = true })
vim.keymap.set('n', 'L', '$', { noremap = true, silent = true })
vim.keymap.set('n', 'H', '0', { noremap = true, silent = true })
vim.keymap.set('n', 'gK', 'kgJ', { noremap = true, silent = true })
vim.keymap.set('n', ';j', '<c-o>', { noremap = true, silent = true })
vim.keymap.set('n', ';k', '<c-i>', { noremap = true, silent = true })
vim.keymap.set('n', '<c-s-k>', 'kzz', { noremap = true, silent = true })
vim.keymap.set('n', '<c-s-j>', 'jzz', { noremap = true, silent = true })
vim.keymap.set('i', '<c-h>', '<left>', { noremap = true, silent = true })
vim.keymap.set('i', '<c-j>', '<down>', { noremap = true, silent = true })
vim.keymap.set('i', '<c-k>', '<up>', { noremap = true, silent = true })
vim.keymap.set('i', '<c-l>', '<right>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-h>', '<left>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-j>', '<down>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-k>', '<up>', { noremap = true, silent = true })
vim.keymap.set('c', '<c-l>', '<right>', { noremap = true, silent = true })

-- COPY TEXT

-- Copy to system clipboard
vim.keymap.set("v", "<c-c>", '"+y', { noremap = true, silent = true })
-- Yank filename
vim.keymap.set('n', 'yp', function()
  vim.fn.setreg('"', vim.fn.expand('%'))  -- Set unnamed register to the file name
  vim.cmd('normal! p')  -- Paste the filename
end, { noremap = true, silent = true })
-- Yank full path
vim.keymap.set('n', 'yP', function()
  vim.fn.setreg('"', vim.fn.expand('%:p'))  -- Set unnamed register to the full path
  vim.cmd('normal! p')  -- Paste the path
end, { noremap = true, silent = true })
-- Yank cmd
vim.keymap.set('n', 'yc', function()
  vim.fn.setreg('"', vim.fn.getreg(':'))  -- Set unnamed register to the last command
  vim.cmd('normal! p')  -- Paste the command
end, { noremap = true, silent = true })

-- WINDOWS NAVIGATION

vim.keymap.set('t', '<c-q>', [[<c-\><c-n>:q<cr>]], { noremap = true, silent = true })
vim.keymap.set('t', '<c-w>', [[<c-\><c-n><c-w>]], { noremap = true, silent = true })
vim.keymap.set('t', '<s-esc>', [[<c-\><c-n>]], { noremap = true, silent = true })
vim.keymap.set('n', '<c-w>v', '<c-w>v<c-w>w', { noremap = true, silent = true })

-- TABS MANAGEMENT

vim.keymap.set('n', '<c-e>n', function()
  vim.cmd('tabnew')
  Snacks.dashboard.open()
end, { noremap = true, silent = true })

vim.keymap.set('n', '<c-e>l', 'gt', { noremap = true })
vim.keymap.set('n', '<c-e>h', 'gT', { noremap = true })
vim.keymap.set('n', '<c-e>q', ':tabclose<cr>', { noremap = true, silent = true })

-- COMMMENT
vim.api.nvim_set_keymap('n', '<leader>c', 'gc', { noremap = false })
vim.api.nvim_set_keymap('x', '<leader>c', 'gc', { noremap = false })
vim.api.nvim_set_keymap('o', '<leader>c', 'gc', { noremap = false })
vim.api.nvim_set_keymap('n', '<leader>cc', 'gcc', { noremap = false })

-- BETTER READABILITY
vim.keymap.set("n", "<leader>r", function()
  if vim.wo.wrap then
    vim.wo.wrap = false
    vim.cmd("LspStop")
  else
    vim.wo.wrap = true
    vim.cmd("LspStart")
  end
end)

-- LAZYVIM
vim.keymap.set('n', '<leader>l', ':Lazy<cr>', { noremap = true, silent = true })

-- OTHER

-- Remap ' to `
vim.keymap.set('n', "'", '`', { noremap = true })
-- Remap <c-/> to K
vim.keymap.set('n', '<c-/>', 'K', { noremap = true, silent = true })
-- Open current file
vim.keymap.set('n', '<leader>b', function()
  vim.fn.system('open ' .. vim.fn.expand('%'))
end, { noremap = true, silent = true })

