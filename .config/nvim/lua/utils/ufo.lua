-- From @nickkadutskyi on GitHub

---@class kdtsk.utils.fold
local M = {}

-- =============================================================================
-- PROVIDER SELECTION
-- =============================================================================

---@param bufnr number
---@return Promise
function M.ufo_provider_selector(bufnr)
	local function handleFallbackException(err, providerName)
		if type(err) == "string" and err:match("UfoFallbackException") then
			return require("ufo").getFolds(bufnr, providerName)
		else
			return require("promise").reject(err)
		end
	end

	local filetype = vim.bo[bufnr].filetype
	local buftype = vim.bo[bufnr].buftype

	-- Skip folding for special buffer types
	if buftype ~= "" then
		return require("promise").resolve({})
	end

	-- Use indent for older files without treesitter support
	local indent_only_fts = { "vim", "help", "conf", "text" }
	if vim.tbl_contains(indent_only_fts, filetype) then
		return require("ufo").getFolds(bufnr, "indent")
	end

	return require("ufo")
		.getFolds(bufnr, "lsp")
		:catch(function(err)
			return handleFallbackException(err, "treesitter")
		end)
		:catch(function(err)
			return handleFallbackException(err, "indent")
		end)
end

-- =============================================================================
-- PATTERN MATCHERS
-- =============================================================================

-- Block comment patterns
local function is_block_comment(firstText, endText)
	local patterns = {
		-- C-style block comments: /* */ and /** */
		{ start = "/%*", finish = "%*/" },
		-- HTML/XML comments: <!-- -->
		{ start = "<!%-%-", finish = "%-%->" },
		-- Shell/Perl block markers: # BEGIN / # END
		{ start = "#%s*BEGIN", finish = "#%s*END" },
		-- Pod documentation: = begin / = end
		{ start = "=%s*begin", finish = "=%s*end" },
	}

	for _, pattern in ipairs(patterns) do
		if firstText:match(pattern.start) and endText:match(pattern.finish) then
			return true
		end
	end
	return false
end

-- HTML/XML tag patterns
local function is_html_xml_tag(firstText, endText)
	return firstText:match("<%s*[%w:_%.%-]+") and endText:match("</%s*[%w:_%.%-]+%s*>")
end

-- Simple bracket/brace patterns
local function is_simple_bracket(firstText, endText)
	local brackets = {
		{ open = "{%s*$", close = "^%s*}%s*$" },
		{ open = "{%s*$", close = "^%s*},%s*$" },
		{ open = "{%s*$", close = "^%s*}%)%s*$" },
		{ open = "{%s*$", close = "^%s*}.*%)%s*$" },
		{ open = "%[%s*$", close = "^%s*]%s*$" },
		{ open = "%(%s*$", close = "^%s*%)%s*$" },
	}

	for _, bracket in ipairs(brackets) do
		if firstText:match(bracket.open) and endText:match(bracket.close) then
			return true
		end
	end
	return false
end

-- Lua language patterns
local function is_lua_construct(firstText, endText)
	-- Function definitions
	local function_patterns_start = {
		"function%s*[^%(]*%(.*%)%s*$", -- function name with parameters
		"function%(.*%)%s*$", -- anonymous function
	}
	local function_patterns_end = {
		"^%s*end[,%)]*%s*$", -- end of function
	}
	for _, start_pattern in ipairs(function_patterns_start) do
		for _, end_pattern in ipairs(function_patterns_end) do
			if firstText:match(start_pattern) and endText:match(end_pattern) then
				return true
			end
		end
	end

	-- Control structures with 'then' or 'do'
	local control_patterns = {
		"if%s+.*%s+then%s*$",
		"for%s+.*%s+do%s*$",
		"while%s+.*%s+do%s*$",
		"repeat%s*$",
	}

	for _, pattern in ipairs(control_patterns) do
		if firstText:match(pattern) and endText:match("^%s*end%s*$") then
			return true
		end
	end

	-- Repeat ... until
	if firstText:match("repeat%s*$") and endText:match("^%s*until%s+") then
		return true
	end

	return false
