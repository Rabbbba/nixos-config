#!/usr/bin/env bash
# Reload full kb_layout to emit a fresh wl_keyboard.keymap — games that cache
# the initial keymap ignore plain group switches.

set -eu

CUR=$(hyprctl getoption input:kb_layout -j | grep -oE '"str": ?"[^"]*"' | head -1 | cut -d'"' -f4)

case "$CUR" in
    "fr,us") NEW="us,fr" ;;
    "us,fr") NEW="fr,us" ;;
    *) NEW="fr,us" ;;
esac

hyprctl keyword input:kb_layout "$NEW"
