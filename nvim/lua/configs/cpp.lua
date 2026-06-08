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

		-- <leader>cg: regenerate compile_commands.json after CMakeLists.txt changes
		-- and restart clangd so diagnostics see new targets/macros/MOC paths.
		vim.keymap.set("n", "<leader>cg", function()
			vim.notify("CMake: generating compile_commands.json...", vim.log.levels.INFO)
			vim.fn.jobstart({ "cmake", "-G", "Ninja", "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON", "-B", build_dir, "-S", root }, {
				stdout_buffered = true,
				stderr_buffered = true,
				on_exit = function(_, code)
					vim.schedule(function()
						if code ~= 0 then
							vim.notify("CMake: generate failed", vim.log.levels.ERROR)
							return
						end

						local compile_commands = root .. "/compile_commands.json"
						local build_compile_commands = build_dir .. "/compile_commands.json"
						if not vim.uv.fs_stat(build_compile_commands) then
							vim.notify("CMake: compile_commands.json was not generated", vim.log.levels.ERROR)
							return
						end

						pcall(vim.uv.fs_unlink, compile_commands)
						local ok, err = vim.uv.fs_symlink("build/compile_commands.json", compile_commands)
						if not ok then
							vim.notify("CMake: symlink failed: " .. tostring(err), vim.log.levels.ERROR)
							return
						end

						vim.cmd("LspRestart clangd")
						vim.notify("CMake: generated; clangd restarted", vim.log.levels.INFO)
					end)
				end,
			})
		end, {
			buffer = buf,
			desc = "CMake: generate + restart clangd",
		})

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
