#!/usr/bin/env bash
# Sets per-output wallpapers via awww/swww and regenerates the
# Quickshell theme via matugen using the DP-2 (primary) image.
#
# Usage:
#   wallpaper.sh                        # uses default DP-2 + DP-1 wallpapers
#   wallpaper.sh <dp2>                  # custom DP-2, default DP-1
#   wallpaper.sh <dp2> <dp1>            # custom both

set -euo pipefail

DP2_WALL="${1:-/etc/nixos/wallpapers/dp2.jpg}"
DP1_WALL="${2:-/etc/nixos/wallpapers/dp1.jpg}"

for f in "$DP2_WALL" "$DP1_WALL"; do
    if [ ! -f "$f" ]; then
        echo "wallpaper not found: $f" >&2
        exit 1
    fi
done

# Per-output wallpapers with smooth transitions.
awww img --outputs DP-2 "$DP2_WALL" \
    --resize fit \
    --transition-type wipe \
    --transition-duration 1 \
    --transition-fps 60

awww img --outputs DP-1 "$DP1_WALL" \
    --resize fit \
    --transition-type fade \
    --transition-duration 1 \
    --transition-fps 60

# Regenerate the Quickshell theme based on the primary (DP-2) wallpaper.
# Quickshell's hot-reload picks up the rewritten Theme.qml automatically.
#
# matugen 4 forces an interactive colour picker on `image` mode and refuses
# to run without a TTY. We wrap it in `script` (allocates a pseudo-TTY) and
# feed it a single \r so it accepts the first/default option, which is
# matugen's own recommended dominant colour for the wallpaper. That gives
# a much better source colour than averaging the pixels ourselves.
printf '\r' | script -q -c "matugen image '$DP2_WALL'" /dev/null > /tmp/matugen.log 2>&1 || \
    notify-send "matugen" "failed: see /tmp/matugen.log" || true
