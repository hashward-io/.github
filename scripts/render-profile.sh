#!/usr/bin/env bash
# Render profile/profile.html into profile/profile.png.
#
# The organisation profile is a single image, so profile/profile.html is the
# source of truth. This script is the only thing that produces the PNG.
# Run it after any change to the poster markup or the vendored design-system
# CSS, then commit the regenerated profile.png alongside the source change.
#
#   ./scripts/render-profile.sh
#
# Requirements: a Chrome/Chromium binary and network access for the webfonts.
# Override the browser with CHROME=/path/to/chrome.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/profile/profile.html"
OUT="$ROOT/profile/profile.png"
WIDTH=1200

CHROME="${CHROME:-}"
if [ -z "$CHROME" ]; then
  for candidate in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$candidate" > /dev/null 2>&1; then
      CHROME="$candidate"
      break
    fi
  done
fi
if [ -z "$CHROME" ]; then
  echo "no Chrome/Chromium found; set CHROME=/path/to/chrome" >&2
  exit 1
fi

URL="file://$SRC"

# Pass 1: the page writes its own rendered height into <title>, so the
# screenshot viewport can be sized to the content instead of guessing.
HEIGHT="$("$CHROME" \
  --headless=new --disable-gpu --hide-scrollbars --no-sandbox \
  --window-size="$WIDTH,1200" --virtual-time-budget=15000 --dump-dom "$URL" \
  | grep -o 'HW-H[0-9]\+' | head -1 | tr -dc '0-9')"

if [ -z "$HEIGHT" ]; then
  echo "could not measure the rendered height of $SRC" >&2
  exit 1
fi

# Pass 2: screenshot at exactly that height.
"$CHROME" \
  --headless=new --disable-gpu --hide-scrollbars --no-sandbox \
  --force-device-scale-factor=1 --screenshot="$OUT" \
  --window-size="$WIDTH,$HEIGHT" --virtual-time-budget=15000 "$URL"

echo "wrote $OUT (${WIDTH}x${HEIGHT})"
