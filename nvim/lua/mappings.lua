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

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
