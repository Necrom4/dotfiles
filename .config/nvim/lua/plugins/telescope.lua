return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      "nvim-telescope/telescope-live-grep-args.nvim" ,
      version = "^1.0.0",
    },
  },
  opts = {
    defaults = {
      path_display = { "smart" },
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
    extension = {
      live_grep_args = {},
    },
  },
  keys = {
    { '<leader>f', ":Telescope<CR>" },
    { '<leader>f', "y<ESC>:Telescope live_grep_args default_text=<C-r>0<CR>", mode = 'v' },
  },
  cmd = 'Telescope',
}