end

-- Python language patterns
local function is_python_construct(firstText, endText)
	local python_patterns = {
		"def%s+",
		"class%s+",
		"if%s+.*:$",
		"elif%s+.*:$",
		"else%s*:$",
		"for%s+.*:$",
		"while%s+.*:$",
		"with%s+.*:$",
		"try%s*:$",
		"except%s*.*:$",
		"finally%s*:$",
	}

	for _, pattern in ipairs(python_patterns) do
		if firstText:match(pattern) and endText:match("^%s*$") then
			return true, false -- Python doesn't show end line
		end
	end
	return false
end

-- Ruby language patterns
local function is_ruby_construct(firstText, endText)
	local ruby_patterns = {
		"def%s+",
		"class%s+",
		"module%s+",
		"if%s+",
		"unless%s+",
		"case%s+",
		"begin%s*$",
		"while%s+",
		"until%s+",
	}

	for _, pattern in ipairs(ruby_patterns) do
		if firstText:match(pattern) and endText:match("^%s*end%s*$") then
			return true
		end
	end
	return false
end

-- Shell language patterns
local function is_shell_construct(firstText, endText)
	local shell_start_patterns = {
		"if%s+.*then%s*$",
		"for%s+.*do%s*$",
		"while%s+.*do%s*$",
		"case%s+.*in%s*$",
		"function%s+.*%(%)%s*{?%s*$",
	}

	local shell_end_patterns = {
		"^%s*fi%s*.*$",
		"^%s*done%s*.*$",
		"^%s*esac%s*.*$",
		"^%s*}%s*$",
	}

	for _, start_pattern in ipairs(shell_start_patterns) do
		if firstText:match(start_pattern) then
			for _, end_pattern in ipairs(shell_end_patterns) do
				if endText:match(end_pattern) then
					return true
				end
			end
		end
	end
	return false
end

-- JavaScript/TypeScript language patterns
local function is_js_ts_construct(firstText, endText)
	local js_patterns = {
		"function%s*[^%(]*%(.*%)%s*{%s*$",
		"class%s+%w+.*{%s*$",
		"if%s*%(.*%)%s*{%s*$",
		"for%s*%(.*%)%s*{%s*$",
		"while%s*%(.*%)%s*{%s*$",
		"switch%s*%(.*%)%s*{%s*$",
		"try%s*{%s*$",
		"catch%s*%(.*%)%s*{%s*$",
		"finally%s*{%s*$",
	}

	for _, pattern in ipairs(js_patterns) do
		if firstText:match(pattern) and endText:match("^%s*}%s*$") then
			return true
		end
	end
	return false
end

-- Exclusion patterns (constructs that should NOT show end line)
local function should_exclude(firstText)
	local exclusion_patterns = {
		"^%s*import%s", -- Import statements
		"^%s*export%s", -- Export statements
		"^%s*//", -- Single line comments
	}

	for _, pattern in ipairs(exclusion_patterns) do
		if firstText:match(pattern) then
			return true
		end
	end
	return false
end

-- =============================================================================
-- FOLD DETECTION LOGIC
-- =============================================================================

