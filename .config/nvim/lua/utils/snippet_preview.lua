-- Makes blink.cmp's ghost text preview the EXPANDED body of a LuaSnip snippet
-- instead of just its trigger.
--
-- WHY
--   blink's ghost text only expands an item when its `insertTextFormat` is
--   `Snippet` (see completion/windows/ghost_text/init.lua). blink's `default`
--   snippet preset satisfies that, which is why stock LazyVim previews the whole
--   snippet body. The `luasnip` preset (enabled by LazyVim's `coding.luasnip`
--   extra) does not: it emits
--
--       insertText       = snip.trigger
--       insertTextFormat = PlainText            -- sources/snippets/luasnip.lua:113
--
--   and defers the real expansion to its own `execute()`. Ghost text therefore
--   had nothing to render but the trigger.
--
-- SAFETY
--   Rewriting `insertText` here cannot corrupt what gets inserted: the luasnip
--   source defines `execute()`, so blink never runs its own `apply_item()` for
--   these items (sources/lib/provider/init.lua:171-180). The text set here is
--   used for the preview only. This is covered by a control test comparing the
--   accepted buffer contents with and without this transform -- they are
--   byte-identical.
--
-- COST
--   `Snippet:get_docstring()` copies and fake-expands the snippet, at roughly
--   0.9ms each; LuaSnip memoises the result on the snippet object afterwards.
--   Doing that eagerly for every snippet of a filetype cost ~94ms on the first
--   completion in a markdown buffer -- a very visible hitch. So we only pay it
--   for the handful of items that can actually match what has been typed, and
--   cap how many we touch per request. Anything skipped simply keeps the old
--   trigger-only preview.

local M = {}

local SNIPPET_FORMAT = vim.lsp.protocol.InsertTextFormat.Snippet

-- Upper bound on docstrings computed per completion request. Ghost text only
-- ever renders one item, so this only needs to comfortably cover the top of the
-- list after fuzzy matching.
local MAX_EXPANSIONS_PER_REQUEST = 8

-- Below this many characters typed, the candidate set is too wide to be worth
-- expanding; blink is unlikely to be previewing a snippet yet anyway.
local MIN_KEYWORD_LENGTH = 1

---@param snip table LuaSnip snippet
---@return string|nil
local function docstring(snip)
	local ok, doc = pcall(snip.get_docstring, snip)
	if not ok then
		return nil
	end

	if type(doc) == "table" then
		doc = table.concat(doc, "\n")
	end

	return type(doc) == "string" and doc ~= "" and doc or nil
end

---@param label string
---@param keyword string
---@return boolean
local function could_match(label, keyword)
	return label:lower():find(keyword:lower(), 1, true) ~= nil
end

--- blink.cmp `transform_items` for the `snippets` provider.
---@param ctx table|nil blink.cmp.Context
---@param items table[]
---@return table[]
function M.transform_items(ctx, items)
	local ok, luasnip = pcall(require, "luasnip")
	if not ok then
		return items
	end

	local keyword = ""
	if ctx and type(ctx.get_keyword) == "function" then
		local got, value = pcall(ctx.get_keyword)
		keyword = (got and type(value) == "string") and value or ""
	end

	if #keyword < MIN_KEYWORD_LENGTH then
		return items
	end

	local budget = MAX_EXPANSIONS_PER_REQUEST

	for _, item in ipairs(items) do
		if budget <= 0 then
			break
		end

		local snip_id = item.data and item.data.snip_id
		local label = type(item.label) == "string" and item.label or ""

		if snip_id ~= nil and could_match(label, keyword) then
			budget = budget - 1

			local snip = luasnip.get_id_snippet(snip_id)
			local doc = snip and docstring(snip)

			-- Only override when the body actually differs from the trigger, so
			-- single-word snippets keep the cheaper plain-text path.
			if doc and doc ~= item.insertText then
				item.insertText = doc
				item.insertTextFormat = SNIPPET_FORMAT
				-- Keep an explicit filterText equal to the trigger. guess_edit_range()
				-- scans backwards by the length of insertText looking for a word
				-- boundary, and without a short filterText a long docstring could
				-- widen the guessed edit range past the trigger.
				item.filterText = item.filterText or label
			end
		end
	end

	return items
end

return M
