-- Custom snippets, enabled by the `coding.luasnip` LazyVim extra.
--
-- Every snippet defined here is registered through `extend_decorator`, which
-- prefixes its trigger with ";". That keeps hand-written snippets from
-- colliding with real words while typing, and avoids having to strip a prefix
-- in blink.cmp's transform_items (which does not work for triggers that begin
-- with a symbol, e.g. ```bash).
-- See https://github.com/L3MON4D3/LuaSnip/discussions/895

return {
	"L3MON4D3/LuaSnip",
	opts = function(_, opts)
		local ls = require("luasnip")

		local extend_decorator = require("luasnip.util.extend_decorator")

		local function auto_semicolon(context)
			if type(context) == "string" then
				return { trig = ";" .. context }
			end
			return vim.tbl_extend("keep", { trig = ";" .. context.trig }, context)
		end

		extend_decorator.register(ls.s, {
			arg_indx = 1,
			extend = function(original)
				return auto_semicolon(original)
			end,
		})

		local s = extend_decorator.apply(ls.s, {})
		local t = ls.text_node
		local i = ls.insert_node
		local f = ls.function_node

		local function clipboard()
			return vim.fn.getreg("+")
		end

		-- #####################################################################
		--                            Markdown
		-- #####################################################################

		local snippets = {}

		-- Fenced code blocks: `;lua`, `;bash`, `;go`, ...
		local function create_code_block_snippet(lang)
			return s({
				trig = lang,
				name = "Codeblock",
				desc = lang .. " codeblock",
			}, {
				t({ "```" .. lang, "" }),
				i(1),
				t({ "", "```" }),
			})
		end

		local languages = {
			"bash",
			"cpp",
			"css",
			"csv",
			"dockerfile",
			"go",
			"html",
			"java",
			"javascript",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"markdown_inline",
			"php",
			"python",
			"regex",
			"sql",
			"templ",
			"txt",
			"yaml",
		}

		for _, lang in ipairs(languages) do
			table.insert(snippets, create_code_block_snippet(lang))
		end

		table.insert(
			snippets,
			s({
				trig = "markdownlint",
				name = "Add markdownlint disable and restore headings",
				desc = "Add markdownlint disable and restore headings",
			}, {
				t({ " ", "<!-- markdownlint-disable -->", " ", "> " }),
				i(1),
				t({ " ", " ", "<!-- markdownlint-restore -->" }),
			})
		)

		table.insert(
			snippets,
			s({
				trig = "prettierignore",
				name = "Add prettier ignore start and end headings",
				desc = "Add prettier ignore start and end headings",
			}, {
				t({ " ", "<!-- prettier-ignore-start -->", " ", "> " }),
				i(1),
				t({ " ", " ", "<!-- prettier-ignore-end -->" }),
			})
		)

		table.insert(
			snippets,
			s({
				trig = "linkt",
				name = 'Add this -> [](){:target="_blank"}',
				desc = 'Add this -> [](){:target="_blank"}',
			}, {
				t("["),
				i(1),
				t("]("),
				i(2),
				t('){:target="_blank"}'),
			})
		)

		table.insert(
			snippets,
			s({
				trig = "todo",
				name = "Add TODO: item",
				desc = "Add TODO: item",
			}, {
				t("<!-- TODO: "),
				i(1),
				t(" -->"),
			})
		)

		-- Paste clipboard contents as the link target, cursor lands on the label
		table.insert(
			snippets,
			s({
				trig = "linkc",
				name = "Paste clipboard as .md link",
				desc = "Paste clipboard as .md link",
			}, {
				t("["),
				i(1),
				t("]("),
				f(clipboard, {}),
				t(")"),
			})
		)

		table.insert(
			snippets,
			s({
				trig = "linkex",
				name = "Paste clipboard as EXT .md link",
				desc = "Paste clipboard as EXT .md link",
			}, {
				t("["),
				i(1),
				t("]("),
				f(clipboard, {}),
				t('){:target="_blank"}'),
			})
		)

		ls.add_snippets("markdown", snippets)

		return opts
	end,
}
