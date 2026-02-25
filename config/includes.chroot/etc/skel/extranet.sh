#!/bin/bash

if [ "${1:-}" != "--run" ]; then
  exec xterm -T "Launching Extranet" -geometry 90x12 -e bash "$0" --run
fi

app_env_file="$HOME/.config/taenite/env"
tmpdir="/tmp/extranet"
# shellcheck disable=SC1090
. "$app_env_file"
targetURL="$EXTRANET"
trap 'rm -rf "$tmpdir"' EXIT INT TERM

echo "Starting Extranet..."
echo "Please wait while Chromium opens."
echo

rm -rf "$tmpdir"
mkdir -p "$tmpdir"
touch "$tmpdir/First Run"

setsid chromium \
  --user-data-dir="$tmpdir" \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized \
  --app="$targetURL" \
  </dev/null >/dev/null 2>&1 &

sleep 5
