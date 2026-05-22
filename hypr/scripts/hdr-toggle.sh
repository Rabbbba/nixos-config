#!/usr/bin/env bash
# Toggles HDR on the OLED. The desktop is kept SDR by default so screen capture
# works; flip to HDR before launching an HDR game, flip back after. Bound to
# Super+Shift+H (bindp, so it fires even while a Proton game holds focus).
# State is read live from hyprctl (colorManagementPreset: srgb = SDR, hdredid = HDR),
# so it stays correct across reloads — no external state file to drift.

MON="desc:Dell Inc. AW3423DWF 5LKG2S3"
BASE="3440x1440@164.9, 1080x0, 1, bitdepth, 10"
HDR="$BASE, cm, hdredid, sdrbrightness, 1.4, sdrsaturation, 1.0"

# A hot color-management change doesn't fully reset Hyprland's render pipeline:
# SDR content shows a washed-out white veil in HDR. A dpms off/on cycle forces a
# full modeset (like a cold boot), which clears it.
refresh() {
  hyprctl dispatch dpms off "$MON" >/dev/null
  sleep 1
  hyprctl dispatch dpms on "$MON" >/dev/null
}

preset=$(hyprctl monitors -j | jq -r '.[] | select(.model=="AW3423DWF") | .colorManagementPreset')

if [ "$preset" = "hdredid" ]; then
  hyprctl keyword monitor "$MON, $BASE"
  refresh
  notify-send -t 2000 -a Display "HDR off" "Desktop back to SDR"
else
  hyprctl keyword monitor "$MON, $HDR"
  refresh
  notify-send -t 2000 -a Display "HDR on" "OLED in HDR mode"
fi
