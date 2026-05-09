#!/usr/bin/env bash
# Wrapper appelé par Doxygen via FILTER_PATTERNS sur chaque .qml.
# Stderr est jeté pour cacher les SyntaxWarning Python 3.14 inoffensifs.
exec uvx --quiet doxyqml "$1" 2>/dev/null
