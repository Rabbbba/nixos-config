require("nvchad.mappings")

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<F5>", function()
	require("dap").continue()
end)
map("n", "<F10>", function()
	require("dap").step_over()
end)
map("n", "<F11>", function()
	require("dap").step_into()
end)
map("n", "<F12>", function()
	require("dap").step_out()
end)
map("n", "<F9>", function()
	require("dap").toggle_breakpoint()
end)

-- LSP keymaps
local lsp = vim.lsp

map("n", "<leader>ca", lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cR", lsp.buf.rename, { desc = "Rename symbol" })
map("n", "gr", lsp.buf.references, { desc = "References" })
map("n", "gd", lsp.buf.definition, { desc = "Definition" })
map("n", "gD", lsp.buf.declaration, { desc = "Declaration" })
map("n", "gi", lsp.buf.implementation, { desc = "Implementation" })
map("n", "K", lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>ds", lsp.buf.document_symbol, { desc = "Document symbols" })
map("n", "<leader>ws", lsp.buf.workspace_symbol, { desc = "Workspace symbols" })
map("n", "<leader>zz", function()
	require("zen-mode").toggle()
end, { desc = "Zen mode" })

vim.api.nvim_create_user_command("Sr", function(info)
	local args = vim.split(info.args, "%s+")
	vim.cmd("%s#" .. args[1] .. "#" .. args[2] .. "#gc")
end, { nargs = "+" })

-- ── Quickshell Doxygen ──────────────────────────────────────────────────────
-- <leader>od ("open doc"): rebuild the project doc in background and, once the
-- build finishes, open the HTML page corresponding to the current .qml file
-- in the system browser. Only relevant inside /etc/nixos/quickshell/.
local quickshell_root = "/etc/nixos/quickshell"

local function qml_doc_path()
	local file = vim.fn.expand("%:p")
	if not vim.startswith(file, quickshell_root .. "/") then
		return nil, "not a Quickshell .qml file"
	end
	local rel = file:sub(#quickshell_root + 2)
	-- Sub-folder: services/CpuUsage.qml → classservices_1_1CpuUsage.html
	local ns, cls = rel:match("^([^/]+)/([^/]+)%.qml$")
	if ns and cls then
		return string.format("%s/doc/html/class%s_1_1%s.html", quickshell_root, ns, cls)
	end
	-- Root file: shell.qml → classshell.html
	local root = rel:match("^([^/]+)%.qml$")
	if root then
		return string.format("%s/doc/html/class%s.html", quickshell_root, root)
	end
	return nil, "could not derive HTML path from " .. rel
end

map("n", "<leader>od", function()
	local path, err = qml_doc_path()
	if not path then
		vim.notify("Doxygen: " .. err, vim.log.levels.WARN)
		return
	end
	vim.notify("Doxygen: regenerating...", vim.log.levels.INFO)
	vim.fn.jobstart({ "doxygen", "Doxyfile" }, {
		cwd = quickshell_root,
		on_exit = function(_, code)
			if code ~= 0 then
				vim.schedule(function()
					vim.notify("Doxygen: FAILED (exit " .. code .. ")", vim.log.levels.ERROR)
				end)
				return
			end
			vim.schedule(function()
				if vim.fn.filereadable(path) == 0 then
					vim.notify("Doxygen: doc built but page not found at " .. path, vim.log.levels.WARN)
					return
				end
				vim.fn.jobstart({ "xdg-open", path }, { detach = true })
				vim.notify("Doxygen: opened " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
			end)
		end,
	})
end, { desc = "Quickshell: regen Doxygen + open doc page for current .qml" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
