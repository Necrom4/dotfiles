return {
	"nvim-mini/mini.diff",
	version = false,
	event = "LazyFile",
	config = function()
		local MiniDiff = require("mini.diff")
		local save = MiniDiff.gen_source.save()
		local states = {}

		local function clear_gitsigns_maps(buf)
			for _, lhs in ipairs({ "]g", "[g", "]G", "[G", "<leader>gs", "<leader>gr", "<leader>gS", "<leader>gu", "<leader>gR", "<leader>gp", "<leader>gb", "<leader>gB", "<leader>gd", "<leader>gD" }) do
				for _, mode in ipairs({ "n", "x" }) do
					pcall(vim.keymap.del, mode, lhs, { buffer = buf })
				end
			end
			for _, mode in ipairs({ "o", "x" }) do
				pcall(vim.keymap.del, mode, "ig", { buffer = buf })
			end
		end

		local function resolve(buf, state, tracked)
			state.status = tracked and "tracked" or "untracked"
			vim.b[buf].minidiff_untracked = not tracked
			if tracked then
				vim.b[buf].minidiff_disable = true
				MiniDiff.disable(buf)
				-- A newly staged file may have been skipped by Gitsigns earlier.
				if package.loaded.gitsigns and not vim.b[buf].minidiff_gitsigns_attached then
					require("gitsigns").attach({ bufnr = buf })
				end
				return
			end
			if vim.b[buf].minidiff_gitsigns_attached and package.loaded.gitsigns then
				require("gitsigns").detach(buf)
				clear_gitsigns_maps(buf)
				vim.b[buf].minidiff_gitsigns_attached = false
			end
			vim.b[buf].minidiff_disable = false
			if not MiniDiff.get_buf_data(buf) then
				MiniDiff.enable(buf)
			end
		end

		local request
		request = function(buf, invalidate)
			if not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" or not vim.bo[buf].buflisted then
				return
			end
			local file = vim.api.nvim_buf_get_name(buf)
			local state = states[buf]
			if state and state.file == file and not invalidate then
				return
			end
			local generation = (state and state.generation or 0) + 1
			state = { file = file, generation = generation }
			states[buf] = state
			vim.b[buf].minidiff_untracked = nil
			vim.b[buf].minidiff_disable = true
			MiniDiff.disable(buf)

			local function current()
				return states[buf] == state
					and states[buf].generation == generation
					and vim.api.nvim_buf_is_loaded(buf)
					and vim.api.nvim_buf_get_name(buf) == file
			end
			local function run(args, callback)
				local ok = pcall(vim.system, args, { text = true }, function(result)
					vim.schedule(function()
						if current() then
							callback(result)
						end
					end)
				end)
				if not ok then
					vim.schedule(function()
						if current() then
							callback({ code = -1 })
						end
					end)
				end
			end

			if file == "" then
				resolve(buf, state, false)
				return
			end
			local dir = vim.fs.dirname(file)
			run({ "git", "-C", dir, "ls-files", "--error-unmatch", "--", file }, function(git)
				if git.code == 0 then
					resolve(buf, state, true)
					return
				end
				-- Gitsigns still owns an index deletion until it is removed from HEAD.
				run({ "git", "-C", dir, "ls-tree", "-r", "--name-only", "HEAD", "--", file }, function(head)
					if head.code == 0 and head.stdout ~= "" then
						resolve(buf, state, true)
						return
					end
					local home = vim.env.HOME
					if not home or not vim.startswith(file, home .. "/") or vim.fn.executable("yadm") == 0 then
						resolve(buf, state, false)
						return
					end
					run({ "yadm", "ls-files", "--error-unmatch", "--", file }, function(yadm)
						resolve(buf, state, yadm.code == 0)
					end)
				end)
			end)
		end

		MiniDiff.setup({
			view = {
				style = "sign",
				signs = {
					add = "┆",
					change = "┆",
					delete = "┄",
				},
			},
			source = {
				name = "untracked-save",
				attach = function(buf)
					local state = states[buf]
					if not state or state.file ~= vim.api.nvim_buf_get_name(buf) then
						request(buf)
					end
					if vim.b[buf].minidiff_disable or not states[buf] or states[buf].status ~= "untracked" then
						return false
					end
					return save.attach(buf)
				end,
				detach = save.detach,
			},
			mappings = {
				apply = "",
				textobject = "ig",
				goto_prev = "[g",
				goto_next = "]g",
			},
		})
		local group = vim.api.nvim_create_augroup("MiniDiffUntrackedOnly", { clear = true })
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			callback = function(event)
				request(event.buf)
			end,
		})
		vim.api.nvim_create_autocmd({ "BufWritePost", "BufFilePost" }, {
			group = group,
			callback = function(event)
				request(event.buf, true)
			end,
		})
		vim.api.nvim_create_autocmd("FocusGained", {
			group = group,
			callback = function()
				-- Invalidate hidden buffers too, but only spawn checks for visible ones.
				local visible = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					visible[vim.api.nvim_win_get_buf(win)] = true
				end
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if visible[buf] then
						request(buf, true)
					elseif states[buf] then
						states[buf] = nil
						vim.b[buf].minidiff_untracked = nil
						vim.b[buf].minidiff_disable = true
						MiniDiff.disable(buf)
					end
				end
			end,
		})
		vim.api.nvim_create_autocmd("BufDelete", {
			group = group,
			callback = function(event)
				states[event.buf] = nil
			end,
		})
	end,
}
