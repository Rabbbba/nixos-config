#!/usr/bin/env bash
# Cycle next/prev wallpaper in $WALLPAPER_LIB and apply via wallpaper.sh.
# Usage: wallpaper-cycle.sh [next|prev]

set -euo pipefail

LIB_DIR="${WALLPAPER_LIB:-$HOME/Pictures/Wallpapers}"
STATE_FILE="$HOME/.cache/hypr-wallpaper-index"
DIRECTION="${1:-next}"

mkdir -p "$(dirname "$STATE_FILE")"

mapfile -t WALLS < <(find "$LIB_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | sort)

if [ "${#WALLS[@]}" -eq 0 ]; then
    notify-send "Wallpaper" "No images in $LIB_DIR" || true
    exit 1
fi

CUR=0
if [ -f "$STATE_FILE" ]; then
    CUR="$(cat "$STATE_FILE")"
fi

COUNT="${#WALLS[@]}"
case "$DIRECTION" in
    next) NEXT=$(( (CUR + 1) % COUNT )) ;;
    prev) NEXT=$(( (CUR - 1 + COUNT) % COUNT )) ;;
    *)
        echo "usage: $(basename "$0") [next|prev]" >&2
        exit 1
        ;;
esac

echo "$NEXT" > "$STATE_FILE"

WALL="${WALLS[$NEXT]}"
/etc/nixos/hypr/scripts/wallpaper.sh "$WALL"
notify-send "Wallpaper" "$(basename "$WALL")" || true
