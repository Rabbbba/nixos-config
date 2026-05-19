-- cmake-tools.nvim: comprehensive CMake workflow inside Neovim.
-- :CMakeGenerate, :CMakeBuild, :CMakeRun, :CMakeDebug, target picker, etc.
-- Coexists with the simple :make wired up in configs/cpp.lua — use whichever fits.
return {
	"Civitasv/cmake-tools.nvim",
	ft = { "c", "cpp", "cmake" },
	cmd = {
		"CMakeGenerate",
		"CMakeBuild",
		"CMakeRun",
		"CMakeDebug",
		"CMakeSelectBuildTarget",
		"CMakeSelectLaunchTarget",
		"CMakeSettings",
	},
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		cmake_command = "cmake",
		cmake_build_directory = "build",
		cmake_generate_options = { "-G", "Ninja" },
		cmake_soft_link_compile_commands = true, -- keep compile_commands.json symlinked at root
		cmake_executor = { name = "quickfix" }, -- build output → quickfix list
		cmake_runner = { name = "terminal" }, -- run target in a terminal split
		cmake_notifications = { runner = { enabled = true }, executor = { enabled = true } },
	},
	keys = {
		{ "<leader>cm", "<cmd>CMakeGenerate<cr>", desc = "CMake: generate" },
		{ "<leader>cB", "<cmd>CMakeBuild<cr>", desc = "CMake: build (all)" },
		{ "<leader>cT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: select build target" },
		{ "<leader>cL", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake: select launch target" },
		{ "<leader>cD", "<cmd>CMakeDebug<cr>", desc = "CMake: debug (via DAP)" },
	},
}
