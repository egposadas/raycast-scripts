#!/bin/bash

# Required parameters:
# DEACTIVATED — uncomment to re-enable in Raycast
# # @raycast.schemaVersion 1
# # @raycast.title Proton VPN - toggle
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🌐

# @Documentation:
# @raycast.packageName VPN
# @raycast.description Toggle VPN connection on/off.
# @raycast.author Eduardo Posadas
# @raycast.authorURL https://github.com/egposadas


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/vpn-config.sh"
VPN=$VPN_NAME

if vpn_is_connected; then
    vpn_toggle_via_settings "$VPN" "disconnect"
    sleep 2
    if vpn_is_connected; then
        echo "⚠️ Couldn't disconnect from $VPN"
        exit 1
    fi
    echo "❌ Disconnected from $VPN!"
    exit 0
fi

# Connect
vpn_toggle_via_settings "$VPN" "connect"

# Poll until connected (up to 20 seconds)
loops=0
max_loops=200

while ! vpn_is_connected; do
    sleep 0.1
    loops=$((loops + 1))
    [ $loops -gt $max_loops ] && break
done

if [ $loops -le $max_loops ]; then
    echo "✅ Connected to $VPN!"
else
    echo "⚠️ Couldn't connect to $VPN"
    vpn_toggle_via_settings "$VPN" "disconnect"
    exit 1
fi
