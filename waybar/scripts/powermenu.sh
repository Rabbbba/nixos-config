#!/bin/bash
# =============================================================================
# powermenu.sh — Menu d'alimentation via Rofi
# Utilisé par Waybar ou déclenché directement
# Thème : ~/.config/rofi/powermenu.rasi
# Note : wlogout (Super+Shift+M) est préféré pour l'usage quotidien
# =============================================================================

LOCK="󰌾  Verrouiller"
LOGOUT="󰍃  Déconnexion"
REBOOT="󰑓  Redémarrer"
SHUTDOWN="󰐥  Éteindre"

# Affiche le menu rofi et récupère le choix
CHOICE=$(printf "%s\n%s\n%s\n%s" "$LOCK" "$LOGOUT" "$REBOOT" "$SHUTDOWN" |
  rofi -dmenu \
    -p "  $USER" \
    -theme "$HOME/.config/rofi/powermenu.rasi")

# Exécute l'action correspondante
case "$CHOICE" in
"$LOCK") loginctl lock-session ;;
"$LOGOUT") hyprctl dispatch exit ;;
"$REBOOT") systemctl reboot ;;
"$SHUTDOWN") systemctl poweroff ;;
esac
