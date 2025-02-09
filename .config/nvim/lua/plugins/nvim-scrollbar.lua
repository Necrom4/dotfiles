return {
  "petertriho/nvim-scrollbar",
  dependencies = { "kevinhwang91/nvim-hlslens", },
  event = { "BufNewFile", "BufReadPost" },
  opts = {
    handle = {
      color = '#7F0000',
    },
    marks = {
      Search = { color = '#FF0000' },
      Error = { color = '#FF0000' },
      Warn = { color = '#7F0000' },
      Info = { color = '#7F0000' },
      Hint = { color = '#7F0000' },
      Misc = { color = '#7F0000' },
    },
    handlers = { search = true },
  }
}
