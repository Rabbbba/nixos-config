require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("clangd", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
		"--completion-style=bundled",
		"--function-arg-placeholders",
		"--all-scopes-completion",
		"--limit-results=20",
	},
	-- no compile_commands.json → single-file mode. For non-CMake projects:
	-- `bear -- ./tools/compile.sh -c f.cpp`
	root_markers = { "compile_commands.json", "CMakeLists.txt", ".git" },
})
vim.lsp.enable("clangd")

local servers = { "html", "cssls" }
vim.lsp.enable(servers)

vim.lsp.config("hyprlang", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("hyprlang")

vim.lsp.config("bashls", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("bashls")

vim.lsp.config("nixd", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("nixd")

-- qmldir is NOT in root_markers: every subfolder ships one, would split the
-- project. qmlls > qml-language-server here for [unqualified] diagnostics.
-- `-E` reads QML_IMPORT_PATH (home.nix). Project opts in quickshell/.qmlls.ini.
vim.lsp.config("qmlls", {
	cmd = { "qmlls", "-E" },
	filetypes = { "qml" },
	root_markers = { "shell.qml", ".qmlls.ini", ".git" },
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("qmlls")

-- Native inlay hints (Neovim 0.10+): enable per buffer when the attached
-- LSP advertises textDocument/inlayHint. clangd shows parameter names at
-- call sites and types deduced behind `auto`.
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})

-- Jdtls for Java
vim.lsp.config("jdtls", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("jdtls")

vim.keymap.set("n", "<leader>ih", function()
	local on = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not on, { bufnr = 0 })
end, { desc = "Toggle inlay hints (buffer)" })

-- fallback if qmlls gets too noisy: qml-language-server (Go/tree-sitter)
-- vim.lsp.config("qml-language-server", {
-- 	cmd = { "qml-language-server" },
-- 	filetypes = { "qml" },
-- 	root_markers = { "shell.qml", ".git" },
-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
-- vim.lsp.enable("qml-language-server")
