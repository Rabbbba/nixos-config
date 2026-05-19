-- trouble.nvim: structured UI for quickfix, diagnostics, LSP refs, symbols.
-- Capital `T` prefix to avoid NvChad's <leader>x (buffer close).
return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opts = {},
	keys = {
		{ "<leader>Td", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: diagnostics (workspace)" },
		{ "<leader>Tb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: diagnostics (buffer)" },
		{ "<leader>Tq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: quickfix list" },
		{ "<leader>Tl", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: location list" },
		{ "<leader>Ts", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble: symbols" },
		{
			"<leader>Tr",
			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
			desc = "Trouble: LSP refs/defs",
		},
	},
}
