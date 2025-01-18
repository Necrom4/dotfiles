return {
  "petertriho/nvim-scrollbar",
  dependencies = { "kevinhwang91/nvim-hlslens", },
  opts = {
    handle = {
      color = '#600000',
    },
    marks = {
      Search = { color = '#D00000' },
      Error = { color = '#D00000' },
      Warn = { color = '#D00000' },
      Info = { color = '#D00000' },
      Hint = { color = '#D00000' },
      Misc = { color = '#D00000' },
    },
    handlers = { search = true },
  }
}
