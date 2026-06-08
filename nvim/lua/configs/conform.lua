local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		cpp = { "clang-format" },
		c = { "clang-format" },
		json = { "prettier" },
		jsonc = { "prettier" },
		css = { "prettier" },
		toml = { "taplo" },
		sh = { "shfmt" },
		fish = { "fish_indent" },
		md = { "prettier" },
		nix = { "nixd" },
		qml = { "qmlformat" },
		java = { "google-java-format" },
	},

	format_on_save = {
		timeout_ms = 500,
	},
	lsp_fallback = true,
}

return options
