#!/usr/bin/env bash
# =============================================================================
# get-art.sh — Télécharge la pochette d'album du lecteur actif
# Sortie : chemin vers /tmp/waybar-media-art.jpg, ou chaîne vide si indisponible
# Utilisé par : media.sh
# =============================================================================

# Récupère l'URL de la pochette — préfère tidal-hifi, fallback sur tout lecteur
art_url=$(playerctl -p tidal-hifi metadata mpris:artUrl 2>/dev/null ||
  playerctl metadata mpris:artUrl 2>/dev/null)

art_path="/tmp/waybar-media-art.jpg"

if [ -n "$art_url" ]; then
  curl -s -o "$art_path" "$art_url" 2>/dev/null
  echo "$art_path"
else
  echo "" # Aucune pochette disponible
fi
