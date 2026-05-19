-- aerial.nvim: code outline (functions, classes, methods) in a side panel.
-- Falls back across LSP → treesitter → markdown depending on what's available.
return {
	"stevearc/aerial.nvim",
	cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
	opts = {
		backends = { "lsp", "treesitter", "markdown" },
		layout = {
			default_direction = "right",
			min_width = 30,
		},
		attach_mode = "global",
		show_guides = true,
		filter_kind = false, -- show all symbol kinds, not just classes/funcs
	},
	keys = {
		{ "<leader>O", "<cmd>AerialToggle<cr>", desc = "Aerial: outline toggle" },
		{ "<leader>oa", "<cmd>AerialNavToggle<cr>", desc = "Aerial: floating nav" },
	},
}
