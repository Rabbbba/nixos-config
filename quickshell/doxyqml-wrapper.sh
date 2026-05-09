#!/usr/bin/env bash
# Wrapper appelé par Doxygen via FILTER_PATTERNS sur chaque .qml.
# Stderr est jeté pour cacher les SyntaxWarning Python 3.14 inoffensifs.
#
# Local (Rayane): uvx présent → utilise le cache uv (rapide).
# CI (Ubuntu)   : doxyqml installé directement via pip → fallback.
if command -v uvx >/dev/null 2>&1; then
    exec uvx --quiet doxyqml "$1" 2>/dev/null
else
    exec doxyqml "$1" 2>/dev/null
fi
