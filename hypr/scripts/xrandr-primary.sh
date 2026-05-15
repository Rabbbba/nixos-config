#!/usr/bin/env bash
# Pin OLED as X primary so Steam toasts land there. EDID model is stable
# across boots, DP-X is not.

set -euo pipefail

oled=$(hyprctl monitors -j | jq -r '.[] | select(.model == "AW3423DWF") | .name' | head -1)

if [[ -n "$oled" ]]; then
    xrandr --output "$oled" --primary
else
    echo "OLED (AW3423DWF) not found — xrandr primary skipped" >&2
    exit 1
fi
