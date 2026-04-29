require("nvchad.autocmds")

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
	pattern = "*",
	callback = function(ctx)
		local buf_id = ctx.buf
		local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
		local changed = false

		for i, line in ipairs(lines) do
			if line ~= line:gsub("%s+$", "") then
				lines[i] = line:gsub("%s+$", "")
				changed = true
			end
		end

		if changed then
			vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
		end
	end,
})
