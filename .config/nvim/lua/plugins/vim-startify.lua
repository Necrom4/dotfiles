return {
  "mhinz/vim-startify",
  config = function()
    -- Function definition for webDevIcons
    function _G.webDevIcons(path)
      local filename = vim.fn.fnamemodify(path, ':t')
      local extension = vim.fn.fnamemodify(path, ':e')
      return require'nvim-web-devicons'.get_icon(filename, extension, { default = true })
    end
  end
}
