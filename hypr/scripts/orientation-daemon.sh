#!/usr/bin/env bash
# Adapte l'orientation du layout master selon le moniteur du workspace actif.
# DP-1 (portrait) → orientationtop  (master en haut, stack en bas)
# DP-2 (paysage)  → orientationleft (master à gauche, stack à droite)

set -euo pipefail

socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

apply_orientation() {
    local mon
    mon=$(hyprctl activeworkspace -j | jq -r '.monitor')
    if [[ "$mon" == "DP-1" ]]; then
        hyprctl dispatch layoutmsg orientationtop > /dev/null
    else
        hyprctl dispatch layoutmsg orientationleft > /dev/null
    fi
}

# Applique une première fois au démarrage
apply_orientation

# Écoute les events Hyprland — ré-applique au changement de workspace/moniteur
socat -u "UNIX-CONNECT:$socket" - | while read -r line; do
    case "$line" in
        "focusedmon>>"*|"workspace>>"*|"workspacev2>>"*)
            apply_orientation
            ;;
    esac
done
