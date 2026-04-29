#!/usr/bin/env bash
# =============================================================================
# media.sh — Affiche les infos du lecteur média en cours
# Sortie JSON : { text: "artiste - titre", tooltip: "<img>..." }
# Utilisé par le module custom/media de Waybar (interval: 2s)
# Préférence : tidal-hifi, fallback sur tout lecteur playerctl disponible
# =============================================================================

PLAYER="tidal-hifi"

get_info() {
  playerctl -p "$PLAYER" metadata --format '{{artist}}|{{title}}|{{mpris:artUrl}}' 2>/dev/null
}

info=$(get_info)

# Fallback sur n'importe quel lecteur actif si tidal-hifi n'est pas disponible
if [ -z "$info" ]; then
  info=$(playerctl metadata --format '{{artist}}|{{title}}|{{mpris:artUrl}}' 2>/dev/null)
fi

# Aucun lecteur actif — sortie vide (masque le module)
if [ -z "$info" ]; then
  echo '{"text": "", "tooltip": ""}'
  exit 0
fi

# Extraction des champs séparés par |
artist=$(echo "$info" | cut -d'|' -f1)
title=$(echo "$info" | cut -d'|' -f2)
art_url=$(echo "$info" | cut -d'|' -f3)

# Téléchargement de la pochette en cache temporaire
art_path="/tmp/waybar-media-art.jpg"
if [ -n "$art_url" ]; then
  curl -s -o "$art_path" "$art_url" 2>/dev/null
fi

# Texte affiché dans la barre (icône note + artiste - titre)
text=" $artist - $title"

# Tooltip : pochette + titre en gras + artiste
if [ -f "$art_path" ] && [ -n "$art_url" ]; then
  tooltip="<img src='$art_path' width='180' height='180'/>\n<b>$title</b>\n$artist"
else
  tooltip="<b>$title</b>\n$artist"
fi

# Échappement des guillemets pour JSON valide
printf '{"text": "%s", "tooltip": "%s"}\n' \
  "$(echo "$text" | sed 's/"/\\"/g')" \
  "$(echo "$tooltip" | sed 's/"/\\"/g')"
