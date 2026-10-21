local function render_obsidian_block_id(ctx)
	local start_row, start_col, end_row = ctx.root:range()
	if start_row ~= end_row then
		return {}
	end

	local text = vim.treesitter.get_node_text(ctx.root, ctx.buf)
	local _, _, offset, block_id = text:find("()(%^[%w-]+)%s*$")
	if not offset or (offset > 1 and not text:sub(offset - 1, offset - 1):match("%s")) then
		return {}
	end

	local col = start_col + offset - 1
	return {
		{
			-- Keep the raw block ID highlighted when the replacement is anti-concealed.
			conceal = false,
			start_row = start_row,
			start_col = col,
			opts = {
				end_col = col + #block_id,
				hl_group = "RenderMarkdownLink",
			},
		},
		{
			conceal = "link",
			start_row = start_row,
			start_col = col,
			opts = {
				end_col = col + #block_id,
				conceal = "",
				hl_mode = "combine",
				virt_text = { { "", "RenderMarkdownLink" } },
				virt_text_pos = "inline",
			},
		},
	}
end

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			bullet = {
				left_pad = 4,
			},
			checkbox = {
				enabled = true,
				left_pad = 4,
				right_pad = 1,
				unchecked = {
					icon = "󰄱",
					highlight = "RenderMarkdownUnchecked",
				},
				checked = {
					icon = "󰡖",
					highlight = "RenderMarkdownChecked",
				},
				custom = {
					todo = {
						raw = "[/]",
						rendered = "󰥔",
						highlight = "RenderMarkdownTodo",
					},
					important = {
						raw = "[!]",
						rendered = "",
						highlight = "Error",
					},
					delete = {
						raw = "[-]",
						rendered = "",
						highlight = "NonText",
					},
					pause = {
						raw = "[=]",
						rendered = "",
						highlight = "String",
					},
					redo = {
						raw = "[+]",
						rendered = "",
						highlight = "@keyword",
					},
					unsure = {
						raw = "[?]",
						rendered = "",
						highlight = "@boolean",
					},
				},
			},
			custom_handlers = {
				markdown_inline = {
					extends = true,
					parse = render_obsidian_block_id,
				},
			},
			heading = {
				icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
			},
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		enabled = false,
	},
	{
		"selimacerbas/mdkite.nvim",
		dependencies = { "selimacerbas/kitehost.nvim" },
		ft = { "markdown", "mermaid" },
		config = function()
			require("mdkite").setup({
				mermaid_elk = true,
			})

			local util = require("mdkite.util")
			local read_text = util.read_text
			util.read_text = function(path, ...)
				local s = read_text(path, ...)
				if type(s) == "string" and tostring(path):match("index%.html$") then
					s = (s:gsub("startOnLoad: false,", "startOnLoad: false, layout: 'elk',", 1))
				end
				return s
			end
		end,
		keys = {
			{
				"<leader>cp",
				ft = { "markdown", "mermaid" },
				"<cmd>MdKite toggle<cr>",
				desc = "Markdown Preview",
			},
		},
	},
}
