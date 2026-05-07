#!/usr/bin/env bash
# Sets per-output wallpapers via awww/swww and regenerates the
# Quickshell theme via matugen using the OLED (primary) image.
#
# Usage:
#   wallpaper.sh                        # uses default OLED + portrait wallpapers
#   wallpaper.sh <oled>                 # custom OLED, default portrait
#   wallpaper.sh <oled> <portrait>      # custom both
#
# Détecte dynamiquement les noms DP-X via le model EDID — robuste cross-boot
# même si Linux/Hyprland renomment les outputs.

set -euo pipefail

OLED_WALL="${1:-/etc/nixos/wallpapers/dp2.jpg}"
PORTRAIT_WALL="${2:-/etc/nixos/wallpapers/dp1.jpg}"

for f in "$OLED_WALL" "$PORTRAIT_WALL"; do
  if [ ! -f "$f" ]; then
    echo "wallpaper not found: $f" >&2
    exit 1
  fi
done

# Attendre que le daemon awww soit prêt
until hyprctl monitors -j >/dev/null 2>&1; do
  sleep 0.5
done

# Détection dynamique des outputs via leur model EDID
OLED_DP=$(hyprctl monitors -j | jq -r '.[] | select(.model == "AW3423DWF") | .name' | head -1)
PORTRAIT_DP=$(hyprctl monitors -j | jq -r '.[] | select(.model == "24G1WG4") | .name' | head -1)

# Per-output wallpapers with smooth transitions.
if [[ -n "$OLED_DP" ]]; then
  awww img --outputs "$OLED_DP" "$OLED_WALL" \
    --resize fit \
    --transition-type wipe \
    --transition-duration 1 \
    --transition-fps 60
else
  echo "OLED (AW3423DWF) introuvable — wallpaper ignoré" >&2
fi

if [[ -n "$PORTRAIT_DP" ]]; then
  awww img --outputs "$PORTRAIT_DP" "$PORTRAIT_WALL" \
    --resize fit \
    --transition-type fade \
    --transition-duration 1 \
    --transition-fps 60
else
  echo "Portrait (24G1WG4) introuvable — wallpaper ignoré" >&2
fi

# Regenerate the Quickshell theme based on the OLED (primary) wallpaper.
# Quickshell's hot-reload picks up the rewritten Theme.qml automatically.
#
# matugen 4 forces an interactive colour picker on `image` mode and refuses
# to run without a TTY. We wrap it in `script` (allocates a pseudo-TTY) and
# feed it a single \r so it accepts the first/default option, which is
# matugen's own recommended dominant colour for the wallpaper.
printf '\r' | script -q -c "matugen image '$OLED_WALL'" /dev/null >/tmp/matugen.log 2>&1 ||
  notify-send "matugen" "failed: see /tmp/matugen.log" || true
