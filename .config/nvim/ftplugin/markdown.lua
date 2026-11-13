-- Turn the selection (or the word under the cursor) into a markdown link.
-- Take the URL from: "x prefix register > clipboard (if it is a URL) > register picker
local markdown_link = require("utils.markdown_link")

vim.keymap.set({ "x", "n" }, "gsl", function()
	markdown_link.link()
end, { buffer = true, desc = "Surround with markdown link (clipboard)" })
vim.keymap.set({ "x", "n" }, "gsL", function()
	markdown_link.link({ pick = true })
end, { buffer = true, desc = "Surround with markdown link (pick register)" })
