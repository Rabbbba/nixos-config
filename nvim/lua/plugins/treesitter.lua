return {
	"nvim-treesitter/nvim-treesitter",
	opts = {
		ensure_installed = {
			"c",
			"cpp",
			"cmake",
			"qml",
			"hyprlang",
			"lua",
			"vim",
			"vimdoc",
			"html",
			"css",
		},
		highlight = {
			enable = true,
		},
	},
	init = function()
		require("nvim-treesitter.install").update({ with_git_exe = true })
	end,
	config = function(_, opts)
		require("nvim-treesitter").setup(opts)
	end,
}
