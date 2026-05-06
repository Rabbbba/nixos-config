#!/usr/bin/env bash
# Force l'OLED comme primary X — Steam place ses notif toasts sur le primary.
# Utilise le model EDID (AW3423DWF) pour être stable cross-boot, contrairement
# aux noms DP-X qui peuvent shifter selon l'ordre de détection des outputs.

set -euo pipefail

oled=$(hyprctl monitors -j | jq -r '.[] | select(.model == "AW3423DWF") | .name' | head -1)

if [[ -n "$oled" ]]; then
    xrandr --output "$oled" --primary
else
    echo "OLED (AW3423DWF) introuvable — xrandr primary ignoré" >&2
    exit 1
fi
