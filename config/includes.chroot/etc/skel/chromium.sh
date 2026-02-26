#!/bin/bash

TEMP="/tmp/chromium"
trap 'rm -rf "$TEMP"' EXIT INT TERM

rm -rf "$TEMP"
mkdir -p "$TEMP"
touch "$TEMP/First Run"

exec chromium \
  --user-data-dir="$TEMP" \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized
