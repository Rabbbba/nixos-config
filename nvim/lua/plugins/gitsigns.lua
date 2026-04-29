return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = vim.keymap.set
				map("n", "<leader>gh", gs.next_hunk, { desc = "Next git hunk" })
				map("n", "<leader>gj", gs.prev_hunk, { desc = "Prev git hunk" })
				map("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
				map("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
				map("n", "<leader>gR", ":Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })
				map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
			end,
		})
	end,
}
