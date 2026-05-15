#!/usr/bin/env bash
# Master orientation follows the active workspace's monitor.
# transform 1/3 (portrait) → orientationtop, else orientationleft.

set -euo pipefail

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

apply_orientation() {
    local mon transform
    mon=$(hyprctl activeworkspace -j | jq -r '.monitor')
    transform=$(hyprctl monitors -j | jq -r --arg m "$mon" '.[] | select(.name==$m) | .transform')
    if [[ "$transform" == "1" || "$transform" == "3" ]]; then
        hyprctl dispatch layoutmsg orientationtop > /dev/null
    else
        hyprctl dispatch layoutmsg orientationleft > /dev/null
    fi
}

apply_orientation

# re-apply on workspace/monitor change
socat -u "UNIX-CONNECT:$socket" - | while read -r line; do
    case "$line" in
        "focusedmon>>"*|"workspace>>"*|"workspacev2>>"*)
            apply_orientation
            ;;
    esac
done
