require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("clangd", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
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

-- Pour revert au LSP officiel Qt, dé-commenter ce bloc et commenter le suivant:
-- vim.lsp.config("qmlls", {
-- 	cmd = { "qmlls", "-E" },
-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
-- vim.lsp.enable("qmlls")

vim.lsp.config("qml-language-server", {
	cmd = { "qml-language-server" },
	filetypes = { "qml" },
	root_markers = { "qmldir", "shell.qml", ".git" },
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("qml-language-server")
