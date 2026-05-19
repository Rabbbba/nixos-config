-- C++ filetype workflow: drive a CMake build via :make and add
-- buffer-local keymaps for build/run. Wired up from autocmds.lua.

local autocmd = vim.api.nvim_create_autocmd

-- Notify on :make completion. Global (any :make), since QuickFixCmdPost
-- fires for the command, not a buffer. Counts only "valid" entries —
-- Ninja progress lines don't match errorformat and stay invalid.
autocmd("QuickFixCmdPost", {
	pattern = "make",
	callback = function()
		local errs = vim.tbl_filter(function(it)
			return it.valid == 1
		end, vim.fn.getqflist())
		if #errs == 0 then
			vim.notify("Build OK", vim.log.levels.INFO)
		else
			vim.notify("Build FAILED — " .. #errs .. " issue(s)", vim.log.levels.ERROR)
			vim.cmd("botright cwindow")
		end
	end,
})

autocmd("FileType", {
	pattern = "cpp",
	callback = function(ctx)
		local buf = ctx.buf
		local file = vim.api.nvim_buf_get_name(buf)

		-- Nearest CMakeLists.txt ancestor is treated as the project root.
		local root = vim.fs.root(file, { "CMakeLists.txt" })
		if not root then
			return
		end

		local build_dir = root .. "/build"
		vim.bo[buf].makeprg = "cmake --build " .. vim.fn.fnameescape(build_dir)

		-- <leader>cb: build. Errors land in the quickfix list — :copen, :cnext, :cprev.
		vim.keymap.set("n", "<leader>cb", "<cmd>make<cr>", {
			buffer = buf,
			desc = "C++: build (cmake)",
		})

		-- <leader>cr: run target derived from <parent-dir>_<file-stem>.
		-- Matches the CMakeLists glob naming (e.g. c1_s1_intro/01_hello.cpp → c1_s1_intro_01_hello).
		vim.keymap.set("n", "<leader>cr", function()
			local stem = vim.fn.expand("%:t:r")
			local section = vim.fn.expand("%:h:t")
			local target = section .. "_" .. stem
			local binary = build_dir .. "/" .. target
			if vim.fn.executable(binary) == 0 then
				vim.notify("C++: not built yet — " .. target, vim.log.levels.WARN)
				return
			end
			vim.cmd("botright split | resize 12 | terminal " .. vim.fn.fnameescape(binary))
		end, {
			buffer = buf,
			desc = "C++: run current file's target",
		})
	end,
})
