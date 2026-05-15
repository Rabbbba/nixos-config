require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("clangd", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--all-scopes-completion",
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

-- fallback if qmlls gets too noisy: qml-language-server (Go/tree-sitter)
-- vim.lsp.config("qml-language-server", {
-- 	cmd = { "qml-language-server" },
-- 	filetypes = { "qml" },
-- 	root_markers = { "shell.qml", ".git" },
-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
-- vim.lsp.enable("qml-language-server")
