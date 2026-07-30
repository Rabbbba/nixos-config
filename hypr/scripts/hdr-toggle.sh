#!/usr/bin/env bash
# Toggles HDR on the OLED. The desktop is kept SDR by default so screen capture
# works; flip to HDR before launching an HDR game, flip back after. Bound to
# Super+Shift+H (bindp, so it fires even while a Proton game holds focus).
# State is read live from hyprctl (colorManagementPreset: srgb = SDR, hdredid = HDR),
# so it stays correct across reloads — no external state file to drift.

MON="desc:Dell Inc. AW3423DWF 5LKG2S3"
BASE="3440x1440@164.9, 1080x0, 1, bitdepth, 10"
HDR="$BASE, cm, hdredid, sdrbrightness, 1.4, sdrsaturation, 1.0"

# Lua config API equivalents of the two monitor lines above, for `hyprctl eval`
# under a Lua config (`hyprctl keyword` is rejected there: "Use eval.").
# cm = "srgb" is required going HDR→SDR: unlike legacy `keyword`, eval'ing
# hl.monitor without a cm key leaves the previous color-management preset
# (hdredid) in place, so HDR never turns back off. Force it back to SDR.
BASE_LUA='hl.monitor({ output = "'"$MON"'", mode = "3440x1440@164.9", position = "1080x0", scale = "1", bitdepth = 10, cm = "srgb" })'
HDR_LUA='hl.monitor({ output = "'"$MON"'", mode = "3440x1440@164.9", position = "1080x0", scale = "1", bitdepth = 10, cm = "hdredid", sdrbrightness = 1.4, sdrsaturation = 1.0 })'

# hyprctl dispatch that works under both the Lua config (0.55+) and the legacy
# .conf: legacy dispatch syntax is rejected under a Lua config, so try the Lua
# IPC form first and fall back to the legacy args when it isn't recognised.
hdispatch() {
  local lua="$1"; shift
  local out
  out=$(hyprctl dispatch "$lua" 2>/dev/null) || true
  [ "$out" = "ok" ] || hyprctl dispatch "$@" >/dev/null
}

# Set the OLED mode. Under a Lua config, `keyword` is rejected, so eval the Lua
# hl.monitor(...) form; fall back to legacy `keyword monitor` under a .conf config.
set_monitor() {
  # $1 = lua hl.monitor(...) expr ; $2 = legacy params (appended after "$MON, ")
  hyprctl eval "$1" 2>/dev/null | grep -qx ok || hyprctl keyword monitor "$MON, $2"
}

# A hot color-management change doesn't fully reset Hyprland's render pipeline:
# SDR content shows a washed-out white veil in HDR. A dpms off/on cycle forces a
# full modeset (like a cold boot), which clears it.
refresh() {
  hdispatch "hl.dsp.dpms({ action = \"off\", monitor = \"$MON\" })" dpms off "$MON"
  sleep 1
  hdispatch "hl.dsp.dpms({ action = \"on\", monitor = \"$MON\" })" dpms on "$MON"
}

preset=$(hyprctl monitors -j | jq -r '.[] | select(.model=="AW3423DWF") | .colorManagementPreset')

# Send the notification *before* refresh(): dpms off/on cycles the primary
# monitor for ~1s, and a notify-send fired right after often lands while the
# compositor is mid-reset and gets dropped. Pre-firing + a longer timeout lets
# the toast survive the cycle and be visible once the OLED comes back.
if [ "$preset" = "hdredid" ]; then
  notify-send -t 5000 -a Display -i display-brightness-symbolic "HDR off" "Desktop back to SDR"
  set_monitor "$BASE_LUA" "$BASE"
  refresh
else
  notify-send -t 5000 -a Display -i display-brightness-symbolic "HDR on" "OLED in HDR mode"
  set_monitor "$HDR_LUA" "$HDR"
  refresh
fi
