#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title DnA VPN - status
# @raycast.mode inline
# @raycast.refreshTime 1m

# Optional parameters:
# @raycast.icon 📡

# @Documentation:
# @raycast.packageName VPN
# @raycast.description Check VPN connection status.
# @raycast.author Alexandru Turcanu
# @raycast.authorURL https://github.com/Pondorasti


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/vpn-config.sh"
VPN=$VPN_NAME

status=$(scutil --nc status "$VPN" | sed -n 1p)

if [ "$status" == "Connected" ]; then
  echo "$status to $VPN"
  exit 0
fi

echo "$status"