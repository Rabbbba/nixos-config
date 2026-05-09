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
-- Note: aucun LSP QML actuel ne fait fonctionner go-to-definition correctement
-- sur ce projet. qmlls a besoin d'un buildDir CMake (qu'on n'a pas car QML pur),
-- qml-language-server ne suit pas les imports relatifs `import "../foo"`.
-- On accepte la limitation: hover (K) et autocomplete fonctionnent, c'est l'essentiel.

vim.lsp.config("qml-language-server", {
	cmd = { "qml-language-server" },
	filetypes = { "qml" },
	root_markers = { "shell.qml", ".git" },
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
vim.lsp.enable("qml-language-server")

-- Alternative: qmlls (Qt officiel). À activer si on a un jour un buildDir CMake valide.
-- vim.lsp.config("qmlls", {
-- 	cmd = { "qmlls", "-E" },
-- 	filetypes = { "qml" },
-- 	root_markers = { "shell.qml", ".git" },
-- 	capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
-- vim.lsp.enable("qmlls")
