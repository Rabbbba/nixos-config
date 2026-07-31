#!/usr/bin/env bash
# Pin OLED as X primary so Steam toasts land there. EDID model is stable
# across boots, DP-X is not.
#
# Runs as xrandr-primary.service, ordered after graphical-session.target:
# hyprctl needs HYPRLAND_INSTANCE_SIGNATURE, which UWSM only exports once the
# session is up. Poll anyway — Xwayland may still be coming up on DISPLAY when
# the target is reached, and a slow start must not be fatal.

set -euo pipefail

for _ in $(seq 1 50); do
    hyprctl monitors -j >/dev/null 2>&1 && break
    sleep 0.2
done

oled=$(hyprctl monitors -j | jq -r '.[] | select(.model == "AW3423DWF") | .name' | head -1)

if [[ -z "$oled" ]]; then
    echo "OLED (AW3423DWF) not found — xrandr primary skipped" >&2
    exit 1
fi

for _ in $(seq 1 50); do
    xrandr --output "$oled" --primary 2>/dev/null && exit 0
    sleep 0.2
done

echo "xrandr could not reach Xwayland on DISPLAY=${DISPLAY:-<unset>}" >&2
exit 1