---@return boolean, boolean|nil
local function should_show_end_line(firstText, secondText, endText, foldKind)
	-- Check exclusions first
	if should_exclude(firstText) then
		return false
	end

	-- Block comments (highest priority)
	if is_block_comment(firstText, endText) then
		return true
	end
	-- Non-block comments have no closing delimiter to show.
	if foldKind == "comment" then
		return false
	end

	-- Fold kind-based detection
	if foldKind == "object" or foldKind == "array" or foldKind == "block" then
		return true
	elseif foldKind == "imports" then
		return false
	end

	-- Language-specific pattern matching
	if is_html_xml_tag(firstText, endText) then
		return true
	end

	if is_simple_bracket(firstText, endText) then
		return true
	end

	if is_simple_bracket(firstText .. secondText, endText) then
		return true, true
	end

	if is_lua_construct(firstText, endText) then
		return true
	end

	local is_python, python_show_end = is_python_construct(firstText, endText)
	if is_python then
		return python_show_end
	end

	if is_ruby_construct(firstText, endText) then
		return true
	end

	if is_shell_construct(firstText, endText) then
		return true
	end

	if is_js_ts_construct(firstText, endText) then
		return true
	end

	return false
end

-- =============================================================================
-- VIRTUAL TEXT HANDLERS
-- =============================================================================

-- Appends chunks while they fit in maxWidth, truncating the one that overflows.
---@return number curWidth, boolean full
local function append_chunks(dst, chunks, curWidth, maxWidth, truncate, trim_start)
	for i, chunk in ipairs(chunks) do
		local chunkText = chunk[1]
		if trim_start and i == 1 then
			chunkText = (chunkText:gsub("^%s+", ""))
		end
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if curWidth + chunkWidth > maxWidth then
			if maxWidth > curWidth then
				chunkText = truncate(chunkText, maxWidth - curWidth)
				table.insert(dst, { chunkText, chunk[2] })
				curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
			end
			return curWidth, true
		end
		table.insert(dst, { chunkText, chunk[2] })
		curWidth = curWidth + chunkWidth
	end
	return curWidth, false
end

function M.ufo_virt_text_handler_enhanced(virtText, lnum, endLnum, width, truncate, ctx)
	local newVirtText = {}
	local filling = (" 󱞡%d "):format(endLnum - lnum)
	-- The filling is always shown, so reserve its width up front.
	local targetWidth = width - vim.fn.strdisplaywidth(filling)

	-- Add the first line content
	local curWidth, full = append_chunks(newVirtText, virtText, 0, targetWidth, truncate)
	if full then
		table.insert(newVirtText, { filling, "UfoFoldedEllipsis" })
		return newVirtText
	end

	-- Extract text for analysis
	local firstLineText = ctx.text or ""

	local secondLineText = ""
	local secondLineHlGroup = "UfoFoldedEllipsis"
	if lnum + 1 <= endLnum then
		local secondVirtText = ctx.get_fold_virt_text(lnum + 1)
		for _, chunk in ipairs(secondVirtText) do
			secondLineText = secondLineText .. chunk[1]
			if chunk[2] then
				secondLineHlGroup = chunk[2]
			end
		end
		secondLineText = secondLineText:gsub("^%s+", ""):gsub("%s+$", "")
	end

	local endVirtText = ctx.get_fold_virt_text(endLnum)
	local endLineText = ""
	for _, chunk in ipairs(endVirtText) do
		endLineText = endLineText .. chunk[1]
	end
	endLineText = endLineText:gsub("^%s+", ""):gsub("%s+$", "")

	-- Determine if we should show the end line
	local foldKind = ctx.get_fold_kind and ctx.get_fold_kind() or ""
	local showEndLine, usedSecondLine = should_show_end_line(firstLineText, secondLineText, endLineText, foldKind)

	if not showEndLine then
		table.insert(newVirtText, { filling, "UfoFoldedEllipsis" })
		return newVirtText
	end

	if usedSecondLine then
		curWidth, full = append_chunks(
			newVirtText,
			{ { secondLineText, secondLineHlGroup } },
			curWidth,
			targetWidth,
			truncate
		)
	end
	table.insert(newVirtText, { filling, "UfoFoldedEllipsis" })

	-- The suffix sits before the last line; count it when fitting that line.
	if not full then
		append_chunks(newVirtText, endVirtText, curWidth + vim.fn.strdisplaywidth(filling), width, truncate, true)
	end

	return newVirtText
end

return M
