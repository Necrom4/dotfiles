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

	-- Use syntax for older files without treesitter support
	local syntax_only_fts = { "vim", "help", "conf", "text" }
	if vim.tbl_contains(syntax_only_fts, filetype) then
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
		-- HTML comments: <!-- -->
		{ start = "<!%-%-", finish = "%-%->" },
		-- Shell/Perl block markers: # BEGIN / # END
		{ start = "#%s*BEGIN", finish = "#%s*END" },
		-- Pod documentation: = begin / = end
		{ start = "=%s*begin", finish = "=%s*end" },
		-- XML comments: <!-- -->
		{ start = "<!--", finish = "-->" },
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
	return firstText:match("<%s*%w+") and endText:match("</%s*%w+>")
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

function M.ufo_virt_text_handler_enhanced(virtText, lnum, endLnum, width, truncate, ctx)
	local newVirtText = {}
	local filling = (" 󱞡%d "):format(endLnum - lnum)
	local suffix = ""
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0

	-- Add the first line content
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
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

	if showEndLine then
		if usedSecondLine then
			table.insert(newVirtText, { secondLineText, secondLineHlGroup })
		end
		table.insert(newVirtText, { filling, "UfoFoldedEllipsis" })

		-- Add the last line content
		for i, chunk in ipairs(endVirtText) do
			local chunkText = chunk[1]
			local hlGroup = chunk[2]
			if i == 1 then
				chunkText = chunkText:gsub("^%s+", "")
			end
			local chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if targetWidth > curWidth + chunkWidth then
				table.insert(newVirtText, { chunkText, hlGroup })
			else
				chunkText = truncate(chunkText, targetWidth - curWidth)
				table.insert(newVirtText, { chunkText, hlGroup })
				break
			end
			curWidth = curWidth + chunkWidth
		end
	else
		table.insert(newVirtText, { filling, "UfoFoldedEllipsis" })
	end

	return newVirtText
end

-- =============================================================================
-- ALTERNATIVE HANDLERS
-- =============================================================================

function M.ufo_virt_text_handler_one_line(virtText, lnum, endLnum, width, truncate, ctx)
	-- include the bottom line in folded text for additional context
	local filling = " ⋯ "
	local suffix = ""
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	table.insert(virtText, { filling, "Folded" })
	local endVirtText = ctx.get_fold_virt_text(endLnum)
	for i, chunk in ipairs(endVirtText) do
		local chunkText = chunk[1]
		local hlGroup = chunk[2]
		if i == 1 then
			chunkText = chunkText:gsub("^%s+", "")
		end
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(virtText, { chunkText, hlGroup })
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			table.insert(virtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			-- str width returned from truncate() may less than 2nd argument, need padding
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	return virtText
end

-- Simple fold text that just shows line count
function M.ufo_virt_text_handler_simple(virtText, lnum, endLnum, width, truncate, ctx)
	local newVirtText = {}
	local suffix = (" ⋯ %d lines"):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0

	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end

	table.insert(newVirtText, { suffix, "Folded" })
	return newVirtText
end

return M
