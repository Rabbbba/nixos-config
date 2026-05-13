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

-- qmldir EXCLU intentionnellement de root_markers: chaque sous-dossier
-- (modules/, popouts/...) contient son propre qmldir, ce qui ferait que le
-- LSP considère le sous-dossier comme racine et n'indexerait pas les autres
-- dossiers du projet.
--
-- Choix LSP QML : qmlls (Qt officiel) — moteur qmllint sous-jacent, catche les
-- [unqualified] (identifier non résolu, ex: `windows: [ window ]` au lieu de
-- `windows: [ panelPopout ]`) que qml-language-server (Go/tree-sitter) rate.
-- Options projet (no-cmake-calls) dans quickshell/.qmlls.ini.
-- `-E` lit QML_IMPORT_PATH (set dans home.nix) pour les modules Quickshell + Qt.

vim.lsp.config("qmlls", {
	cmd = { "qmlls", "-E" },
	filetypes = { "qml" },
	root_markers = { "shell.qml", ".qmlls.ini", ".git" },
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("qmlls")

-- Alternative gardée en commentaire : qml-language-server (Go/tree-sitter).
-- Plus permissif (ne flag pas les unqualified) — à réactiver si qmlls devient
-- trop bruyant ou si ses faux positifs gênent.
-- vim.lsp.config("qml-language-server", {
-- 	cmd = { "qml-language-server" },
-- 	filetypes = { "qml" },
-- 	root_markers = { "shell.qml", ".git" },
-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
-- vim.lsp.enable("qml-language-server")
