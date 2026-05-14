return {
	"nvim-mini/mini.ai",
	version = false,
	event = "VeryLazy",
	config = function()
		local ai = require("mini.ai")
		ai.setup({
			n_lines = 500,
			custom_textobjects = {
				f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
				c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
				a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
				o = ai.gen_spec.treesitter({ a = "@block.outer", i = "@block.inner" }),
			},
		})
	end,
}
