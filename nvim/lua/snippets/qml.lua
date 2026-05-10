-- Snippets QML pour le projet Quickshell.
-- Auto-loaded par luasnip via from_lua.load() dans plugins/cmp.lua.
-- Triggers (filetype = qml): tape le mot puis <Tab> en mode insert.

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
	-- prop : property publique avec doc.   Tab → type → name → default
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

	-- propr : readonly property avec doc.
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

	-- propa : property alias avec doc.
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

	-- sig : signal avec un paramètre typé.
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

	-- sig0 : signal sans paramètre.
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

	-- func : function typée (style QML moderne) avec doc.
	-- Le nom du paramètre est mirroré entre la doc et la signature.
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

	-- brief : juste un bloc Doxygen @brief (avant un type compound).
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
