#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Proton VPN - status
# @raycast.mode inline
# @raycast.refreshTime 1m

# Optional parameters:
# @raycast.icon 🌐

# @Documentation:
# @raycast.packageName VPN
# @raycast.description Check VPN connection status.
# @raycast.author Eduardo Posadas
# @raycast.authorURL https://github.com/egposadas


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/vpn-config.sh"
VPN=$VPN_NAME

status=$(scutil --nc status "$VPN" | sed -n 1p)

if [ "$status" == "Connected" ]; then
  echo "✅ $status to $VPN"
  exit 0
fi

echo "$status"