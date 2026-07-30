#!/usr/bin/env bash
# Master orientation follows the active workspace's monitor.
# transform 1/3 (portrait) → orientationtop, else orientationleft.

set -euo pipefail

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# hyprctl dispatch that works under both the Lua config (0.55+) and the legacy
# .conf: legacy dispatch syntax is rejected under a Lua config, so try the Lua
# IPC form first and fall back to the legacy args when it isn't recognised.
hdispatch() {
    local lua="$1"; shift
    local out
    out=$(hyprctl dispatch "$lua" 2>/dev/null) || true
    [ "$out" = "ok" ] || hyprctl dispatch "$@" >/dev/null
}

apply_orientation() {
    local mon transform
    mon=$(hyprctl activeworkspace -j | jq -r '.monitor')
    transform=$(hyprctl monitors -j | jq -r --arg m "$mon" '.[] | select(.name==$m) | .transform')
    if [[ "$transform" == "1" || "$transform" == "3" ]]; then
        hdispatch 'hl.dsp.layout("orientationtop")' layoutmsg orientationtop > /dev/null
    else
        hdispatch 'hl.dsp.layout("orientationleft")' layoutmsg orientationleft > /dev/null
    fi
}

# Launched at hyprland.start (exec-once), the compositor/IPC may not be up yet.
# Wait for the event socket and a live hyprctl before proceeding, so a transient
# early failure doesn't kill the daemon under `set -euo pipefail`.
for _ in $(seq 1 100); do
    [[ -S "$socket" ]] && hyprctl monitors -j >/dev/null 2>&1 && break
    sleep 0.2
done

apply_orientation

# re-apply on workspace/monitor change
socat -u "UNIX-CONNECT:$socket" - | while read -r line; do
    case "$line" in
        "focusedmon>>"*|"workspace>>"*|"workspacev2>>"*)
            apply_orientation
            ;;
    esac
done
