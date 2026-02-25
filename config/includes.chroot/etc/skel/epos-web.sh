#!/bin/bash

config_file="$HOME/machine-config.txt"
app_env_file="$HOME/.config/taenite/env"

if [ "${1:-}" != "--run" ]; then
  exec xterm -T "Launching EPOS Web" -geometry 90x12 -e bash "$0" --run
fi

if [ ! -f "$config_file" ]; then
  echo "Machine is not configured yet."
  echo "Run 'Configure Machine' first."
  echo
  read -r -p "Press Enter to close..."
  exit 1
fi

# shellcheck disable=SC1090
. "$config_file"
if [ -z "${SHOP_ID:-}" ] || [ -z "${TILL_ID:-}" ] || [ -z "${STATIC_IP_ADDRESS:-}" ] || [ -z "${NETWORK_PRINTER_IP_ADDRESS:-}" ]; then
  echo "Machine configuration is incomplete."
  echo "Run 'Configure Machine' again and fill all fields."
  echo
  read -r -p "Press Enter to close..."
  exit 1
fi

echo "Starting EPOS Web..."
echo "Please wait while Chromium opens."
echo

tmpdir="/tmp/eposnext"
# shellcheck disable=SC1090
. "$app_env_file"
targetURL="$EPOS"
trap 'rm -rf "$tmpdir"' EXIT INT TERM

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
