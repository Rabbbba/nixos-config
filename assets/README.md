# assets/

Visual material referenced from the root `README.md`.

## How to (re-)capture the bar screenshot

Static screenshot of the full bar:

```bash
# Hide the cursor and grab the top 40 px of the OLED (Dell QD-OLED, monitor 0).
grim -g "1080,0 3440x40" -t png assets/bar.png
```

For a richer hero image showing a popout open (e.g. Tidal):

```bash
# Open the Tidal popout first, then capture a wider region:
grim -g "1080,0 3440x340" -t png assets/bar-tidal.png
```

## How to record a GIF/WebP of the live bar

Animated capture is more compelling than static for showing the cava
equalizer, popout transitions, and hover effects.

```bash
# 10-second record at 30 fps of the full top region:
wf-recorder -g "1080,0 3440x340" -f /tmp/bar.mp4 -F fps=30 -c libx264 \
  --duration 10

# Convert to optimized WebP (smaller than GIF, well-supported on GitHub):
ffmpeg -i /tmp/bar.mp4 -vcodec libwebp -lossless 0 -compression_level 6 \
  -q:v 60 -loop 0 -preset picture -an -vsync 0 \
  -vf "fps=15,scale=1720:-1:flags=lanczos" assets/bar.webp
```

Aim for < 2 MB. GitHub renders WebP and GIF inline in markdown.
