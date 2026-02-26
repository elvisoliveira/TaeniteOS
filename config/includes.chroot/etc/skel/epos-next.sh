#!/bin/bash
CONFIG="$HOME/machine-config.txt"
ENV_DIR="$HOME/.config/taenite"

# shellcheck disable=SC1090
. "$ENV_DIR/env"

if [ "${1:-}" != "--run" ]; then
  exec xterm -T "Launching EPOS Web" -geometry 90x12 -e bash "$0" --run
fi

if [ ! -f "$CONFIG" ]; then
  echo "Machine is not configured yet."
  echo "Run 'Configure Machine' first."
  echo
  read -r -p "Press Enter to close..."
  exit 1
fi

if [ -r "$CONFIG" ]; then
  . "$CONFIG"
fi

if [ -z "${SHOP_ID:-}" ] || 
   [ -z "${TILL_ID:-}" ] || 
   [ -z "${STATIC_IP_ADDRESS:-}" ]; then
  echo "Machine configuration is incomplete."
  echo "Run 'Configure Machine' again and fill all fields."
  echo
  read -r -p "Press Enter to close..."
  exit 1
fi

if ! app_url="$(
  python3 "$HOME/epos-next-settings-url.py" \
    "$ENV_DIR/epos-web-next.json" \
    "$NEXT" \
    "$SHOP_ID" \
    "$TILL_ID"
)"; then
  echo "Failed to build EPOS settings URL."
  echo
  read -r -p "Press Enter to close..."
  exit 1
fi

echo "Starting EPOS Web..."
echo "Please wait while Chromium opens."
echo

setsid chromium \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized \
  --app="$app_url" \
  </dev/null >/dev/null 2>&1 &

sleep 5
