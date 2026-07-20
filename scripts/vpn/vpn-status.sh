#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Azure VPN - status
# @raycast.mode inline
# @raycast.refreshTime 1m

# Optional parameters:
# @raycast.icon ../images/azure-vpn.png
# @raycast.packageName VPN

# Documentation:
# @raycast.description Check Azure VPN (rty-dna) connection status
# @raycast.author egposadas
# @raycast.authorURL https://github.com/egposadas


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/vpn-config.sh"
VPN=$VPN_NAME

if ! vpn_exists; then
  echo "⚠️ $VPN missing"
  exit 0
fi

status=$(vpn_status)

if [ "$status" == "Connected" ]; then
  echo "✅ Connected to $VPN"
  exit 0
fi

echo "Disconnected from $VPN"
