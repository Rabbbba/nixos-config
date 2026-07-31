#!/usr/bin/env bash
# Master orientation follows the active workspace's monitor.
# transform 1/3 (portrait) → orientationtop, else orientationleft.

set -euo pipefail

# hyprctl dispatch that works under both the Lua config (0.55+) and the legacy
# .conf: legacy dispatch syntax is rejected under a Lua config, so try the Lua
# IPC form first and fall back to the legacy args when it isn't recognised.
# Never fatal: a single missed dispatch must not kill the daemon under `set -e`.
hdispatch() {
    local lua="$1"; shift
    local out
    out=$(hyprctl dispatch "$lua" 2>/dev/null) || true
    [ "$out" = "ok" ] && return 0
    hyprctl dispatch "$@" >/dev/null 2>&1 && return 0
    echo "orientation dispatch failed: $lua" >&2
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

# HYPRLAND_INSTANCE_SIGNATURE is exported by UWSM only once the session is up
# (systemctl --user show-environment → UWSM_WAIT_VARNAMES). A bare expansion
# under `set -u` aborts on line 1 of the wait, which is exactly how this daemon
# died silently when it was an exec-once: hl.on("hyprland.start") fires before
# UWSM finalises the variable. Default to empty and let the loop wait for it.
socket=""
for _ in $(seq 1 100); do
    his="${HYPRLAND_INSTANCE_SIGNATURE:-}"
    candidate="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/$his/.socket2.sock"
    if [[ -n "$his" && -S "$candidate" ]] && hyprctl monitors -j >/dev/null 2>&1; then
        socket="$candidate"
        break
    fi
    sleep 0.2
done

if [[ -z "$socket" ]]; then
    echo "hyprland IPC not available after 20s — giving up" >&2
    exit 1
fi

apply_orientation

# re-apply on workspace/monitor change
socat -u "UNIX-CONNECT:$socket" - | while read -r line; do
    case "$line" in
        "focusedmon>>"*|"workspace>>"*|"workspacev2>>"*)
            apply_orientation
            ;;
    esac
done

# Reaching here means the event socket closed under us. Exit non-zero so the
# unit's Restart=on-failure reconnects; a clean exit would leave it stopped.
echo "hyprland event socket closed" >&2
exit 1
