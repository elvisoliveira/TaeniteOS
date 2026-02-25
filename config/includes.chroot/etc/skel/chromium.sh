#!/bin/bash

tmpdir="/tmp/chromium"
trap 'rm -rf "$tmpdir"' EXIT INT TERM

rm -rf "$tmpdir"
mkdir -p "$tmpdir"
touch "$tmpdir/First Run"

exec chromium \
  --user-data-dir="$tmpdir" \
  --password-store=basic \
  --disable-print-preview \
  --start-maximized
