-- clangd_extensions.nvim: off-spec clangd features (AST view, memory usage,
-- symbol info). Inlay hints disabled here — native Neovim 0.10+ inlay hints
-- are wired up in configs/lspconfig.lua and supersede the plugin's version.
-- Note: github repo is archived; the source code still works. Upstream maintenance
-- has moved to sr.ht/~chinmay/clangd_extensions.nvim if a fork is ever needed.
return {
	"p00f/clangd_extensions.nvim",
	ft = { "c", "cpp" },
	opts = {
		inlay_hints = { inline = false }, -- defer to native vim.lsp.inlay_hint
		ast = {
			role_icons = {
				type = "T",
				declaration = "D",
				expression = "E",
				statement = ";",
				specifier = "S",
				["template argument"] = "A",
			},
			kind_icons = {
				Compound = "C",
				Recovery = "R",
				TranslationUnit = "U",
				PackExpansion = "P",
				TemplateTypeParm = "T",
				TemplateTemplateParm = "T",
				TemplateParamObject = "T",
			},
		},
	},
	keys = {
		{ "<leader>cA", "<cmd>ClangdAST<cr>", desc = "Clangd: AST view" },
		{ "<leader>cS", "<cmd>ClangdSymbolInfo<cr>", desc = "Clangd: symbol info" },
		{ "<leader>cH", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Clangd: switch header/source" },
	},
}
