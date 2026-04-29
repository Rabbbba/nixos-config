#!/bin/bash
# =============================================================================
# weather.sh — Météo via wttr.in
# Sortie JSON : { text: "icône temp°C", tooltip: "description détaillée" }
# Utilisé par le module custom/weather de Waybar (interval: 1800s = 30 min)
# Variable d'env WEATHER_LOCATION : laisser vide pour auto-détection par IP
# =============================================================================

LOCATION="${WEATHER_LOCATION:-}" # Vide = auto-détection basée sur l'IP

# Récupère les données météo en JSON depuis wttr.in
DATA=$(curl -sf "https://wttr.in/${LOCATION}?format=j1" 2>/dev/null)

# En cas d'échec réseau, affiche une valeur par défaut
if [ -z "$DATA" ]; then
  echo '{"text": "󰖑 N/A", "tooltip": "Météo indisponible"}'
  exit 0
fi

# Extraction des champs via Python (plus robuste que jq pour les nested objets)
TEMP=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['temp_C'])" 2>/dev/null)
DESC=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['weatherDesc'][0]['value'])" 2>/dev/null)
FEELS=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['FeelsLikeC'])" 2>/dev/null)
HUMIDITY=$(echo "$DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['current_condition'][0]['humidity'])" 2>/dev/null)

# Sélection de l'icône Nerd Font selon la description anglaise de wttr.in
case "$DESC" in
*Sunny* | *Clear*) ICON="󰖙" ;;
*Cloudy* | *Overcast*) ICON="󰖐" ;;
*Partly*) ICON="󰖕" ;;
*Rain* | *Drizzle*) ICON="󰖗" ;;
*Snow*) ICON="󰖘" ;;
*Thunder* | *Storm*) ICON="󰖓" ;;
*Fog* | *Mist*) ICON="󰖑" ;;
*) ICON="󰖑" ;; # Fallback générique
esac

TEXT="$ICON ${TEMP}°C"
TOOLTIP="$DESC\nRessenti : ${FEELS}°C\nHumidité : ${HUMIDITY}%"

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"
