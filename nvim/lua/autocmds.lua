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

-- ── Quickshell QML skeleton ─────────────────────────────────────────────────
-- When opening a new or empty .qml file inside /etc/nixos/quickshell/, insert
-- a starter template adapted to the parent folder (services = singleton,
-- popouts = anchored Item, modules = ModuleWrapper, components = Item,
-- root = generic Item). Cursor lands on the @brief line so the user can
-- start typing immediately.
--
-- Two events to cover both `nvim newfile.qml` (BufNewFile) AND nvim-tree's
-- "create file then open" flow (BufReadPost on an empty file). The empty
-- check guards against ever overwriting an existing file's content.
autocmd({ "BufNewFile", "BufReadPost" }, {
	pattern = "/etc/nixos/quickshell/**/*.qml",
	callback = function(ctx)
		-- Skip if buffer already has content (existing file).
		local existing = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
		if #existing > 1 or (#existing == 1 and existing[1] ~= "") then
			return
		end
		local file = vim.api.nvim_buf_get_name(ctx.buf)
		local rel = file:sub(#"/etc/nixos/quickshell/" + 1)
		local folder = rel:match("^([^/]+)/") or ""
		local class = rel:match("([^/]+)%.qml$") or "Component"

		local templates = {
			services = {
				"pragma Singleton",
				"import QtQuick",
				"",
				"/**",
				" * @brief TODO: short description.",
				" *",
				" * Detailed description.",
				" */",
				"QtObject {",
				"    id: root",
				"",
				"}",
			},
			popouts = {
				"import QtQuick",
				'import "../modules"',
				'import "../components"',
				"",
				"/**",
				" * @brief TODO: short description.",
				" *",
				" * Detailed description. Meant to be placed inside a @ref components::Popout.",
				" */",
				"Item {",
				"    id: root",
				"    anchors.fill: parent",
				"",
				"}",
			},
			modules = {
				"import QtQuick",
				'import "../services"',
				'import "../components"',
				'import "../popouts"',
				"",
				"/**",
				" * @brief TODO: short description.",
				" *",
				" * Detailed description.",
				" */",
				"ModuleWrapper {",
				"    id: root",
				"",
				"    bgIdle: Theme.moduleBg",
				"    bgHover: Theme.accent",
				"",
				"    StyledText {",
				'        text: ""',
				"        color: root.hovered ? Theme.popupBg : Theme.text",
				"        font.pixelSize: Theme.fontSizeLg",
				"    }",
				"}",
			},
			components = {
				"import QtQuick",
				'import "../modules"',
				"",
				"/**",
				" * @brief TODO: short description.",
				" *",
				" * Detailed description.",
				" */",
				"Item {",
				"    id: root",
				"",
				"}",
			},
		}

		local template = templates[folder] or {
			"import QtQuick",
			"",
			"/**",
			" * @brief TODO: short description.",
			" */",
			"Item {",
			"    id: root",
			"",
			"}",
		}

		vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, template)

		-- Place cursor on the @brief line, right after "TODO: " so user can type.
		for line_idx, line in ipairs(template) do
			local col = line:find("TODO: ")
			if col then
				vim.api.nvim_win_set_cursor(0, { line_idx, col + #"TODO: " - 1 })
				vim.cmd("startinsert")
				break
			end
		end

		-- Suppress the "@brief TODO" placeholder by selecting it for deletion as the
		-- user starts typing — this keeps the rest of the line ("short description.")
		-- which they can then edit. Actually, simpler: leave the placeholder, user
		-- edits in place. (No-op here.)
	end,
})
