require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("clangd", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	cmd = {
		"clangd",
		"--background-index", -- indexation projet en arrière-plan (defs cross-file)
		"--clang-tidy", -- intègre clang-tidy dans les diagnostics LSP
		"--header-insertion=iwyu", -- propose les #include manquants (style include-what-you-use)
		"--completion-style=detailed", -- complétion plus riche (overloads séparés, params nommés)
		"--function-arg-placeholders", -- snippets <args> à la complétion
		"--all-scopes-completion", -- complète aussi les symboles hors namespace courant
	},
	-- Cherche compile_commands.json à la racine projet ; sinon clangd
	-- fonctionne sur fichier unique en best-effort. Pour les projets
	-- multi-fichiers hors CMake, utiliser `bear -- ./tools/compile.sh -c f.cpp`.
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
