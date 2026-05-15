#!/usr/bin/env bash
# Sets per-output wallpapers via awww and regenerates the Quickshell theme
# from the OLED image. Outputs matched by EDID model — survives DP-X renames.
#
# Usage:
#   wallpaper.sh                       # defaults
#   wallpaper.sh <oled>                # custom OLED only
#   wallpaper.sh <oled> <portrait>     # both

set -euo pipefail

OLED_WALL="${1:-/etc/nixos/wallpapers/dp2.jpg}"
PORTRAIT_WALL="${2:-/etc/nixos/wallpapers/dp1.jpg}"

for f in "$OLED_WALL" "$PORTRAIT_WALL"; do
  if [ ! -f "$f" ]; then
    echo "wallpaper not found: $f" >&2
    exit 1
  fi
done

# wait for awww
until hyprctl monitors -j >/dev/null 2>&1; do
  sleep 0.5
done

OLED_DP=$(hyprctl monitors -j | jq -r '.[] | select(.model == "AW3423DWF") | .name' | head -1)
PORTRAIT_DP=$(hyprctl monitors -j | jq -r '.[] | select(.model == "24G1WG4") | .name' | head -1)

if [[ -n "$OLED_DP" ]]; then
  awww img --outputs "$OLED_DP" "$OLED_WALL" \
    --resize fit \
    --transition-type wipe \
    --transition-duration 1 \
    --transition-fps 60
else
  echo "OLED (AW3423DWF) not found — wallpaper skipped" >&2
fi

if [[ -n "$PORTRAIT_DP" ]]; then
  awww img --outputs "$PORTRAIT_DP" "$PORTRAIT_WALL" \
    --resize fit \
    --transition-type fade \
    --transition-duration 1 \
    --transition-fps 60
else
  echo "Portrait (24G1WG4) not found — wallpaper skipped" >&2
fi

# matugen 4 forces an interactive picker on `image` mode and refuses without a
# TTY. Wrap in `script` for a pty and feed \r to accept the default colour.
# Quickshell hot-reloads the rewritten Theme.qml.
printf '\r' | script -q -c "matugen image '$OLED_WALL'" /dev/null >/tmp/matugen.log 2>&1 ||
  notify-send "matugen" "failed: see /tmp/matugen.log" || true
