local M = {}

local home = vim.fn.expand("$HOME")
local yadm_repo = home .. "/.local/share/yadm/repo.git"

-- Run a git command and report its output as a notification.
function M.run(args)
	if not args[#args] or args[#args] == "" then
		return
	end
	local out = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
	if out.code ~= 0 then
		Snacks.notify.error(vim.trim(out.stderr or ""), { title = "git " .. args[1] })
	elseif vim.trim(out.stdout or "") ~= "" then
		Snacks.notify.info(vim.trim(out.stdout), { title = "git " .. args[1] })
	end
end

function M.add_current_file()
	M.run({ "add", "--", vim.api.nvim_buf_get_name(0) })
end

-- YADM
function M.yadm_config(key)
	return require("utils.general").term_cmd(
		string.format(
			"GIT_DIR=%s GIT_WORK_TREE=%s git config %s",
			vim.fn.shellescape(yadm_repo),
			vim.fn.shellescape(home),
			vim.fn.shellescape(key)
		)
	)
end

function M.is_yadm_repo(path)
	local config = home .. "/.config"
	path = path or vim.fn.getcwd()
	return path == home or path == config or vim.startswith(path, config .. "/")
end

M.original_git_dir = nil

-- Point $GIT_DIR at the yadm repo (or back), so git tools work on dotfiles.
function M.switch_git_dir()
	if vim.env.GIT_DIR == yadm_repo then
		vim.env.GIT_DIR = M.original_git_dir
		M.original_git_dir = nil
		print("In Project Repo")
	else
		M.original_git_dir = vim.env.GIT_DIR or nil
		vim.env.GIT_DIR = yadm_repo
		print("In Yadm Repo")
	end
end

function M.pick_yadm_files()
	Snacks.dashboard.pick("git_files", {
		cwd = home,
		args = { "--git-dir=" .. yadm_repo, "--work-tree=" .. home },
	})
end

return M
