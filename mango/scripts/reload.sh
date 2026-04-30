#!/usr/bin/env bash
# Reload complet : redémarre les programmes externes + recharge mango

pkill waybar
waybar &

# Recharge mango via SIGUSR1 (équivalent à reload_config)
pkill -SIGUSR1 mango
