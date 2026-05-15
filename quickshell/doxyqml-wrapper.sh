#!/usr/bin/env bash
# Doxygen FILTER_PATTERNS hook for .qml files.
# stderr dropped to hide harmless Py 3.14 SyntaxWarnings.
# uvx locally (uv cache) → pip-installed doxyqml on CI.
if command -v uvx >/dev/null 2>&1; then
    exec uvx --quiet doxyqml "$1" 2>/dev/null
else
    exec doxyqml "$1" 2>/dev/null
fi
