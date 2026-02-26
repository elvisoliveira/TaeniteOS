#!/bin/bash
ENV_DIR="$HOME/.config/taenite"

# shellcheck disable=SC1090
. "$ENV_DIR/env"

if [ "${1:-}" != "--run" ]; then
  exec xterm -T "Launching Extranet" -geometry 90x12 -e bash "$0" --run
fi

echo "Starting Extranet..."
echo "Please wait while Chromium opens."
echo

setsid chromium \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized \
  --app="$EXTRANET" \
  </dev/null >/dev/null 2>&1 &

sleep 5
