return {
	"nvim-pack/nvim-spectre",
	cmd = { "Spectre" },
	keys = {
		{
			"<leader>sg",
			function()
				require("spectre").open()
			end,
			desc = "Search and replace (project)",
		},
	},
}
