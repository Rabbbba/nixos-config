#!/usr/bin/env bash
# Reload full kb_layout to emit a fresh wl_keyboard.keymap — games that cache
# the initial keymap ignore plain group switches.

set -eu

CUR=$(hyprctl getoption input:kb_layout -j | grep -oE '"str": ?"[^"]*"' | head -1 | cut -d'"' -f4)

# swap the two pairs below to use different layouts
case "$CUR" in
    "fr,us") NEW="us,fr" ;;
    "us,fr") NEW="fr,us" ;;
    *) NEW="fr,us" ;;
esac

# `hyprctl keyword` is rejected under a Lua config ("Use eval."), so apply the
# change through the Lua config API via `eval`; fall back to legacy keyword when
# running under a .conf config (eval has no Lua parser there).
hyprctl eval "hl.config({ input = { kb_layout = \"$NEW\" } })" 2>/dev/null | grep -qx ok \
    || hyprctl keyword input:kb_layout "$NEW"
