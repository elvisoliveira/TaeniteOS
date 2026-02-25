#!/bin/bash

set -u

CONFIG_FILE="$HOME/machine-config.txt"

is_valid_ipv4() {
  local ip="$1"
  local IFS=.
  local -a octets

  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  read -r -a octets <<< "$ip"
  [ "${#octets[@]}" -eq 4 ] || return 1

  for octet in "${octets[@]}"; do
    [ "$octet" -ge 0 ] 2>/dev/null || return 1
    [ "$octet" -le 255 ] 2>/dev/null || return 1
  done
}

ask_non_empty() {
  local prompt="$1"
  local value=""
  while :; do
    read -r -p "$prompt: " value
    if [ -n "$value" ]; then
      printf '%s\n' "$value"
      return 0
    fi
    echo "This field is required."
  done
}

ask_ipv4() {
  local prompt="$1"
  local value=""
  while :; do
    read -r -p "$prompt: " value
    if is_valid_ipv4 "$value"; then
      printf '%s\n' "$value"
      return 0
    fi
    echo "Please enter a valid IPv4 address (example: 192.168.1.10)."
  done
}

if [ "${1:-}" != "--prompt" ]; then
  exec xterm -T "Machine Configuration" -geometry 90x20 -e bash "$0" --prompt
fi

echo "Machine Configuration"
echo "====================="
echo "Authentication required to configure this machine."

if ! sudo -v; then
  echo
  echo "Authentication failed. Configuration aborted."
  echo
  read -r -p "Press Enter to close..."
  exit 1
fi
echo

shop_id="$(ask_non_empty "Shop ID (Acronym)")"
till_id="$(ask_non_empty "Till ID")"
static_ip="$(ask_ipv4 "Static IP Address")"
printer_ip="$(ask_ipv4 "Network Printer IP Address")"

umask 077
cat > "$CONFIG_FILE" <<EOF
SHOP_ID="$shop_id"
TILL_ID="$till_id"
STATIC_IP_ADDRESS="$static_ip"
NETWORK_PRINTER_IP_ADDRESS="$printer_ip"
EOF

echo
echo "Configuration saved."
echo
read -r -p "Press Enter to close..."
