#!/bin/bash
ENV_DIR="$HOME/.config/taenite/env"
ENV="$ENV_DIR/env"

# shellcheck disable=SC1090
. "$ENV"

if [ "${1:-}" != "--run" ]; then
  exec xterm -T "Launching Extranet" -geometry 90x12 -e bash "$0" --run
fi

temp="/tmp/extranet"
trap 'rm -rf "$temp"' EXIT INT TERM

echo "Starting Extranet..."
echo "Please wait while Chromium opens."
echo

rm -rf "$temp"
mkdir -p "$temp"
touch "$temp/First Run"

setsid chromium \
  --user-data-dir="$temp" \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized \
  --app="$EXTRANET" \
  </dev/null >/dev/null 2>&1 &

sleep 5
