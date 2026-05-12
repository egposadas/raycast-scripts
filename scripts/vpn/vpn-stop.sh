#!/bin/bash

# Required parameters:
# DISABLED: @raycast.schemaVersion 1
# @raycast.title Disconnect
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📡

# @Documentation:
# @raycast.packageName VPN
# @raycast.description Stop VPN connection.
# @raycast.author Alexandru Turcanu
# @raycast.authorURL https://github.com/Pondorasti


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/vpn-config.sh"
VPN=$VPN_NAME

scutil --nc stop "$VPN"

echo "Disconnected from $VPN!"