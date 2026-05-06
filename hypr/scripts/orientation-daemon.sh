#!/usr/bin/env bash
# Adapte l'orientation du layout master selon l'orientation physique du moniteur
# du workspace actif (détectée via le `transform` Hyprland — 1/3 = rotated/portrait).
# Portrait → orientationtop  (master en haut, stack en bas)
# Paysage  → orientationleft (master à gauche, stack à droite)

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
