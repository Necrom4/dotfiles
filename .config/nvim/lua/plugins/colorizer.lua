return {
  "catgoose/nvim-colorizer.lua",
  event = { "BufNewFile", "BufReadPost" },
  opts = {
    filetypes = {
      "*",
    },
    user_default_options = {
      always_update = true,
    }
  }
}
