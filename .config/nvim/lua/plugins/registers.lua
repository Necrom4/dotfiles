return {
  "tversteeg/registers.nvim",
  cmd = "Registers",
  config = true,
  opts = {
    window = {
      border = "rounded",
      transparency = 0,
    },
  },
  keys = {
    { "\"",    mode = { "n", "v" } },
    { "<C-R>", mode = "i" }
  },
  name = "registers",
}
