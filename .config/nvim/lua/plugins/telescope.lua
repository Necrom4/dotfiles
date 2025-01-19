return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = {
      -- path_display = { "smart" },
      mappings = {
        i = {
          ["<esc>"] = "close",
          ["<c-q>"] = "close",
          ["<c-d>"] = "delete_buffer",
          ["<c-r>"] = "delete_mark",
          ["<c-k>"] = "move_selection_previous",
          ["<c-j>"] = "move_selection_next",
          ["<c-l>"] = "select_default",
          -- ["<c-b>"] = function() vim.cmd "normal! delmarks" end,
        },
      },
      dynamic_preview_title = true,
    },
    pickers = {
      find_files = {
        hidden = { true },
      },
      grep_string = {
        additional_args = { "--hidden" },
      },
      live_grep = {
        additional_args = { "--hidden" },
      },
    },
  },
  keys = {
    { '<leader>f', ":Telescope<CR>" },
    { '<leader>f', "y<ESC>:Telescope live_grep default_text=<C-r>0<CR>", mode = 'v' },
  },
  cmd = 'Telescope',
}
