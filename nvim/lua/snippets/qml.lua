-- QML snippets — loaded by luasnip via plugins/cmp.lua.
-- Trigger: type the keyword then <Tab> in insert mode.

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
	-- prop: public property + doc
	s(
		"prop",
		fmt(
			[[
/** {} */
property {} {}: {}
]],
			{
				i(1, "Description"),
				i(2, "color"),
				i(3, "name"),
				i(4, '""'),
			}
		)
	),

	-- propr: readonly property + doc
	s(
		"propr",
		fmt(
			[[
/** {} */
readonly property {} {}: {}
]],
			{
				i(1, "Description"),
				i(2, "color"),
				i(3, "name"),
				i(4, '""'),
			}
		)
	),

	-- propa: alias property + doc
	s(
		"propa",
		fmt(
			[[
/** {} */
property alias {}: {}
]],
			{
				i(1, "Description"),
				i(2, "name"),
				i(3, "target"),
			}
		)
	),

	-- sig: signal with one typed param
	s(
		"sig",
		fmt(
			[[
/** Emitted when {} */
signal {}({}: {})
]],
			{
				i(1, "..."),
				i(2, "name"),
				i(3, "arg"),
				i(4, "type"),
			}
		)
	),

	-- sig0: parameterless signal
	s(
		"sig0",
		fmt(
			[[
/** Emitted when {} */
signal {}
]],
			{
				i(1, "..."),
				i(2, "name"),
			}
		)
	),

	-- func: typed function + doc, param name mirrored between doc and signature
	s(
		"func",
		fmt(
			[[
/**
 * {desc}.
 * @param {arg} {arg_desc}
 */
function {name}({arg_sig}: {type}): {ret} {{
    {body}
}}
]],
			{
				desc = i(1, "Description"),
				arg = i(2, "p"),
				arg_desc = i(3, "..."),
				name = i(4, "name"),
				arg_sig = rep(2),
				type = i(5, "real"),
				ret = i(6, "void"),
				body = i(0),
			}
		)
	),

	-- brief: standalone @brief block before a compound type
	s(
		"brief",
		fmt(
			[[
/**
 * @brief {}.
 *
 * {}
 */
]],
			{
				i(1, "Short description"),
				i(2, "Detailed description."),
			}
		)
	),
}
