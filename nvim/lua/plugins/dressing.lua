-- dressing.nvim wraps vim.ui.select and vim.ui.input with a real popup
-- (replaces the default vim.fn.confirm / vim.fn.inputlist prompts).
-- Improves LSP code_action, rename, and any plugin using vim.ui.*.
return {
	"stevearc/dressing.nvim",
	event = "VeryLazy",
	opts = {},
}
