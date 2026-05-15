return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text", -- inline variables while stepping
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- gdb >= 14 ships a DAP server; codelldb has no standalone nixpkgs.
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "-i=dap" },
			}

			dap.configurations.cpp = {
				{
					name = "Launch executable",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Attach to PID",
					type = "gdb",
					request = "attach",
					pid = function()
						return tonumber(vim.fn.input("PID: "))
					end,
					cwd = "${workspaceFolder}",
				},
			}

			dap.configurations.c = vim.deepcopy(dap.configurations.cpp)

			-- ── UI auto open/close ───────────────────────────────────────
			dapui.setup()
			require("nvim-dap-virtual-text").setup({})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			-- ── VSCode-style keymaps ─────────────────────────────────────
			local map = vim.keymap.set
			map("n", "<F5>", function()
				dap.continue()
			end, { desc = "DAP continue / launch" })
			map("n", "<F10>", function()
				dap.step_over()
			end, { desc = "DAP step over" })
			map("n", "<F11>", function()
				dap.step_into()
			end, { desc = "DAP step into" })
			map("n", "<F12>", function()
				dap.step_out()
			end, { desc = "DAP step out" })
			map("n", "<leader>db", function()
				dap.toggle_breakpoint()
			end, { desc = "DAP toggle breakpoint" })
			map("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP conditional breakpoint" })
			map("n", "<leader>dr", function()
				dap.repl.open()
			end, { desc = "DAP open REPL" })
			map("n", "<leader>du", function()
				dapui.toggle()
			end, { desc = "DAP toggle UI" })
			map("n", "<leader>dt", function()
				dap.terminate()
			end, { desc = "DAP terminate" })
			map("n", "<leader>dk", function()
				require("dap.ui.widgets").hover()
			end, { desc = "DAP hover variable" })
		end,
	},
}
