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
