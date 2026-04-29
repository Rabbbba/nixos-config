#!/usr/bin/env bash
# =============================================================================
# toggle-media-popup.sh — Toggle du popup média EWW
# Ouvre ou ferme la fenêtre "media-player" selon son état actuel
# Note : EWW doit être configuré séparément pour ce widget
# =============================================================================

if eww active-windows | grep -q "media-player"; then
  eww close media-player
else
  eww open media-player
fi
