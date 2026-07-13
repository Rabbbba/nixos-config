return {
	"ray-x/lsp_signature.nvim",
	event = "LspAttach",
	opts = {
		floating_window = true,
		floating_window_above_cur_line = true, -- s'ouvre au-dessus de la ligne, pas dessus
		hint_enable = false, -- pas de hint virtuel inline
		handler_opts = {
			border = "rounded",
		},
	},
	config = function(_, opts)
		require("lsp_signature").setup(opts)
	end,
}
